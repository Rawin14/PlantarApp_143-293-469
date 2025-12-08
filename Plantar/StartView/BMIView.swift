//
// BMIView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

// MARK: - BMI Category Enum
enum BMICategory {
    case underweight
    case normal
    case overweight
    case obese
    
    var title: String {
        switch self {
        case .underweight: return "น้ำหนักต่ำกว่าเกณฑ์"
        case .normal: return "น้ำหนักปกติ"
        case .overweight: return "น้ำหนักเกิน"
        case .obese: return "อ้วน"
        }
    }
    
    var color: Color {
        switch self {
        case .underweight: return Color(red: 173/255, green: 216/255, blue: 230/255) // ฟ้า
        case .normal: return Color(red: 172/255, green: 187/255, blue: 98/255) // เขียว
        case .overweight: return Color(red: 255/255, green: 182/255, blue: 193/255) // ชมพู
        case .obese: return Color.red.opacity(0.8) // แดง
        }
    }
    
    var description: String {
        switch self {
        case .underweight:
            return "คุณมีน้ำหนักต่ำกว่าเกณฑ์มาตรฐาน ควรรับประทานอาหารที่มีประโยชน์และออกกำลังกายเพิ่มมวลกล้ามเนื้อ"
        case .normal:
            return "ยินดีด้วย! คุณมีน้ำหนักที่เหมาะสมกับส่วนสูง รักษาสุขภาพให้ดีต่อไป"
        case .overweight:
            return "คุณมีน้ำหนักเกินเล็กน้อย ควรควบคุมอาหารและออกกำลังกายสม่ำเสมอ"
        case .obese:
            return "คุณมีน้ำหนักเกินมาตรฐาน ควรปรึกษาแพทย์เพื่อวางแผนการลดน้ำหนักที่เหมาะสม"
        }
    }
}

struct BMIView: View {
    // MARK: - Properties
    @EnvironmentObject var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    @State private var navigateToNext = false
    @State private var showSaveAnimation = false
    
    // MARK: - Custom Colors
    let backgroundColor = Color(red: 247/255, green: 246/255, blue: 236/255)
    let cardBackground = Color.white
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255)
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
    let buttonColor = Color(red: 94/255, green: 84/255, blue: 68/255)
    let textColor = Color(red: 100/255, green: 100/255, blue: 100/255)
    
    // MARK: - Computed Properties
    var bmiValue: Double {
        userProfile.calculateBMI()
    }
    
    var bmiCategory: BMICategory {
        switch bmiValue {
        case ..<18.5: return .underweight
        case 18.5..<25.0: return .normal
        case 25.0..<30.0: return .overweight
        default: return .obese
        }
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Header
                    Text("Your BMI Result")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 60)
                        .padding(.bottom, 30)
                    
                    // MARK: - BMI Circle Display
                    ZStack {
                        // Background Circle
                        Circle()
                            .stroke(
                                bmiCategory.color.opacity(0.2),
                                lineWidth: 20
                            )
                            .frame(width: 220, height: 220)
                        
                        // Progress Circle
                        Circle()
                            .trim(from: 0, to: min(bmiValue / 40, 1.0))
                            .stroke(
                                bmiCategory.color,
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 220, height: 220)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.0), value: bmiValue)
                        
                        // BMI Value
                        VStack(spacing: 8) {
                            Text(String(format: "%.1f", bmiValue))
                                .font(.system(size: 56, weight: .bold))
                                .foregroundColor(bmiCategory.color)
                            
                            Text("BMI")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(textColor)
                        }
                    }
                    .padding(.vertical, 40)
                    
                    // MARK: - Category Badge
                    Text(bmiCategory.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(bmiCategory.color)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(bmiCategory.color.opacity(0.15))
                        )
                        .padding(.bottom, 30)
                    
                    // MARK: - User Info Card
                    VStack(spacing: 20) {
                        HStack(spacing: 30) {
                            // Age
                            VStack(spacing: 8) {
                                Text("\(userProfile.age)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(primaryColor)
                                Text("Years")
                                    .font(.system(size: 14))
                                    .foregroundColor(textColor)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                            )
                            
                            // Height
                            VStack(spacing: 8) {
                                Text("\(Int(userProfile.height))")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(primaryColor)
                                Text("CM")
                                    .font(.system(size: 14))
                                    .foregroundColor(textColor)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                            )
                            
                            // Weight
                            VStack(spacing: 8) {
                                Text("\(Int(userProfile.weight))")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(primaryColor)
                                Text("KG")
                                    .font(.system(size: 14))
                                    .foregroundColor(textColor)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 30)
                    
                    // MARK: - Description Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundColor(bmiCategory.color)
                            
                            Text("คำแนะนำ")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Text(bmiCategory.description)
                            .font(.system(size: 16))
                            .foregroundColor(textColor)
                            .lineSpacing(6)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    
                    // MARK: - BMI Standard Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("มาตรฐานค่า BMI")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            BMIRangeRow(
                                title: "น้ำหนักต่ำกว่าเกณฑ์",
                                range: "< 18.5",
                                color: Color(red: 173/255, green: 216/255, blue: 230/255),
                                isHighlighted: bmiValue < 18.5
                            )
                            
                            BMIRangeRow(
                                title: "น้ำหนักปกติ",
                                range: "18.5 - 24.9",
                                color: Color(red: 172/255, green: 187/255, blue: 98/255),
                                isHighlighted: bmiValue >= 18.5 && bmiValue < 25.0
                            )
                            
                            BMIRangeRow(
                                title: "น้ำหนักเกิน",
                                range: "25.0 - 29.9",
                                color: Color(red: 255/255, green: 182/255, blue: 193/255),
                                isHighlighted: bmiValue >= 25.0 && bmiValue < 30.0
                            )
                            
                            BMIRangeRow(
                                title: "อ้วน",
                                range: "≥ 30.0",
                                color: Color.red.opacity(0.8),
                                isHighlighted: bmiValue >= 30.0
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                    
                    // MARK: - Next Button
                    Button(action: {
                        showSaveAnimation = true
                        
                        Task {
                            await userProfile.saveToSupabase()
                            
                            print("BMI: \(String(format: "%.1f", bmiValue))")
                            print("Category: \(bmiCategory.title)")
                            
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            navigateToNext = true
                        }
                    }) {
                        HStack {
                            if showSaveAnimation {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                            }
                            
                            Text(showSaveAnimation ? "Saving..." : "Continue")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(buttonColor)
                        )
                    }
                    .disabled(showSaveAnimation)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<6) { index in
                            Circle()
                                .fill(index == 3 ? Color.black : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToNext) {
            EvaluateView()
        }
        .onAppear {
            Task {
                await userProfile.loadFromSupabase()
            }
        }
    }
}

// MARK: - BMI Range Row Component
struct BMIRangeRow: View {
    let title: String
    let range: String
    let color: Color
    let isHighlighted: Bool
    
    var body: some View {
        HStack {
            // Color Indicator
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
                .frame(width: 8, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: isHighlighted ? .bold : .medium))
                    .foregroundColor(.black)
                
                Text(range)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isHighlighted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(color)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isHighlighted ? color.opacity(0.1) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isHighlighted ? color : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BMIView()
            .environmentObject({
                let profile = UserProfile()
                profile.nickname = "John Doe"
                profile.age = 25
                profile.height = 170
                profile.weight = 65
                return profile
            }())
    }
}
