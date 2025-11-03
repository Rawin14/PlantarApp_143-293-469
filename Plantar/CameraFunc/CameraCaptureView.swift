//
//  CameraCaptureView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI
import AVFoundation

// นี่คือ View ที่จะเด้งขึ้นมา (Sheet)
struct CameraCaptureView: View {
    
    @ObservedObject var manager: CaptureUploadManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 1. กล้อง (เต็มจอ)
            CameraPreview(manager: manager)
                .ignoresSafeArea()
            
            // 2. UI ที่ลอยทับ
            VStack {
                // 2.1. หัวข้อ (บอกว่าถ่ายกี่รูป)
                Text("\(manager.imageCount) รูป")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(.black.opacity(0.5))
                    .clipShape(Capsule())
                
                Spacer()
                
                // 2.2. ปุ่ม
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
                        // ส่งสัญญาณให้ CameraPreview ถ่ายรูป
                        NotificationCenter.default.post(name: .takePhoto, object: nil)
                    }) {
                        Circle()
                            .fill(.white)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().stroke(.black, lineWidth: 3))
                    }
                    
                    Spacer()
                    
                    // ปุ่มเสร็จสิ้น (จะเรียก startUpload)
                    Button("Upload") {
                        // 👇 ไม่ต้องใช้ footSide แล้ว หรือใช้ค่า default
                        manager.startUpload(footSide: .left)
                        dismiss() // ปิดหน้ากล้อง
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(manager.imageCount < 10 ? .gray : .green)
                    .padding(40)
                    .disabled(manager.imageCount < 10) // ต้องถ่ายอย่างน้อย 10 รูป
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            // 👇 ไม่ต้องใช้ footSide แล้ว หรือใช้ค่า default
            manager.setupFolders(footSide: .left)
        }
    }
}

// สร้าง Notification Name
extension Notification.Name {
    static let takePhoto = Notification.Name("takePhotoNotification")
}

// --- สะพานเชื่อม UIKit (AVFoundation) กับ SwiftUI ---
struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var manager: CaptureUploadManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        context.coordinator.setupCaptureSession { previewLayer in
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        
        // 1. ฟัง Notification "takePhoto"
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
        Coordinator(parent: self, manager: manager)
    }
    
    // --- Coordinator (สมองของกล้อง) ---
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraPreview
        var manager: CaptureUploadManager
        var session: AVCaptureSession?
        var output = AVCapturePhotoOutput()
        var previewLayer: AVCaptureVideoPreviewLayer?
        
        init(parent: CameraPreview, manager: CaptureUploadManager) {
            self.parent = parent
            self.manager = manager
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
            
            // 2. ส่งรูปที่ถ่ายได้ไปให้ Manager
            Task { @MainActor in
                manager.addImage(image)
            }
        }
    }
}
