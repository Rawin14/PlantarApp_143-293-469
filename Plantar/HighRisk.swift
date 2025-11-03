//
// HighRisk.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

struct HighRisk: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @State private var currentPageIndex = 6 // จุดสุดท้าย (จุดที่ 7)
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255)
    let selectedDotColor = Color(red: 188/255, green: 204/255, blue: 112/255)
    let unselectedDotColor = Color(red: 220/255, green: 220/255, blue: 220/255)
    let redColor = Color(red: 204/255, green: 71/255, blue: 56/255)
    let buttonColor = Color(red: 94/255, green: 84/255, blue: 68/255) // สีปุ่ม Complete (น้ำตาลเทา)
    
    var body: some View {
        ZStack {
            // 1. สีพื้นหลัง
            backgroundColor.ignoresSafeArea()
            
            // 2. UI หลัก
            VStack(alignment: .leading, spacing: 0) {
                // ปุ่ม Back Arrow
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title2.weight(.medium))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(.white.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(.bottom, 16)
                
                // เนื้อหาหลัก
                VStack(spacing: 24) {
                    Spacer()
                    
                    // ไอคอนเตือน (สามเหลี่ยมสีขาวในวงกลมแดง)
                    ZStack {
                        Circle()
                            .fill(redColor)
                            .frame(width: 200, height: 200)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 16)
                    
                    // ข้อความ High Risk
                    Text("High Risk")
                        .font(.system(size: 36))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    // คำอธิบาย
                    Text("Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit. Maecenas ornare .")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    Spacer()
                    
                    // ปุ่ม Complete (สีเปลี่ยนเป็นน้ำตาลเทา)
                    Button(action: {
                        dismiss() // กลับไปหน้าก่อนหน้า
                    }) {
                        Text("Complete")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(buttonColor) // เปลี่ยนจาก .black
                            .clipShape(Capsule())
                    }
                    
                    // Page Indicator (7 จุด - จุดสุดท้ายเป็นสีเขียว)
                    HStack(spacing: 8) {
                        ForEach(0..<7, id: \.self) { index in
                            Circle()
                                .fill(index == currentPageIndex ? selectedDotColor : unselectedDotColor)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        HighRisk()
    }
}
