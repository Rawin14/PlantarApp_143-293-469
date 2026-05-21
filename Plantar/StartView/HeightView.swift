//
// HeightView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 18/10/2568 BE.
//

import SwiftUI

// MARK: - HeightView Colors
extension Color {
    // 🎨 **Height-Specific Colors** (ตัวแปรสีห้ามซ้ำ)
    static let Height_Background = Color(red: 247/255, green: 246/255, blue: 236/255) // สีพื้นหลังหลัก (ครีมอ่อน)
    static let Height_Primary = Color(red: 139/255, green: 122/255, blue: 184/255)  // สีม่วงหลัก (สำหรับตัวเลข, ขีดบน Ruler)
    static let Height_Accent = Color(red: 172/255, green: 187/255, blue: 98/255)    // สีเขียวอ่อน (สำหรับวงกลมด้านบน)
    static let Height_SecondaryText = Color(red: 100/255, green: 100/255, blue: 100/255) // สีเทาสำหรับข้อความ
    static let Height_InfoBox = Color(red: 220/255, green: 220/255, blue: 220/255) // สีพื้นหลังกล่องข้อความ
    static let Height_PageIndicatorActive = Color.black // สีจุด Page Indicator ที่ใช้งานอยู่
    static let Height_PageIndicatorInactive = Color(red: 200/255, green: 200/255, blue: 200/255) // สีจุด Page Indicator ที่ไม่ใช้งาน
    static let Height_ButtonBackground = Color.white // สีพื้นหลังปุ่ม +/-
    static let Height_NextButton = Color(red: 94/255, green: 84/255, blue: 68/255) // สีปุ่ม Next (น้ำตาลเทา)
}

// MARK: - HeightView Main View
struct HeightView: View {
    @State private var currentHeight: Int = 160
    @State private var currentPage: Int = 1
    @State private var navigateToWeight = false
    @EnvironmentObject var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss

    let minHeight: Int = 100
    let maxHeight: Int = 220
    let heightStep: Int = 1

    var body: some View {
        ZStack {
            Color.Height_Background.ignoresSafeArea()

            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                    }
                    .padding(.leading, 10)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Title
                Text("โปรดระบุส่วนสูง ?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

                Spacer()

                // Height Display
                HStack(alignment: .bottom, spacing: 5) {
                    Text("\(currentHeight)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(Color.Height_Primary)

                    Text("ซม.")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(Color.Height_Primary.opacity(0.8))
                        .offset(y: -10)
                }
                .padding(.vertical, 30)

                // Ruler — ส่ง Binding<Int> ตรงๆ ไม่ต้องแปลง
                GenericRuler(
                            selectedValue: $currentHeight,
                            config: HeightRulerConfig(),
                            themeColor: Color.Height_Primary
                        )
                // +/- Buttons
                HStack(spacing: 40) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentHeight > minHeight { currentHeight -= heightStep }
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.title2).fontWeight(.semibold)
                            .foregroundColor(currentHeight <= minHeight
                                ? Color.Height_SecondaryText.opacity(0.3)
                                : Color.Height_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Height_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentHeight <= minHeight)

                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentHeight < maxHeight { currentHeight += heightStep }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2).fontWeight(.semibold)
                            .foregroundColor(currentHeight >= maxHeight
                                ? Color.Height_SecondaryText.opacity(0.3)
                                : Color.Height_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Height_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentHeight >= maxHeight)
                }
                .padding(.top, 10)

                Spacer()

                // Info Box
                Text("ระบุส่วนสูงปัจจุบันเพื่อคำนวณค่า BMI และวิเคราะห์โครงสร้างร่างกายเบื้องต้น")
                    .font(.body)
                    .foregroundColor(Color.Height_SecondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.Height_InfoBox)
                    .cornerRadius(15)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 20)

                // Next Button
                Button(action: {
                    userProfile.height = Double(currentHeight)
                    Task { await userProfile.saveToSupabase() }
                    navigateToWeight = true
                }) {
                    Text("ถัดไป")
                        .font(.title3).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.Height_NextButton)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)

                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index == currentPage
                                ? Color.Height_PageIndicatorActive
                                : Color.Height_PageIndicatorInactive)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToWeight) {
            WeightView()
        }
        .onAppear {
            if userProfile.height > 0 {
                currentHeight = Int(userProfile.height)
            }
        }
    }
}

// MARK: - Preview ✔ (แก้แล้ว)
struct HeightView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HeightView()
                .environmentObject(UserProfile())   // ✅ แก้ตรงนี้อย่างเดียว
        }
    }
}
