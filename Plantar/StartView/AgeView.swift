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
    @State private var currentAge: Double = 25.0 // Changed initial value
    // 📍 For Page Indicator at the bottom
    @State private var currentPage: Int = 2 // Adjusted for a typical starting page
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
                Text("What's your Age?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                
                Spacer()
                
                // MARK: - Current Age Display
                HStack(alignment: .bottom, spacing: 5) {
                    Text("\(Int(currentAge.rounded()))")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(Color.Age_Primary)
                    
                    Text("Years")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(Color.Age_Primary.opacity(0.8))
                        .offset(y: -10)
                }
                .padding(.vertical, 30)
                
                // MARK: - Ruler/Slider
                AgeRuler(currentValue: $currentAge, min: minAge, max: maxAge, step: ageStep)
                    .frame(height: 100)
                    .padding(.vertical, 20)
                
                // MARK: - Plus/Minus Buttons
                HStack(spacing: 40) {
                    // ปุ่มลด (-)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentAge > minAge {
                                currentAge -= ageStep
                            }
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(currentAge <= minAge ? Color.Age_SecondaryText.opacity(0.3) : Color.Age_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Age_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentAge <= minAge)
                    
                    // ปุ่มเพิ่ม (+)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentAge < maxAge {
                                currentAge += ageStep
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(currentAge >= maxAge ? Color.Age_SecondaryText.opacity(0.3) : Color.Age_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Age_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentAge >= maxAge)
                }
                .padding(.top, 10)
                
                Spacer()
                
                // MARK: - Info Box
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ornare.")
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
                    print("Next button tapped. Final Age: \(Int(currentAge.rounded()))")
                    userProfile.age = Int(currentAge.rounded())
                    Task {
                        await userProfile.saveToFirebase()
                    }
                    navigateToHeight = true
                }) {
                    Text("Next")
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
                    ForEach(0..<6) { index in
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
                currentAge = Double(userProfile.age)
            }
        }
    }
}

// MARK: - Custom Views for AgeView
// Custom Ruler/Slider
struct AgeRuler: View {
    @Binding var currentValue: Double
    let min: Double
    let max: Double
    let step: Double
    
    // State for dragging
    @State private var dragOffset: CGFloat = 0
    
    // Constant values
    let pixelsPerUnit: CGFloat = 20 // เพิ่มจาก 8 เป็น 20 (ยิ่งมากยิ่งช้า)
    let dragSensitivity: CGFloat = 0.5 // ค่า 0.5 = ช้าลง 50%
    
    var body: some View {
        GeometryReader { geometry in
            let rulerWidth = geometry.size.width
            let centerOffset = rulerWidth / 2
            
            ZStack(alignment: .leading) {
                // Current Value Indicator (Triangle) - Always centered
                VStack {
                    ATriangle()
                        .fill(Color.Age_Primary)
                        .frame(width: 15, height: 10)
                        .rotationEffect(.degrees(180))
                        .offset(y: 40)
                }
                .frame(width: rulerWidth)
                
                // Ruler Line
                Rectangle()
                    .fill(Color.Age_Primary.opacity(0.3))
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                    .offset(y: 10)
                
                // Markings
                HStack(spacing: 0) {
                    ForEach(Int(min)...Int(max), id: \.self) { value in
                        let isMajor = value % 10 == 0 // ทุก 10 ปีเป็นขีดยาว
                        let isMedium = value % 5 == 0 && value % 10 != 0 // ทุก 5 ปีเป็นขีดกลาง
                        
                        VStack(spacing: 0) {
                            // Major mark (long/medium)
                            Rectangle()
                                .fill(Color.Age_Primary.opacity(0.8))
                                .frame(width: 2, height: isMajor ? 25 : (isMedium ? 20 : 15))
                            
                            // Number
                            if isMajor {
                                Text("\(value)")
                                    .font(.caption)
                                    .foregroundColor(.Age_SecondaryText)
                                    .offset(y: 5)
                            }
                        }
                        .frame(width: pixelsPerUnit)
                    }
                }
                .offset(x: centerOffset - ((currentValue - min) * pixelsPerUnit) + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // ใช้ dragSensitivity เพื่อลดความไวในการลาก
                            dragOffset = gesture.translation.width * dragSensitivity
                            let deltaValue = -dragOffset / pixelsPerUnit
                            let newValue = currentValue + deltaValue
                            
                            // ปัดเศษให้ตรงกับ step และจำกัดค่า
                            let snappedValue = (newValue / step).rounded() * step
                            currentValue = Swift.max(min, Swift.min(max, snappedValue))
                        }
                        .onEnded { _ in
                            // รีเซ็ต dragOffset พร้อมแอนิเมชั่นแบบ smooth
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                                dragOffset = 0
                            }
                        }
                )
            }
        }
    }
}

// Custom Shape for Triangle (Indicator)
struct ATriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AgeView()
            .environmentObject(UserProfile()) // 👈 เพิ่ม UserProfile ใน Preview
    }
}
