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
                    // Only fetch if it's a new barcode
                    if detectedBarcode != barcode {
                        detectedBarcode = barcode
                        // Fetch product and add to history
                        Task {
                            await viewModel.handleScannedBarcode(
                                productCode: barcode
                            )
                            if viewModel.scannedProduct != nil {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showProductDetail = true
                                }
                            }
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
                    // Clear the scanned product when sheet is dismissed
                    viewModel.clearScannedProduct()
                    detectedBarcode = nil
                }
            ) {
                if let product = viewModel.scannedProduct {
                    ProductDetailSheet(product: product)
                }
            }
            .alert(
                "Error",
                isPresented: .constant(viewModel.errorMessage != nil)
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
