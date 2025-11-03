//
// ScanView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

// 📍 เราจะประกาศ enum ScanState ไว้ที่นี่
enum ScanState {
    case idle       // ยังไม่เริ่ม
    case saving     // กำลังอัปโหลด
    case finished   // อัปโหลดเสร็จ
}

struct ScanView: View {
    
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @State private var currentPageIndex = 4
    
    // --- State ควบคุม Capture/Upload ---
    @StateObject private var captureManager = CaptureUploadManager()
    @State private var navigateToCamera = false
    
    // --- State สำหรับแสดง Alert ---
    @State private var isShowingErrorAlert = false
    @State private var alertMessage = ""
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255)
    let selectedDotColor = Color(red: 188/255, green: 204/255, blue: 112/255)
    let unselectedDotColor = Color(red: 220/255, green: 220/255, blue: 220/255)
    
    var body: some View {
        ZStack {
            // 1. สีพื้นหลัง
            backgroundColor.ignoresSafeArea()
            
            // 2. UI หลัก
            VStack(alignment: .leading, spacing: 16) {
                
                // --- สลับ UI ตามสถานะ ---
                
                // --- สถานะ: กำลังอัปโหลด ---
                if captureManager.scanState == .saving {
                    VStack(spacing: 20) {
                        Text("Uploading...")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("กำลังอัปโหลดรูปภาพ (1-2 นาที)")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: captureManager.processingProgress)
                            .padding(.vertical)
                        Text("\(Int(captureManager.processingProgress * 100))%")
                            .font(.title)
                        Spacer()
                    }
                    
                // --- สถานะ: อัปโหลดเสร็จสิ้น ---
                } else if captureManager.scanState == .finished {
                    VStack(spacing: 20) {
                        Text("Upload Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.green)
                            .padding()
                        
                        Text("อัปโหลดสำเร็จ! ไฟล์ของคุณกำลังถูกประมวลผลบนเซิร์ฟเวอร์")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        Button(action: {
                            captureManager.scanState = .idle // กลับไปหน้าแรก
                        }) {
                            Text("Scan Again")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.black)
                                .clipShape(Capsule())
                        }
                    }
                    
                // --- สถานะ: เริ่มต้น (idle) ---
                } else {
                    
                    // 2. ปุ่ม Back Arrow
                    Button(action: {
                        dismiss() // ย้อนกลับ
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2.weight(.medium))
                            .foregroundColor(.black)
                            .padding(8)
                            .background(.white.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 16)
                    
                    // 3. ส่วนหัวข้อ
                    Text("Scan your feet")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("เตรียมถ่ายรูปเท้าของคุณอย่างน้อย 10-40 รูป")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.bottom, 24)
                    
                    // 4. รูป Placeholder (เปลี่ยนเป็นรูปกล้อง)
                    HStack {
                        Spacer()
                        Image(systemName: "camera.fill.badge.ellipsis")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200)
                            .foregroundColor(.black.opacity(0.8))
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // 5. ปุ่ม "Start Capture" - นำทางไปหน้าถ่ายภาพ
                    Button(action: {
                        navigateToCamera = true
                    }) {
                        Text("Start Capture")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.black)
                            .clipShape(Capsule())
                    }
                    
                    // 6. Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .fill(index == currentPageIndex ? selectedDotColor : unselectedDotColor)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToCamera) {
            // 👇 ใช้ CameraCaptureView แทน CameraView
            CameraCaptureView(manager: captureManager)
        }
        .onChange(of: captureManager.scanState) { newState in
            // เมื่อมี Error
            if newState == .idle && captureManager.exportedURL == nil && captureManager.imageCount > 0 {
                alertMessage = "การอัปโหลดถูกยกเลิก หรือล้มเหลว"
                isShowingErrorAlert = true
            }
        }
        .alert("Error", isPresented: $isShowingErrorAlert) {
            Button("ตกลง") {}
        } message: {
            Text(alertMessage)
        }
    }
} 

// MARK: - CameraView (ตัวอย่างหน้าถ่ายภาพ)
struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var manager: CaptureUploadManager
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // แสดงจำนวนภาพที่ถ่ายแล้ว
                Text("Photos Captured: \(manager.imageCount)")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                
                // ใส่ UI สำหรับกล้องตรงนี้
                Text("Camera Interface")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 40) {
                    // ปุ่มปิด
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    // ปุ่มอัปโหลด (ถ้ามีภาพมากกว่า 10 ภาพ)
                    if manager.imageCount >= 10 {
                        Button("Upload (\(manager.imageCount) photos)") {
                            // เริ่มอัปโหลด (ไม่ต้องใช้ footSide แล้ว หรือใช้ค่า default)
                            manager.startUpload(footSide: .left) // หรือ .right ตามที่ต้องการ
                            dismiss()
                        }
                        .foregroundColor(.green)
                        .padding()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Setup folders เมื่อเข้าหน้ากล้อง (ไม่ต้องใช้ footSide แล้ว หรือใช้ค่า default)
            manager.setupFolders(footSide: .left) // หรือ .right ตามที่ต้องการ
        }
    }
}

#Preview {
    NavigationStack {
        ScanView()
    }
}
