//
//  LoginView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    // MARK: - Properties
    @EnvironmentObject var authManager: AuthManager
    
    @State private var email = ""
    @State private var password = ""
    
    // Navigation & States
    @State private var navigateToProfile = false
    @State private var showRegister = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        // ใช้ NavigationStack จาก Parent (หรือใส่ตรงนี้ถ้าเป็น Root view)
        ZStack {
            // Background
            Color(red: 0.98, green: 0.97, blue: 0.91) // ครีมอ่อน
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // MARK: - Logo
                ZStack {
                    Circle()
                        .fill(Color(red: 0.82, green: 0.84, blue: 0.36))
                        .frame(width: 100, height: 100)
                    
                    Image("Smile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 130)
                        .clipShape(Circle())
                    
                }
                .padding(.top, 40)
                
                // MARK: - Main Card
                VStack(spacing: 20) {
                    
                    Text("Sign in") // เปลี่ยนเป็น Sign in
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.black)
                    
                    // Email
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Email")
                            .font(.caption).fontWeight(.semibold)
                        
                        TextField("Your email", text: $email)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    // Password
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Password")
                            .font(.caption).fontWeight(.semibold)
                        
                        SecureField("Enter your password", text: $password)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Error Message
                    if let error = authManager.errorMessage ?? errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    // MARK: - Sign In Button
                    Button(action: {
                        handleSignIn()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sign in")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(email.isEmpty || password.isEmpty ? Color.gray : Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .shadow(radius: 3)
                    }
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                    .padding(.top, 10)
                    
                    // MARK: - Divider
                    HStack {
                        Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
                        Text("Or Sign in with")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
                    }
                    .padding(.vertical, 10)
                    
                    // MARK: - Social Buttons
                    HStack(spacing: 16) {
                        // Facebook (Placeholder)
                        socialButton(image: "facebook", color: Color(hex: "1877F2")) {
                            // Action
                        }
                        
                        // Google
                        socialButton(image: "google", color: Color.white) {
                            Task { await authManager.signInWithGoogle() }
                        }
                        
                        // Apple
                        // Apple requires a specific button class, so we customize it to match the square design
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(Color.black)
//                                .frame(width: 80, height: 50)
//                                .shadow(radius: 1)
//                            
//                            SignInWithAppleButton(.signIn) { request in
//                                request.requestedScopes = [.email, .fullName]
//                            } onCompletion: { result in
//                                handleAppleSignIn(result)
//                            }
//                            .signInWithAppleButtonStyle(.white) // Icon color
//                            .labelStyle(.iconOnly) // Show only icon
//                            .frame(width: 50, height: 50) // Limit hit area mostly to box
//                            .blendMode(.destinationOver) // Hack to hide default button background if needed, or just rely on frame
//                        }
//                        .frame(width: 80, height: 50)
//                        .mask(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // MARK: - Footer (Go to Register)
                    HStack {
                        Text("Don't have an account?") // เปลี่ยนข้อความ
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showRegister = true
                        }) {
                            Text("Sign up")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .underline()
                        }
                    }
                    .padding(.bottom, 15)
                }
                .padding()
                .background(Color.white) // หรือ Color(white: 0.9) ตามชอบ
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        // MARK: - Navigation Handlers
        .navigationDestination(isPresented: $navigateToProfile) {
            Profile() // ไปหน้า Profile
        }
        .navigationDestination(isPresented: $showRegister) {
            RegisterView() // เปิดหน้า Register
        }
    }
    
    // MARK: - Functions
    
    private func handleSignIn() {
        Task {
            isLoading = true
            errorMessage = nil
            
            await authManager.signIn(email: email, password: password)
            
            isLoading = false
            
            if authManager.isAuthenticated {
                navigateToProfile = true
            }
        }
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let identityToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: identityToken, encoding: .utf8) else {
                    authManager.errorMessage = "Failed to get Apple ID token"
                    return
                }
                
                let nonce = UUID().uuidString // ใน Production ควรใช้ Nonce จริงๆ
                
                Task {
                    await authManager.signInWithApple(idToken: idTokenString, nonce: nonce)
                    if authManager.isAuthenticated {
                        navigateToProfile = true
                    }
                }
            }
        case .failure(let error):
            authManager.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Subviews
    
    private func socialButton(image: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
                    .frame(width: 80, height: 50)
                    .shadow(radius: 1)
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
//                    
//                    Image(systemName: "applelogo")
//                    
//                        .foregroundColor(.white)
//                    
//                        .font(.system(size: 28))
                    
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthManager())
    }
}
