//
// WeightView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 18/10/2568 BE.
//

import SwiftUI

// MARK: - WeightView Colors (ตัวแปรสีห้ามซ้ำ)
extension Color {
    static let Weight_Background = Color(red: 247/255, green: 246/255, blue: 236/255) // สีพื้นหลังหลัก (ครีมอ่อน)
    static let Weight_Primary = Color(red: 139/255, green: 122/255, blue: 184/255)  // สีม่วงหลัก (สำหรับตัวเลข, ขีดบน Ruler)
    static let Weight_Accent = Color(red: 172/255, green: 187/255, blue: 98/255)    // สีเขียวอ่อน (สำหรับวงกลมด้านบน)
    static let Weight_SecondaryText = Color(red: 100/255, green: 100/255, blue: 100/255) // สีเทาสำหรับข้อความ
    static let Weight_InfoBox = Color(red: 220/255, green: 220/255, blue: 220/255) // สีพื้นหลังกล่องข้อความ
    static let Weight_PageIndicatorActive = Color.black // สีจุด Page Indicator ที่ใช้งานอยู่
    static let Weight_PageIndicatorInactive = Color(red: 200/255, green: 200/255, blue: 200/255) // สีจุด Page Indicator ที่ไม่ใช้งาน
    static let Weight_ButtonBackground = Color.white // สีพื้นหลังปุ่ม +/-
    static let Weight_NextButton = Color(red: 94/255, green: 84/255, blue: 68/255) // สีปุ่ม Next (น้ำตาลเทา)
}

// MARK: - WeightView Main View
struct WeightView: View {
    // น้ำหนักเริ่มต้น
    @State private var currentWeight: Int = 55
    // สำหรับ Page Indicator ด้านล่าง
    @State private var currentPage: Int = 2
    
    @State private var isgotoBMIView = false
    
    @EnvironmentObject var userProfile: UserProfile // 👈 เพิ่ม
    @Environment(\.dismiss) private var dismiss // 👈 เพิ่ม
        
    
    // Constants for Weight Range
    let minWeight: Double = 10.0 // Min Weight in KG
    let maxWeight: Double = 200.0 // Max Weight in KG
    let weightStep: Double = 1.0 // Step 1 kg

    var body: some View {
        ZStack {
            Color.Weight_Background.ignoresSafeArea()
            
            VStack {
                // MARK: - Header
                    HStack {
                            Button(action: {
                            dismiss() // 👈 ย้อนกลับ
                                   }) {
                                       Image(systemName: "arrow.left")
                                           .font(.title2)
                                           .foregroundColor(.black)
                                   }
                        .padding(.leading, 10)
                        .onTapGesture {
                            print("Back button tapped")
                        }
                    Spacer()
                    // Status Bar (จำลอง)
                    Spacer()
                    HStack(spacing: 4) {
                    }
                    .font(.system(size: 15, weight: .medium))
                    .padding(.trailing, 10)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // MARK: - Title
                Text("โปรดระบุน้ำหนัก ?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

                Spacer()
                
                // MARK: - Current Weight Display
                HStack(alignment: .bottom, spacing: 5) {
                    Text("\(currentWeight)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(Color.Weight_Primary)
                    
                    Text("กก.")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(Color.Weight_Primary.opacity(0.8))
                        .offset(y: -10)
                }
                .padding(.vertical, 30)

                // MARK: - Ruler/Slider (แถบไม้บรรทัดที่เลื่อนได้)
                GenericRuler(
                            selectedValue: $currentWeight,
                            config: WeightRulerConfig(),
                            themeColor: Color.Weight_Primary // สีของ WeightView
                        )
                
                // MARK: - Plus/Minus Buttons
                HStack(spacing: 40) {
                    // ปุ่มลด (-)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentWeight > Int(minWeight) {
                                currentWeight -= Int(weightStep)
                            }
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(currentWeight <= Int(minWeight) ? Color.Weight_SecondaryText.opacity(0.3) : Color.Weight_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Weight_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentWeight <= Int(minWeight))
                    
                    // ปุ่มเพิ่ม (+)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentWeight < Int(maxWeight) {
                                currentWeight += Int(weightStep)
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(currentWeight >= Int(maxWeight) ? Color.Weight_SecondaryText.opacity(0.3) : Color.Weight_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Weight_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentWeight >= Int(maxWeight))
                }
                .padding(.top, 10)

                Spacer()
                
                // MARK: - Info Box
                Text("ระบุน้ำหนักปัจจุบันเพื่อคำนวณค่า BMI และประเมินสุขภาพของคุณ")
                    .font(.body)
                    .foregroundColor(Color.Weight_SecondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.Weight_InfoBox)
                    .cornerRadius(15)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 20)

                // MARK: - Next Button (สีเปลี่ยนเป็นน้ำตาลเทา)
                Button(action: {
                    Task {
                        // 1. อัปเดตค่า local
                        userProfile.weight = Double(currentWeight)
                            
                        // 2. สั่งบันทึกและ "รอ" จนกว่าจะเสร็จ (await)
                        await userProfile.saveToSupabase()
                            
                        print("Saved weight: \(currentWeight)")
                            
                        // 3. เมื่อเสร็จแล้วค่อยเปลี่ยนหน้า
                        // ต้องสั่ง UI update บน Main Thread
                        await MainActor.run {
                            isgotoBMIView = true
                            }
                        }
                }) {
                    Text("ถัดไป")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.Weight_NextButton) // เปลี่ยนจาก .black
                        .cornerRadius(15)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)

                // MARK: - Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index == currentPage ? Color.Weight_PageIndicatorActive : Color.Weight_PageIndicatorInactive)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isgotoBMIView) { // 👈 เปลี่ยนเป็น navigationDestination
                    BMIView()
                }
                .onAppear {
                    // โหลดค่าจาก UserProfile (ถ้ามี)
                    if userProfile.weight > 0 {
                        currentWeight = Int(userProfile.weight)
                    }
                }
    }
}



// MARK: - Preview ✔ (แก้แล้วเฉพาะ Preview)
struct WeightView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WeightView()
                .environmentObject(UserProfile()) // ✅ ใส่ตัวอย่าง UserProfile สำหรับ Preview
        }
    }
}
