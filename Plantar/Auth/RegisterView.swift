//
//  RegisterView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//

import SwiftUI

struct RegisterView: View {
    // MARK: - Properties
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    // Form Fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    
    // UI States
    @State private var isLoading = false
    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        password.count >= 6
    }
    
    var body: some View {
        ZStack {
            // Background Color
            Color(red: 0.98, green: 0.97, blue: 0.91) // ใช้สีครีมตามธีมแอพ Plantar เดิม หรือใช้ .systemGray6 ตาม UI ใหม่ก็ได้
                .ignoresSafeArea()
            
            ScrollView { // เพิ่ม ScrollView เผื่อหน้าจอเล็ก
                VStack(spacing: 20) {
                    
                    // MARK: - Logo Header
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.82, green: 0.84, blue: 0.36)) // สีเขียวธีมเดิม
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    
                    // MARK: - Main Card
                    VStack(spacing: 20) {
                        
                        Text("Create an account")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.black)
                        
                        // MARK: - Social Buttons
                        HStack(spacing: 16) {
                            // Facebook (Dummy action)
                            socialButton(image: "facebook", color: Color(hex: "1877F2")) {
                                // Action for FB
                            }
                            
                            // Google
                            socialButton(image: "google", color: Color.white) {
                                Task { await authManager.signInWithGoogle() }
                            }
                            
                            // Apple
                            socialButton(image: "applelogo", color: Color.black) {
                                // Apple Sign in flow usually handled via specific request controller
                                // But here represents the trigger
                            }
                        }
                        
                        // Divider
                        HStack {
                            line
                            Text("Or")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            line
                        }
                        
                        // MARK: - Input Fields
                        
                        // Name Row
                        HStack(spacing: 12) {
                            VStack(alignment: .leading) {
                                Text("First Name")
                                    .font(.caption).fontWeight(.semibold)
                                TextField("First Name", text: $firstName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Last Name")
                                    .font(.caption).fontWeight(.semibold)
                                TextField("Last Name", text: $lastName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                        
                        // Email
                        VStack(alignment: .leading) {
                            Text("Email")
                                .font(.caption).fontWeight(.semibold)
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        // Password
                        VStack(alignment: .leading) {
                            Text("Password")
                                .font(.caption).fontWeight(.semibold)
                            SecureField("Enter your password (min 6 chars)", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Error Message
                        if let error = authManager.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        
                        // MARK: - Submit Button
                        Button(action: {
                            handleSignUp()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Create account")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.black : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .shadow(radius: 3)
                        }
                        .disabled(!isFormValid || isLoading)
                        .padding(.top, 10)
                        
                        // MARK: - Privacy Policy Text
                        VStack(spacing: 4) {
                            Text("Signing up for an Application\naccount means you agree to the ")
                                .foregroundColor(.gray) +
                            Text("Privacy Policy").fontWeight(.semibold).foregroundColor(.black) +
                            Text(" and ").foregroundColor(.gray) +
                            Text("Terms of Service").fontWeight(.semibold).foregroundColor(.black)
                        }
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        
                        // MARK: - Sign In Link
                        HStack {
                            Text("Already have an account?")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                dismiss() // กลับไปหน้า Login
                            }) {
                                Text("Sign in")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .underline()
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Functions
    

    // ใน RegisterView.swift

    private func handleSignUp() {
        Task {
            // 1. เริ่มหมุน
            isLoading = true
            
            // ✅ defer: คำสั่งนี้จะทำงานเสมอเมื่อจบฟังก์ชันนี้ (ไม่ว่าจะจบด้วยดี หรือ Error)
            // ช่วยแก้ปัญหา isLoading ค้าง
            defer {
                isLoading = false
            }
            
            let combinedNickname = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            let finalNickname = combinedNickname.isEmpty ? firstName : combinedNickname
            
            // 2. เรียกใช้ AuthManager เพื่อสมัครสมาชิก
            await authManager.signUp(
                email: email,
                password: password,
                nickname: finalNickname
            )
            
            // 3. ตรวจสอบสถานะการล็อกอิน
            if authManager.errorMessage == nil {
                dismiss() // คำสั่งนี้จะพากลับไปหน้า LoginView
            }
        }
    }
    
    // MARK: - Subviews
    
    private var line: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 1)
    }
    
    private func socialButton(image: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
                    .frame(width: 80, height: 50)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                
                if image == "facebook" {
                    
                    Image("facebook_logo")
                    
                        .resizable()
                    
                        .scaledToFit()
                    
                        .frame(width: 24, height: 24)
                    
                } else if image == "google" {
                    
                    Image("google_logo") // แนะนำให้นำไอคอน google เข้ามาใน Assets
                    
                        .resizable()
                    
                        .scaledToFit()
                    
                        .frame(width: 24, height: 24)
                    
                } else {
                    
                    Image(systemName: "applelogo")
                    
                        .foregroundColor(.white)
                    
                        .font(.system(size: 28))
                    
                }
            }
        }
    }
}

// MARK: - Styling Helper
// สร้าง Style ให้ Textfield สวยงามเหมือนกันทุกช่อง
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// Extension for Hex Color (Optional Helper)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthManager())
}
