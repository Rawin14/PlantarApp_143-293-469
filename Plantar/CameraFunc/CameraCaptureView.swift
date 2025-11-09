//
//  CameraCaptureView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI
import AVFoundation

struct CameraCaptureView: View {
    
    @ObservedObject var manager: CaptureUploadManager
    @Environment(\.dismiss) var dismiss
    
    @State private var capturedImage: UIImage? = nil // เก็บรูปที่ถ่าย
    @State private var showPreview = false // แสดงหน้า Preview
    
    var body: some View {
        ZStack {
            if showPreview, let image = capturedImage {
                // แสดง Preview ของรูปที่ถ่าย
                ImagePreviewView(
                    image: image,
                    onRetake: {
                        // ถ่ายใหม่
                        capturedImage = nil
                        showPreview = false
                    },
                    onConfirm: {
                        // ยืนยันและอัปโหลด
                        manager.addImage(image)
                        manager.startUpload(footSide: .left)
                        dismiss()
                    }
                )
            } else {
                // แสดงกล้อง
                CameraPreview(capturedImage: $capturedImage, showPreview: $showPreview)
                    .ignoresSafeArea()
                
                // UI ที่ลอยทับ
                VStack {
                    Spacer()
                    
                    HStack(alignment: .bottom) {
                        // ปุ่มยกเลิก
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(40)
                        
                        Spacer()
                        
                        // ปุ่มถ่ายรูป
                        Button(action: {
                            NotificationCenter.default.post(name: .takePhoto, object: nil)
                        }) {
                            Circle()
                                .fill(.white)
                                .frame(width: 70, height: 70)
                                .overlay(Circle().stroke(.black, lineWidth: 3))
                        }
                        
                        Spacer()
                        
                        // ช่องว่าง (เพื่อความสมดุล)
                        Color.clear
                            .frame(width: 80)
                            .padding(40)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            manager.setupFolders(footSide: .left)
        }
    }
}

// MARK: - Image Preview View
struct ImagePreviewView: View {
    let image: UIImage
    let onRetake: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // แสดงรูป
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // ปุ่ม
                HStack(spacing: 40) {
                    Button("Retake") {
                        onRetake()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.red.opacity(0.8))
                    .clipShape(Capsule())
                    
                    Button("Use Photo") {
                        onConfirm()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.green.opacity(0.8))
                    .clipShape(Capsule())
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Notification
extension Notification.Name {
    static let takePhoto = Notification.Name("takePhotoNotification")
}

// MARK: - Camera Preview
struct CameraPreview: UIViewRepresentable {
    
    @Binding var capturedImage: UIImage?
    @Binding var showPreview: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        context.coordinator.setupCaptureSession { previewLayer in
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        
        NotificationCenter.default.addObserver(
            forName: .takePhoto,
            object: nil,
            queue: .main) { _ in
                context.coordinator.takePhoto()
            }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(capturedImage: $capturedImage, showPreview: $showPreview)
    }
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        @Binding var capturedImage: UIImage?
        @Binding var showPreview: Bool
        
        var session: AVCaptureSession?
        var output = AVCapturePhotoOutput()
        var previewLayer: AVCaptureVideoPreviewLayer?
        
        init(capturedImage: Binding<UIImage?>, showPreview: Binding<Bool>) {
            _capturedImage = capturedImage
            _showPreview = showPreview
            super.init()
        }
        
        func setupCaptureSession(completion: @escaping (AVCaptureVideoPreviewLayer) -> Void) {
            let session = AVCaptureSession()
            session.sessionPreset = .photo
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device) else { return }
            
            if session.canAddInput(input) { session.addInput(input) }
            if session.canAddOutput(output) { session.addOutput(output) }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspectFill
            
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
                DispatchQueue.main.async {
                    if let layer = self.previewLayer {
                        completion(layer)
                    }
                }
            }
            
            self.session = session
        }
        
        func takePhoto() {
            let settings = AVCapturePhotoSettings()
            output.capturePhoto(with: settings, delegate: self)
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                print("Error ถ่ายรูป: \(error)")
                return
            }
            
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.capturedImage = image
                self.showPreview = true
            }
        }
    }
}
