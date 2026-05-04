//
// AgeView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 18/10/2568 BE.
//

import SwiftUI

// MARK: - AgeView Colors
extension Color {
    // 🎨 **Age-Specific Colors** (Must be unique)
    static let Age_Background = Color(red: 247/255, green: 246/255, blue: 236/255) // Main Background (Light Cream)
    static let Age_Primary = Color(red: 139/255, green: 122/255, blue: 184/255)  // Main Purple (for numbers, ruler marks)
    static let Age_Accent = Color(red: 172/255, green: 187/255, blue: 98/255)    // Light Green (for top circle, if used)
    static let Age_SecondaryText = Color(red: 100/255, green: 100/255, blue: 100/255) // Grey for text
    static let Age_InfoBox = Color(red: 220/255, green: 220/255, blue: 220/255) // Info box background color
    static let Age_PageIndicatorActive = Color.black // Active Page Indicator dot color
    static let Age_PageIndicatorInactive = Color(red: 200/255, green: 200/255, blue: 200/255) // Inactive Page Indicator dot color
    static let Age_ButtonBackground = Color.white // สีพื้นหลังปุ่ม +/-
    static let Age_NextButton = Color(red: 94/255, green: 84/255, blue: 68/255) // สีปุ่ม Next (น้ำตาลเทา)
}

struct AgeView: View {
    // 👤 Initial Age
    @State private var currentAge: Int = 25 // Changed initial value
    // 📍 For Page Indicator at the bottom
    @State private var currentPage: Int = 0 // Adjusted for a typical starting page
    // 🔄 Navigation
    @State private var navigateToHeight = false
    @EnvironmentObject var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    // **Constants for Age Range**
    let minAge: Double = 1.0
    let maxAge: Double = 100.0
    let ageStep: Double = 1.0
    
    var body: some View {
        ZStack {
            Color.Age_Background.ignoresSafeArea()
            
            VStack {
                // MARK: - Header (Back Button + Title)
                HStack {
                    // Back Button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                    }
                    .padding(.leading, 10)
                    .onTapGesture {
                        print("Back button tapped")
                    }
                    
                    Spacer()
                    
                    // Status Bar (Placeholder)
                    Spacer()
                    
                    HStack(spacing: 4) {
                    }
                    .font(.system(size: 15, weight: .medium))
                    .padding(.trailing, 10)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // MARK: - Title (Centered)
                Text("โปรดระบุอายุ ?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                
                Spacer()
                
                // MARK: - Current Age Display
                HStack(alignment: .bottom, spacing: 5) {
                    Text("\(currentAge)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(Color.Age_Primary)
                    
                    Text("Years")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(Color.Age_Primary.opacity(0.8))
                        .offset(y: -10)
                }
                .padding(.vertical, 30)
                
                // MARK: - Ruler/Slider
                AgeRuler(selectedAge: $currentAge)
                    .frame(height: 100)
                    .padding(.vertical, 20)
                
                // MARK: - Plus/Minus Buttons
                HStack(spacing: 40) {
                    // ปุ่มลด (-)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentAge > Int(minAge) {
                                currentAge -= Int(ageStep)
                            }
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(currentAge <= Int(minAge) ? Color.Age_SecondaryText.opacity(0.3) : Color.Age_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Age_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentAge <= Int(minAge))
                    
                    // ปุ่มเพิ่ม (+)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentAge < Int(maxAge) {
                                currentAge += Int(ageStep)
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(currentAge >= Int(maxAge) ? Color.Age_SecondaryText.opacity(0.3) : Color.Age_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Age_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentAge >= Int(maxAge))
                }
                .padding(.top, 10)
                
                Spacer()
                
                // MARK: - Info Box
                Text("ระบุน้ำหนักปัจจุบันเพื่อคำนวณค่า BMI และประเมินสุขภาพของคุณ")
                    .font(.body)
                    .foregroundColor(Color.Age_SecondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.Age_InfoBox)
                    .cornerRadius(15)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 20)
                
                // MARK: - Next Button
                Button(action: {
                    print("Next button tapped. Final Age: \(currentAge)")
                    userProfile.age = Int(currentAge)
                    Task {
                        await userProfile.saveToSupabase()
                    }
                    navigateToHeight = true
                }) {
                    Text("ถัดไป")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.Age_NextButton)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)
                
                // MARK: - Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index == currentPage ? Color.Age_PageIndicatorActive : Color.Age_PageIndicatorInactive)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToHeight) {
            HeightView()
        }
        .onAppear {
            // โหลดค่าจาก UserProfile (ถ้ามี)
            if userProfile.age > 0 {
                currentAge = Int(Double(userProfile.age))
            }
        }
    }
}

// MARK: - Custom Views for AgeView
struct AgeRuler: View {
    @Binding var selectedAge: Int
    let range = Array(1...100)

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 20))
                .foregroundColor(Color.Age_Primary)
                .offset(y: -10)
                .zIndex(1)

            RulerScrollView(
                selectedRuler: $selectedAge,
                range: range,
                themeColor: Color.Age_Primary
            )
            .frame(height: 110)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black, location: 0.28),
                        .init(color: .black, location: 0.72),
                        .init(color: .clear, location: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AgeView()
            .environmentObject(UserProfile()) // 👈 เพิ่ม UserProfile ใน Preview
    }
}
