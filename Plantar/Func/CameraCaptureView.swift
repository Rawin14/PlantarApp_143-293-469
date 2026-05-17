//
//  CameraCaptureView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI
import AVFoundation

struct CameraCaptureView: View {
    @Environment(\.dismiss) var dismiss
    
    let onComplete: ([UIImage]) -> Void
    
    @State private var capturedImages: [UIImage] = []
    @State private var isPressingShutter = false // สำหรับ Animation ปุ่มชัตเตอร์
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // 1. Camera Preview (ชั้นล่างสุด)
            CameraPreview(capturedImages: $capturedImages)
                .ignoresSafeArea()
            
            // 2. Foot Guide Overlay (ชั้นกลาง - กรอบช่วยถ่าย)
            FootOverlayView()
                .ignoresSafeArea()
            
            // 3. UI Layer
            VStack {
                // --- Top Bar ---
                HStack {
                    if !capturedImages.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "photo.stack")
                            Text("\(capturedImages.count) รูป")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal)
                
                Spacer()
                
                // --- Bottom Control Bar ---
                ZStack {
                    // Gradient Background
                    LinearGradient(
                        colors: [.black.opacity(0), .black.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 180)
                    .ignoresSafeArea()
                    
                    HStack(alignment: .center, spacing: 30) {
                        
                        // 1. Cancel / Back Button
                        Button(action: { dismiss() }) {
                            Text("ยกเลิก")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(width: 80) // กำหนดความกว้างให้สมดุลกับปุ่มขวา
                        }
                        
                        // 2. Shutter Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isPressingShutter = true
                            }
                            NotificationCenter.default.post(name: .takePhoto, object: nil)
                            
                            // Reset animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation { isPressingShutter = false }
                            }
                        }) {
                            ShutterButton(isPressed: isPressingShutter)
                        }
                        
                        // 3. Thumbnail / Submit Button (ปรับให้เข้าใจง่ายขึ้น)
                        Button(action: {
                            if !capturedImages.isEmpty {
                                onComplete(capturedImages)
                                dismiss()
                            }
                        }) {
                            VStack(spacing: 8) {
                                if let lastImage = capturedImages.last {
                                    // Show Thumbnail & Badge
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: lastImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white, lineWidth: 2)
                                            )
                                        
                                        // Badge checkmark
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .background(Circle().fill(.white).padding(2))
                                            .offset(x: 8, y: -8)
                                    }
                                    .frame(width: 60, height: 60)
                                    
                                    // ✅ เพิ่มข้อความให้ชัดเจนว่าต้องกดส่ง
                                    Text("วิเคราะห์รูป")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                } else {
                                    // Placeholder (Disabled)
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                    
                                    Text(" ")
                                        .font(.caption)
                                }
                            }
                            .frame(width: 80) // กำหนดความกว้างให้สมดุลกับปุ่มซ้าย
                        }
                        .disabled(capturedImages.isEmpty)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

// MARK: - Components

// ปุ่มชัตเตอร์
struct ShutterButton: View {
    var isPressed: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white, lineWidth: 4)
                .frame(width: 76, height: 76)
            
            Circle()
                .fill(Color.white)
                .frame(width: isPressed ? 60 : 66, height: isPressed ? 60 : 66)
        }
    }
}

// กรอบช่วยถ่ายรูป (Foot Overlay)
struct FootOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. พื้นหลังสีดำจางๆ เจาะรูตรงกลาง
                Color.black.opacity(0.6)
                    .mask(
                        ZStack {
                            Rectangle().fill(Color.white)
                            
                            // ✅ ปรับสัดส่วนรูให้เป็นสี่เหลี่ยมแนวตั้ง เหมาะสำหรับรอยเท้า
                            RoundedRectangle(cornerRadius: 40)
                                .fill(Color.black)
                                .frame(width: geometry.size.width * 0.55, height: geometry.size.height * 0.6)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                    )
                
                // 2. เส้นประขอบเขต
                RoundedRectangle(cornerRadius: 40)
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [12, 12]))
                    .foregroundColor(Color(red: 172/255, green: 187/255, blue: 98/255)) // ใช้สีเขียวของแอปให้ชัดขึ้น
                    .frame(width: geometry.size.width * 0.55, height: geometry.size.height * 0.6)
                
                // 3. ข้อความแนะนำ (ปรับปรุงใหม่ให้อ่านง่ายและชัดเจน)
                VStack {
                    Text("วางรอยเท้าเปียกให้อยู่ในกรอบ")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 4, x: 0, y: 2)
                        .padding(.top, geometry.size.height * 0.1)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("ถ่ายในที่สว่างเพื่อให้ AI วิเคราะห์ได้แม่นยำ")
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Capsule())
                    .padding(.bottom, geometry.size.height * 0.25)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Notification & Preview Logic

extension Notification.Name {
    static let takePhoto = Notification.Name("takePhotoNotification")
}

struct CameraPreview: UIViewRepresentable {
    @Binding var capturedImages: [UIImage]
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        
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
            
            // ✅ เลือกระยะเลนส์ Wide ธรรมดา
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device) else { return }
            
            // ✅ บังคับล็อคเลนส์เป็น 1.0x (1x) เสมอ เพื่อป้องกันกล้องสลับไป 0.5x หรือบิดเบี้ยว
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = 1.0
                device.unlockForConfiguration()
            } catch {
                print("Cannot lock device configuration")
            }
            
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
            
            // Haptic Feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            DispatchQueue.main.async {
                withAnimation {
                    self.capturedImages.append(image)
                }
            }
        }
    }
}
