//
//  CameraCaptureView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//
//
//  CameraCaptureView.swift
//  Plantar
//

import SwiftUI
import AVFoundation

struct CameraCaptureView: View {
    @Environment(\.dismiss) var dismiss
    
    let onComplete: ([UIImage]) -> Void
    
    @State private var capturedImages: [UIImage] = []
    @State private var showImageCount = true
    
    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreview(capturedImages: $capturedImages)
                .ignoresSafeArea()
            
            // UI Overlay
            VStack {
                // Image Count
                if showImageCount {
                    Text("\(capturedImages.count) รูป")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(.black.opacity(0.5))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                // Buttons
                HStack(alignment: .bottom) {
                    // Cancel
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(40)
                    
                    Spacer()
                    
                    // Capture Button
                    Button(action: {
                        NotificationCenter.default.post(name: .takePhoto, object: nil)
                    }) {
                        Circle()
                            .fill(.white)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().stroke(.black, lineWidth: 3))
                    }
                    
                    Spacer()
                    
                    // Done Button
                    Button("Done") {
                        if capturedImages.count >= 1 {
                            onComplete(capturedImages)
                            dismiss()
                        }
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(capturedImages.count < 1 ? .gray : .green)
                    .padding(40)
                    .disabled(capturedImages.count < 1)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

// Notification Name
extension Notification.Name {
    static let takePhoto = Notification.Name("takePhotoNotification")
}

// Camera Preview
struct CameraPreview: UIViewRepresentable {
    @Binding var capturedImages: [UIImage]
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        context.coordinator.setupCaptureSession { previewLayer in
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        
        NotificationCenter.default.addObserver(
            forName: .takePhoto,
            object: nil,
            queue: .main
        ) { _ in
            context.coordinator.takePhoto()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(capturedImages: $capturedImages)
    }
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        @Binding var capturedImages: [UIImage]
        
        var session: AVCaptureSession?
        var output = AVCapturePhotoOutput()
        
        init(capturedImages: Binding<[UIImage]>) {
            _capturedImages = capturedImages
        }
        
        func setupCaptureSession(completion: @escaping (AVCaptureVideoPreviewLayer) -> Void) {
            let session = AVCaptureSession()
            session.sessionPreset = .photo
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device) else { return }
            
            if session.canAddInput(input) { session.addInput(input) }
            if session.canAddOutput(output) { session.addOutput(output) }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
                DispatchQueue.main.async {
                    completion(previewLayer)
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
                print("Error: \(error)")
                return
            }
            
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.capturedImages.append(image)
            }
        }
    }
}
