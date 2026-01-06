//
//  ProfileView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

struct ProfileView: View {
    // MARK: - Environment & State
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var authManager: AuthManager
    
    // UI State
    @State private var showImageSelector = false
    @State private var selectedImage: String = "Female" // ใช้เริ่มต้น (ควรเซฟลง UserProfile จริงๆ)
    @State private var isEditingName = false
    @State private var editedName = ""
    
    // MARK: - Colors
    let backgroundColor = Color(red: 247/255, green: 246/255, blue: 236/255) // Cream
    let cardBackground = Color.white
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255)    // Purple
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)     // Green
    let buttonColor = Color(red: 94/255, green: 84/255, blue: 68/255)       // Brown
    let textColor = Color(red: 100/255, green: 100/255, blue: 100/255)
    
    // Assets Images (ต้องมีชื่อรูปตามนี้ใน Assets)
    let availableImages = ["Female", "Male", "profile1", "profile2", "profile3", "PlantarMan"]
    
    // MARK: - Computed Properties
    var bmiValue: Double { userProfile.calculateBMI() }
    
    var bmiCategory: String {
        switch bmiValue {
        case ..<18.5: return "ผอม"
        case 18.5..<25.0: return "ปกติ"
        case 25.0..<30.0: return "ท้วม"
        default: return "อ้วน"
        }
    }
    
    var bmiColor: Color {
        switch bmiValue {
        case ..<18.5: return primaryColor
        case 18.5..<25.0: return accentColor
        case 25.0..<30.0: return buttonColor.opacity(0.8)
        default: return buttonColor
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 1. Background Layer
            backgroundColor.ignoresSafeArea()
            
            // 2. Main Content Layer
            VStack(spacing: 0) {
                // Top Nav Bar
                HStack {
                    Spacer()
                    Text("โปรไฟล์")
                        .font(.headline)
                        .foregroundColor(buttonColor)
                    Spacer()
                }
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // --- Profile Header Section ---
                        VStack(spacing: 16) {
                            // Profile Image & Edit Button
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(LinearGradient(colors: [primaryColor.opacity(0.3), accentColor.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 140, height: 140)
                                    .overlay(
                                        Image(selectedImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 130, height: 130)
                                            .clipShape(Circle())
                                    )
                                    .overlay(Circle().stroke(primaryColor, lineWidth: 3))
                                
                                Button(action: {
                                    withAnimation { showImageSelector = true }
                                }) {
                                    ZStack {
                                        Circle().fill(accentColor).frame(width: 40, height: 40)
                                        Image(systemName: "camera.fill").foregroundColor(.white).font(.system(size: 16))
                                    }
                                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                                }
                                .offset(x: 5, y: 5)
                            }
                            .padding(.top, 20)
                            
                            // User Name & Edit
                            VStack(spacing: 8) {
                                if isEditingName {
                                    VStack(spacing: 12) {
                                        TextField("ชื่อผู้ใช้", text: $editedName)
                                            .font(.title3)
                                            .multilineTextAlignment(.center)
                                            .padding(8)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                            .frame(maxWidth: 250)
                                        
                                        HStack(spacing: 20) {
                                            Button("ยกเลิก") { isEditingName = false }
                                                .foregroundColor(.red)
                                            
                                            Button("บันทึก") {
                                                Task {
                                                    await userProfile.updateNickname(editedName)
                                                    isEditingName = false
                                                }
                                            }
                                            .fontWeight(.bold)
                                            .foregroundColor(accentColor)
                                        }
                                        .font(.subheadline)
                                    }
                                } else {
                                    HStack(spacing: 8) {
                                        Text(userProfile.nickname.isEmpty ? "ชื่อผู้ใช้" : userProfile.nickname)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(buttonColor)
                                        
                                        Button {
                                            editedName = userProfile.nickname
                                            isEditingName = true
                                        } label: {
                                            Image(systemName: "pencil")
                                                .foregroundColor(accentColor)
                                                .font(.title3)
                                        }
                                    }
                                    
                                    Text(authManager.currentUser?.email ?? "")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // --- Quick Stats (Grid) ---
                        HStack(spacing: 12) {
                            QuickStatCard(icon: "calendar", value: "\(userProfile.age)", label: "ปี", color: primaryColor)
                            QuickStatCard(icon: "ruler", value: "\(Int(userProfile.height))", label: "ซม.", color: accentColor)
                            QuickStatCard(icon: "scalemass", value: "\(Int(userProfile.weight))", label: "กก.", color: buttonColor)
                        }
                        .padding(.horizontal, 20)
                        
                        // --- BMI Card ---
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                ZStack {
                                    Circle().fill(bmiColor.opacity(0.15)).frame(width: 50, height: 50)
                                    Image(systemName: "figure.stand").font(.title2).foregroundColor(bmiColor)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ดัชนีมวลกาย (BMI)")
                                        .font(.headline)
                                        .foregroundColor(buttonColor)
                                    Text(bmiCategory)
                                        .font(.caption)
                                        .foregroundColor(bmiColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(bmiColor.opacity(0.15))
                                        .cornerRadius(12)
                                }
                                Spacer()
                                Text(String(format: "%.1f", bmiValue))
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(bmiColor)
                            }
                            
                            Divider()
                            
                            // BMI Bar
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ช่วงค่ามาตรฐาน: 18.5 - 24.9").font(.caption2).foregroundColor(textColor)
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(LinearGradient(colors: [primaryColor.opacity(0.5), accentColor, buttonColor], startPoint: .leading, endPoint: .trailing))
                                            .frame(height: 10)
                                        
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 18, height: 18)
                                            .overlay(Circle().stroke(bmiColor, lineWidth: 3))
                                            .offset(x: min(max(CGFloat((bmiValue - 15) / 25) * geometry.size.width, 0), geometry.size.width - 18))
                                            .shadow(radius: 2)
                                    }
                                }
                                .frame(height: 18)
                            }
                        }
                        .padding(20)
                        .background(cardBackground)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                        .padding(.horizontal, 20)
                        
                        // --- Menu List ---
                        VStack(spacing: 12) {
                            // Dashboard Link
                            NavigationLink(destination: DashboardView()) {
                                InfoRowCard(icon: "chart.line.uptrend.xyaxis", title: "Dashboard", value: "ดูสถิติ", color: accentColor)
                            }
                            
                            // Logout Button
                            Button {
                                Task {
                                        await authManager.signOut()
                                    
                                    }
                            } label: {
                                InfoRowCard(icon: "rectangle.portrait.and.arrow.right", title: "ออกจากระบบ", value: "", color: .red)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                } // End ScrollView
            } // End Main VStack
            
            // 3. Popup Layer (Overlay)
            if showImageSelector {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showImageSelector = false } }
                    .zIndex(1)
                
                VStack(spacing: 20) {
                    Text("เลือกรูปโปรไฟล์")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(buttonColor)
                        .padding(.top, 10)
                    
                    // ✅ ใช้ ScrollView เพื่อป้องกันรูปล้นจอ
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(availableImages, id: \.self) { imageName in
                                Button(action: {
                                    selectedImage = imageName
                                    // TODO: Save to Supabase here if needed
                                    withAnimation { showImageSelector = false }
                                }) {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(selectedImage == imageName ? accentColor : Color.gray.opacity(0.2), lineWidth: selectedImage == imageName ? 3 : 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    .frame(maxHeight: 350)
                    
                    Button(action: { withAnimation { showImageSelector = false } }) {
                        Text("ยกเลิก")
                            .fontWeight(.medium)
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
                .shadow(radius: 20)
                .padding(.horizontal, 30)
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
            }
            
        } // End ZStack
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // โหลดข้อมูลล่าสุดเมื่อเปิดหน้า
            Task { await userProfile.loadFromSupabase() }
        }
    }
}

// MARK: - Subviews

struct QuickStatCard: View {
    let icon: String, value: String, label: String, color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 50, height: 50)
                Image(systemName: icon).font(.title3).foregroundColor(color)
            }
            Text(value).font(.title2).fontWeight(.bold).foregroundColor(Color(red: 94/255, green: 84/255, blue: 68/255))
            Text(label).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

struct InfoRowCard: View {
    let icon: String, title: String, value: String, color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.15)).frame(width: 50, height: 50)
                Image(systemName: icon).font(.title3).foregroundColor(color)
            }
            Text(title).font(.headline).foregroundColor(Color(red: 94/255, green: 84/255, blue: 68/255))
            Spacer()
            if !value.isEmpty {
                Text(value).font(.subheadline).foregroundColor(.gray)
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ProfileView()
            .environmentObject(UserProfile.shared) // ใช้ Singleton Mock
            .environmentObject(AuthManager.shared)
    }
}
