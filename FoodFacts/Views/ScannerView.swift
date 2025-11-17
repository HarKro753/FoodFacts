//
//  ScannerView.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import AVFoundation
import Combine
import SwiftUI

// MARK: - Scanner View
struct ScannerView: View {
    @StateObject private var viewModel = ScannerViewModel()
    @StateObject private var cameraManager = CameraManager()
    @State private var detectedBarcode: String?
    @State private var isFlashOn = false
    @State private var showProductDetail = false

    var body: some View {
        NavigationStack {
            ZStack {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()

                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 280, height: 200)
            }
            .navigationTitle("Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isFlashOn.toggle()
                        cameraManager.toggleFlash(isFlashOn)
                    } label: {
                        Image(
                            systemName: isFlashOn
                                ? "bolt.fill" : "bolt.slash.fill"
                        )
                        .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                cameraManager.requestPermission()
                cameraManager.onBarcodeDetected = { barcode in
                    guard detectedBarcode != barcode && !showProductDetail
                    else {
                        return
                    }

                    detectedBarcode = barcode

                    Task {
                        await viewModel.handleScannedBarcode(
                            productCode: barcode
                        )
                        if viewModel.scannedProduct != nil {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showProductDetail = true
                            }
                        } else {
                            detectedBarcode = nil
                        }
                    }
                }
            }
            .onDisappear {
                cameraManager.stopSession()
            }
            .sheet(
                isPresented: $showProductDetail,
                onDismiss: {
                    viewModel.clearScannedProduct()
                    detectedBarcode = nil
                    cameraManager.startSession()
                }
            ) {
                if let product = viewModel.scannedProduct {
                    ProductDetailSheet(product: product)
                }
            }
            .onChange(of: showProductDetail) { oldValue, newValue in
                if newValue {
                    cameraManager.stopSession()
                }
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Product Detail Sheet
struct ProductDetailSheet: View {
    let product: Product
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ProductDetail(product: product)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")

                        }
                    }
                }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

#Preview("Scanner") {
    ScannerView()
}

#Preview("Product Detail Sheet") {
    ProductDetailSheet(product: Product.sampleProducts[0])
}
