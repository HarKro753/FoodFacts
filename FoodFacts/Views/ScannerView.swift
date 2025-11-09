//
//  ScannerView.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Scanner View
struct ScannerView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var detectedBarcode: String?
    @State private var isFlashOn = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Camera Preview - Full Screen
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()

                // Simple gray frame overlay
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 280, height: 200)

                // Detected barcode overlay
                if let barcode = detectedBarcode {
                    VStack {
                        Spacer()
                        BarcodeDetectedView(barcode: barcode, onDismiss: {
                            detectedBarcode = nil
                            cameraManager.startScanning()
                        })
                        Spacer()
                            .frame(height: 80)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle("Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isFlashOn.toggle()
                        cameraManager.toggleFlash(isFlashOn)
                    } label: {
                        Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                cameraManager.requestPermission()
                cameraManager.onBarcodeDetected = { barcode in
                    withAnimation {
                        detectedBarcode = barcode
                    }
                }
            }
            .onDisappear {
                cameraManager.stopSession()
            }
        }
    }
}

// MARK: - Camera Manager
class CameraManager: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    let session = AVCaptureSession()
    private var captureDevice: AVCaptureDevice?
    var onBarcodeDetected: ((String) -> Void)?

    override init() {
        super.init()
        setupCamera()
    }

    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            if granted {
                DispatchQueue.main.async {
                    self?.startSession()
                }
            }
        }
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        captureDevice = device

        do {
            let input = try AVCaptureDeviceInput(device: device)

            if session.canAddInput(input) {
                session.addInput(input)
            }

            let output = AVCaptureMetadataOutput()

            if session.canAddOutput(output) {
                session.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = [.ean8, .ean13, .upce, .qr, .code128, .code39]
            }
        } catch {
            print("Error setting up camera: \(error)")
        }
    }

    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func startScanning() {
        startSession()
    }

    func toggleFlash(_ isOn: Bool) {
        guard let device = captureDevice, device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = isOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flash: \(error)")
        }
    }

    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let barcode = metadataObject.stringValue {
            // Stop scanning temporarily after detection
            Task { @MainActor in
                stopSession()
                onBarcodeDetected?(barcode)
            }
        }
    }
}

// MARK: - Camera Preview
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        context.coordinator.previewLayer = previewLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.previewLayer?.frame = uiView.bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Barcode Detected View Component
struct BarcodeDetectedView: View {
    let barcode: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)

            Text("Barcode Detected")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Text(barcode)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)

            HStack(spacing: 12) {
                Button {
                    onDismiss()
                } label: {
                    Text("Scan Again")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.6))
                        .cornerRadius(10)
                }

                NavigationLink {
//                    ProductDetail()
                } label: {
                    Text("View Product")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
    }
}

#Preview {
    ScannerView()
}
