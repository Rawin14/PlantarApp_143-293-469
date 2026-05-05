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
                    // ปุ่ม Cancel ย้ายมาข้างบน (เหมือนแอปกล้องทั่วไป) หรือจะไว้ล่างก็ได้
                    // ในที่นี้ขอเอาไว้ข้างล่างเพื่อให้กดมือเดียวง่าย แต่ข้างบนแสดงสถานะ
                    
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
                    
                    HStack(alignment: .center, spacing: 40) {
                        
                        // 1. Cancel / Back Button
                        Button(action: { dismiss() }) {
                            Text("ยกเลิก")
                                .font(.callout)
                                .foregroundColor(.white)
                                .frame(width: 70)
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
                        
                        // 3. Thumbnail / Done Button
                        Button(action: {
                            if !capturedImages.isEmpty {
                                onComplete(capturedImages)
                                dismiss()
                            }
                        }) {
                            if let lastImage = capturedImages.last {
                                // Show Thumbnail
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
                                        .offset(x: 5, y: -5)
                                }
                                .frame(width: 70) // Frame เพื่อจัด layout ให้เท่ากัน
                            } else {
                                // Placeholder (Disabled)
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 60, height: 60)
                                    .frame(width: 70)
                            }
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

// ปุ่มชัตเตอร์สวยๆ
struct ShutterButton: View {
    var isPressed: Bool
    
    var body: some View {
        ZStack {
            // วงแหวนนอก
            Circle()
                .stroke(Color.white, lineWidth: 4)
                .frame(width: 76, height: 76)
            
            // วงกลมใน
            Circle()
                .fill(Color.white)
                .frame(width: isPressed ? 60 : 66, height: isPressed ? 60 : 66) // Animation ย่อขยาย
        }
    }
}

// กรอบช่วยถ่ายรูป (Foot Overlay)
struct FootOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. พื้นหลังสีดำจางๆ เจาะรูตรงกลาง
                Color.black.opacity(0.5)
                    .mask(
                        ZStack {
                            Rectangle().fill(Color.white)
                            
                            // เจาะรูสี่เหลี่ยมมน
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.black)
                                .frame(width: geometry.size.width * 0.75, height: geometry.size.height * 0.55)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                    )
                
                // 2. เส้นประขอบเขต
                RoundedRectangle(cornerRadius: 30)
                    .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [10, 10]))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: geometry.size.width * 0.75, height: geometry.size.height * 0.55)
                
                // 3. ข้อความแนะนำ
                VStack {
                    Text("ถ่ายรอยเท้าให้ตรงกรอบ")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 4)
                        .padding(.top, geometry.size.height * 0.15)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "sun.max.fill")
                        Text("หาสถานที่ที่มีแสงสว่างเพียงพอ")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.3))
                    .cornerRadius(20)
                    .padding(.bottom, geometry.size.height * 0.22)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Notification & Preview Logic (คงเดิม)

extension Notification.Name {
    static let takePhoto = Notification.Name("takePhotoNotification")
}

struct CameraPreview: UIViewRepresentable {
    @Binding var capturedImages: [UIImage]
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black // กันสีขาวแลบตอนโหลด
        
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
            // เปิด High Resolution ถ้าต้องการภาพชัดๆ
            // settings.isHighResolutionPhotoEnabled = true
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
            
            // Flash Animation Effect (Optional: ใส่เพิ่มใน View ได้ถ้าต้องการ)
            
            DispatchQueue.main.async {
                withAnimation {
                    self.capturedImages.append(image)
                }
            }
        }
    }
}
