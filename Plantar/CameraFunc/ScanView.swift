//
//  ScanView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

enum ScanState {
    case idle       // ยังไม่เริ่ม
    case scanning   // (Photogrammetry ไม่ได้ใช้ แต่มีไว้เผื่อ)
    case saving     // กำลังประมวลผล (Processing)
    case finished   // เสร็จแล้ว
}

struct ScanView: View {
    
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @State private var selectedFoot: FootSide = .left
    @State private var currentPageIndex = 4
    
    // --- State ควบคุม Object Capture ---
    @StateObject private var captureManager = ObjectCaptureManager()
    @State private var isShowingCameraSheet = false // State สำหรับเปิดหน้ากล้อง
    
    // --- State สำหรับแสดง Alert ---
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // Enum สำหรับเลือกข้าง
    enum FootSide {
        case left, right
    }
    
    // --- Custom Colors --- (เหมือนเดิม)
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255)
    let selectedDotColor = Color(red: 188/255, green: 204/255, blue: 112/255)
    let unselectedSegmentColor = Color(red: 220/255, green: 220/255, blue: 220/255)
    let unselectedDotColor = Color(red: 220/255, green: 220/255, blue: 220/255)
    
    
    var body: some View {
        ZStack {
            // 1. สีพื้นหลัง
            backgroundColor.ignoresSafeArea()
            
            // 2. UI หลัก
            VStack(alignment: .leading, spacing: 16) {
                
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
                
                // --- สลับ UI ตอนกำลังประมวลผล ---
                if captureManager.scanState == .saving {
                    
                    VStack(spacing: 20) {
                        Text("Processing...")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("กำลังสร้างโมเดล 3D... กรุณารอ (1-5 นาที)")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: captureManager.processingProgress)
                            .padding(.vertical)
                        Text("\(Int(captureManager.processingProgress * 100))%")
                            .font(.title)
                        Spacer()
                    }
                    
                } else {
                    
                    // --- UI ปกติ (ก่อนประมวลผล) ---
                    
                    // 3. ส่วนหัวข้อ
                    Text("Scan your feet")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("เลือกเท้าที่ต้องการสแกน และเตรียมถ่ายรูปอย่างน้อย 10-40 รูป")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // 4. ปุ่มเลือก Left/Right
                    FootSegmentedControl(selectedSide: $selectedFoot,
                                         unselectedColor: unselectedSegmentColor)
                        .padding(.vertical, 24)
                    
                    // 5. รูป Placeholder (เปลี่ยนเป็นรูปกล้อง)
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
                    
                    // 6. ปุ่ม "Next" เปลี่ยนเป็น "Start Capture"
                    Button(action: {
                        isShowingCameraSheet = true // เปิดหน้ากล้อง
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
                    
                    // 7. Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .fill(index == currentPageIndex ? selectedDotColor : unselectedDotColor)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                } // End if-else
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isShowingCameraSheet) {
            // 3. แสดงหน้ากล้อง (CameraCaptureView)
            CameraCaptureView(manager: captureManager, footSide: $selectedFoot)
        }
        .onChange(of: captureManager.scanState) { newState in
            // 4. เมื่อประมวลผลเสร็จ (finished)
            if newState == .finished {
                if let url = captureManager.exportedURL {
                    alertTitle = "บันทึกสำเร็จ!"
                    alertMessage = "ไฟล์ถูกบันทึกที่: \(url.lastPathComponent)"
                } else {
                    alertTitle = "ผิดพลาด"
                    alertMessage = "ไม่สามารถบันทึกไฟล์ได้"
                }
                isShowingAlert = true
                captureManager.scanState = .idle // Reset
            }
        }
        .alert(alertTitle, isPresented: $isShowingAlert) {
            Button("ตกลง") {
                // TODO: ไปหน้าต่อไป หรือสแกนอีกข้าง
            }
        } message: {
            Text(alertMessage)
        }
    }
}

// --- Component ย่อย (เหมือนเดิม) ---
struct FootSegmentedControl: View {
    @Binding var selectedSide: ScanView.FootSide
    let unselectedColor: Color
    // ... (โค้ดข้างในเหมือนเดิม ไม่ต้องแก้) ...
    var body: some View {
        HStack(spacing: 4) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedSide = .left
                }
            }) {
                Text("Left")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedSide == .left ? .white : .clear)
                    .foregroundColor(selectedSide == .left ? .black : .secondary)
                    .clipShape(Capsule())
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedSide = .right
                }
            }) {
                Text("Right")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedSide == .right ? .white : .clear)
                    .foregroundColor(selectedSide == .right ? .black : .secondary)
                    .clipShape(Capsule())
            }
        }
        .padding(4)
        .background(unselectedColor)
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        ScanView()
    }
}
