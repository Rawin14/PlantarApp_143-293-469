//
// ProfileView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

struct ProfileView: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    
    // --- State Variables ---
    @State private var showImagePicker = false
    @State private var selectedImage: String = "Female" // รูปเริ่มต้นจาก Asset
    @State private var showImageSelector = false
    
    // --- User Data (ควรได้มาจาก Data Model จริง) ---
    @State private var userName: String = "จงกั๋วเหริน แทน"
    @State private var age: Int = 25
    @State private var height: Double = 165.0
    @State private var weight: Double = 58.0
    @State private var painLevel: Int = 3 // 1-5
    
    
    // --- Custom Colors (เหลือแค่ 4 สี) ---
    let backgroundColor = Color(red: 247/255, green: 246/255, blue: 236/255) // ครีม
    let cardBackground = Color.white
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // ม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียว
    let buttonColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    let textColor = Color(red: 100/255, green: 100/255, blue: 100/255)
    
    // Available images in Assets
    let availableImages = ["Female", "Male", "profile1", "profile2", "profile3"]
    
    // Computed BMI
    var bmiValue: Double { userProfile.calculateBMI() }
    
    var bmiCategory: String {
        switch bmiValue {
        case ..<18.5: return "ผอม"
        case 18.5..<25.0: return "ปกติ"
        case 25.0..<30.0: return "เกิน"
        default: return "อ้วน"
        }
    }
    
    var bmiColor: Color {
        switch bmiValue {
        case ..<18.5: return primaryColor // ม่วง
        case 18.5..<25.0: return accentColor // เขียว
        case 25.0..<30.0: return buttonColor // น้ำตาล
        default: return buttonColor.opacity(0.8) // น้ำตาลเข้ม
        }
    }
    
    var painLevelColor: Color {
        switch painLevel {
        case 1: return accentColor // เขียว
        case 2: return accentColor.opacity(0.8) // เขียวเข้ม
        case 3: return primaryColor // ม่วง
        case 4, 5: return buttonColor // น้ำตาล
        default: return textColor
        }
    }
    
    var painLevelText: String {
        switch painLevel {
        case 1: return "เล็กน้อย"
        case 2: return "น้อย"
        case 3: return "ปานกลาง"
        case 4: return "มาก"
        case 5: return "มากที่สุด"
        default: return "ไม่ระบุ"
        }
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Top Navigation Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(buttonColor)
                    }
                    Spacer()
                    Text("โปรไฟล์")
                        .font(.headline)
                        .foregroundColor(buttonColor)
                    Spacer()
                    Button(action: {
                        // Edit profile
                    }) {
                        Image(systemName: "pencil")
                            .font(.title3)
                            .foregroundColor(buttonColor)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // MARK: - Profile Picture Section
                        VStack(spacing: 16) {
                            // Profile Image with Edit Button
                            ZStack(alignment: .bottomTrailing) {
                                // Profile Circle
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [primaryColor.opacity(0.3), accentColor.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 140, height: 140)
                                    .overlay(
                                        Image(selectedImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 130, height: 130)
                                            .clipShape(Circle())
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(primaryColor, lineWidth: 3)
                                    )
                                
                                // Edit Button
                                Button(action: {
                                    showImageSelector = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(accentColor)
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16))
                                    }
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                            }
                            .padding(.top, 20)
                            
                            // User Name
                            Text(userProfile.nickname)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(buttonColor)
                            
                            // Member Badge
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(accentColor)
                                    .font(.system(size: 14))
                                Text("สมาชิกพรีเมียม")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(textColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(accentColor.opacity(0.15))
                            )
                        }
                        .padding(.bottom, 10)
                        
                        // MARK: - Quick Stats Grid
                        HStack(spacing: 12) {
                            QuickStatCard(icon: "calendar", value: "\(userProfile.age)", label: "ปี", color: primaryColor)
                            QuickStatCard(icon: "arrow.up", value: "\(Int(userProfile.height))", label: "CM", color: accentColor)
                            QuickStatCard(icon: "scalemass", value: "\(Int(userProfile.weight))", label: "KG", color: buttonColor)
                        }
                        .padding(.horizontal, 20)
                        
                        // MARK: - Pain Level Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(painLevelColor.opacity(0.15))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "bolt.heart.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(painLevelColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ระดับความเจ็บปวด")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(buttonColor)
                                    Text(painLevelText)
                                        .font(.system(size: 14))
                                        .foregroundColor(painLevelColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(painLevelColor.opacity(0.15))
                                        .cornerRadius(12)
                                }
                                
                                Spacer()
                                
                                // Pain Level Number
                                Text("\(painLevel)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(painLevelColor)
                            }
                            
                            // Pain Scale Indicator
                            HStack(spacing: 8) {
                                ForEach(1...5, id: \.self) { level in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(level <= painLevel ? painLevelColor : Color.gray.opacity(0.2))
                                        .frame(height: 8)
                                }
                            }
                        }
                        .padding(20)
                        .background(cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        
                        // MARK: - BMI Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(bmiColor.opacity(0.15))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "figure.stand")
                                        .font(.system(size: 24))
                                        .foregroundColor(bmiColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ดัชนีมวลกาย (BMI)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(buttonColor)
                                    Text(bmiCategory)
                                        .font(.system(size: 14))
                                        .foregroundColor(bmiColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(bmiColor.opacity(0.15))
                                        .cornerRadius(12)
                                }
                                
                                Spacer()
                                
                                // BMI Value
                                Text(String(format: "%.1f", bmiValue))
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(bmiColor)
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.2))
                            
                            // BMI Progress Bar
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ช่วงค่ามาตรฐาน: 18.5 - 24.9")
                                    .font(.system(size: 12))
                                    .foregroundColor(textColor)
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // Background gradient (ใช้ 4 สี)
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        primaryColor.opacity(0.5), // ม่วง (ผอม)
                                                        accentColor, // เขียว (ปกติ)
                                                        buttonColor.opacity(0.7), // น้ำตาล (เกิน)
                                                        buttonColor // น้ำตาลเข้ม (อ้วน)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(height: 12)
                                        
                                        // Indicator
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 20, height: 20)
                                            .overlay(
                                                Circle()
                                                    .stroke(bmiColor, lineWidth: 3)
                                            )
                                            .offset(x: min(max(CGFloat((bmiValue - 15) / 25) * geometry.size.width, 0), geometry.size.width - 20))
                                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    }
                                }
                                .frame(height: 20)
                            }
                        }
                        .padding(20)
                        .background(cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        
                        // MARK: - Additional Info Cards
                        VStack(spacing: 12) {
                            InfoRowCard(
                                icon: "heart.text.square.fill",
                                title: "ประวัติสุขภาพ",
                                value: "ดูรายละเอียด",
                                color: primaryColor
                            )
                            
                            InfoRowCard(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "ความคืบหน้า",
                                value: "ดู Dashboard",
                                color: accentColor
                            )
                            
                            InfoRowCard(
                                icon: "gearshape.fill",
                                title: "ตั้งค่า",
                                value: "แก้ไขข้อมูล",
                                color: buttonColor
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            
            // MARK: - Image Selector Sheet
            if showImageSelector {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showImageSelector = false
                        }
                    }
                
                VStack(spacing: 20) {
                    Text("เลือกรูปโปรไฟล์")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(buttonColor)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(availableImages, id: \.self) { imageName in
                            Button(action: {
                                selectedImage = imageName
                                withAnimation {
                                    showImageSelector = false
                                }
                            }) {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                selectedImage == imageName ? accentColor : Color.gray.opacity(0.3),
                                                lineWidth: selectedImage == imageName ? 3 : 1
                                            )
                                    )
                            }
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            showImageSelector = false
                        }
                    }) {
                        Text("ยกเลิก")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(buttonColor)
                            .cornerRadius(12)
                    }
                }
                .padding(24)
                .background(cardBackground)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 40)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task { await userProfile.loadFromSupabase() }
        }
    }
}

// MARK: - Quick Stat Card Component
struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(red: 94/255, green: 84/255, blue: 68/255))
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color(red: 100/255, green: 100/255, blue: 100/255))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Info Row Card Component
struct InfoRowCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 94/255, green: 84/255, blue: 68/255))
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 100/255, green: 100/255, blue: 100/255))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 100/255, green: 100/255, blue: 100/255))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ProfileView()
    }
}
