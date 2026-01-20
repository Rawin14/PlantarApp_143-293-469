////
////  LoginView.swift
////  Plantar
////
////  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
////
//
//import SwiftUI
//import AuthenticationServices
//
//struct LoginView: View {
//    // MARK: - Properties
//    @EnvironmentObject var authManager: AuthManager
//    
//    @State private var email = ""
//    @State private var password = ""
//    
//    // Navigation & States
//    @State private var navigateToProfile = false
//    @State private var showRegister = false
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//
//    var body: some View {
//        // ใช้ NavigationStack จาก Parent (หรือใส่ตรงนี้ถ้าเป็น Root view)
//        ZStack {
//            // Background
//            Color(red: 0.98, green: 0.97, blue: 0.91) // ครีมอ่อน
//                .ignoresSafeArea()
//            
//            VStack(spacing: 20) {
//                
//                // MARK: - Logo
//                ZStack {
//                    Circle()
//                        .fill(Color(red: 0.82, green: 0.84, blue: 0.36))
//                        .frame(width: 100, height: 100)
//                    
//                    Image("Smile")
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 130, height: 130)
//                        .clipShape(Circle())
//                    
//                }
//                .padding(.top, 40)
//                
//                // MARK: - Main Card
//                VStack(spacing: 20) {
//                    
//                    Text("Sign in") // เปลี่ยนเป็น Sign in
//                        .font(.system(size: 26, weight: .medium))
//                        .foregroundColor(.black)
//                    
//                    // Email
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text("Email")
//                            .font(.caption).fontWeight(.semibold)
//                        
//                        TextField("Your email", text: $email)
//                            .padding(12)
//                            .background(Color.white)
//                            .cornerRadius(8)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                            )
//                            .keyboardType(.emailAddress)
//                            .autocapitalization(.none)
//                    }
//                    
//                    // Password
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text("Password")
//                            .font(.caption).fontWeight(.semibold)
//                        
//                        SecureField("Enter your password", text: $password)
//                            .padding(12)
//                            .background(Color.white)
//                            .cornerRadius(8)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                            )
//                    }
//                    
//                    // Error Message
//                    if let error = authManager.errorMessage ?? errorMessage {
//                        Text(error)
//                            .foregroundColor(.red)
//                            .font(.caption)
//                            .multilineTextAlignment(.center)
//                    }
//                    
//                    // MARK: - Sign In Button
//                    Button(action: {
//                        handleSignIn()
//                    }) {
//                        HStack {
//                            if isLoading {
//                                ProgressView().tint(.white)
//                            } else {
//                                Text("Sign in")
//                                    .fontWeight(.semibold)
//                            }
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(email.isEmpty || password.isEmpty ? Color.gray : Color.black)
//                        .foregroundColor(.white)
//                        .cornerRadius(30)
//                        .shadow(radius: 3)
//                    }
//                    .disabled(email.isEmpty || password.isEmpty || isLoading)
//                    .padding(.top, 10)
//                    
//                    // MARK: - Divider
//                    HStack {
//                        Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
//                        Text("Or Sign in with")
//                            .font(.footnote)
//                            .foregroundColor(.gray)
//                        Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
//                    }
//                    .padding(.vertical, 10)
//                    
//                    // MARK: - Social Buttons
//                    HStack(spacing: 16) {
//                        // Facebook (Placeholder)
//                        socialButton(image: "facebook", color: Color(hex: "1877F2")) {
//                            // Action
//                        }
//                        
//                        // Google
//                        socialButton(image: "google", color: Color.white) {
//                            Task { await authManager.signInWithGoogle() }
//                        }
//                        
//                        // Apple
//                        // Apple requires a specific button class, so we customize it to match the square design
////                        ZStack {
////                            RoundedRectangle(cornerRadius: 10)
////                                .fill(Color.black)
////                                .frame(width: 80, height: 50)
////                                .shadow(radius: 1)
////                            
////                            SignInWithAppleButton(.signIn) { request in
////                                request.requestedScopes = [.email, .fullName]
////                            } onCompletion: { result in
////                                handleAppleSignIn(result)
////                            }
////                            .signInWithAppleButtonStyle(.white) // Icon color
////                            .labelStyle(.iconOnly) // Show only icon
////                            .frame(width: 50, height: 50) // Limit hit area mostly to box
////                            .blendMode(.destinationOver) // Hack to hide default button background if needed, or just rely on frame
////                        }
////                        .frame(width: 80, height: 50)
////                        .mask(RoundedRectangle(cornerRadius: 10))
//                    }
//                    
//                    // MARK: - Footer (Go to Register)
//                    HStack {
//                        Text("Don't have an account?") // เปลี่ยนข้อความ
//                            .font(.footnote)
//                            .foregroundColor(.gray)
//                        
//                        Button(action: {
//                            showRegister = true
//                        }) {
//                            Text("Sign up")
//                                .font(.footnote)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.black)
//                                .underline()
//                        }
//                    }
//                    .padding(.bottom, 15)
//                }
//                .padding()
//                .background(Color.white) // หรือ Color(white: 0.9) ตามชอบ
//                .cornerRadius(30)
//                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                .padding(.horizontal)
//                
//                Spacer()
//            }
//        }
//        // MARK: - Navigation Handlers
//        .navigationDestination(isPresented: $navigateToProfile) {
//            Profile() // ไปหน้า Profile
//        }
//        .navigationDestination(isPresented: $showRegister) {
//            RegisterView() // เปิดหน้า Register
//        }
//    }
//    
//    // MARK: - Functions
//    
//    private func handleSignIn() {
//        Task {
//            isLoading = true
//            errorMessage = nil
//            
//            await authManager.signIn(email: email, password: password)
//            
//            isLoading = false
//            
//            if authManager.isAuthenticated {
//                navigateToProfile = true
//            }
//        }
//    }
//    
//    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
//        switch result {
//        case .success(let authorization):
//            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//                guard let identityToken = appleIDCredential.identityToken,
//                      let idTokenString = String(data: identityToken, encoding: .utf8) else {
//                    authManager.errorMessage = "Failed to get Apple ID token"
//                    return
//                }
//                
//                let nonce = UUID().uuidString // ใน Production ควรใช้ Nonce จริงๆ
//                
//                Task {
//                    await authManager.signInWithApple(idToken: idTokenString, nonce: nonce)
//                    if authManager.isAuthenticated {
//                        navigateToProfile = true
//                    }
//                }
//            }
//        case .failure(let error):
//            authManager.errorMessage = error.localizedDescription
//        }
//    }
//    
//    // MARK: - Subviews
//    
//    private func socialButton(image: String, color: Color, action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(color)
//                    .frame(width: 80, height: 50)
//                    .shadow(radius: 1)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//                    )
//                
//                if image == "facebook" {
//                    
//                    Image("facebook_logo")
//                    
//                        .resizable()
//                    
//                        .scaledToFit()
//                    
//                        .frame(width: 24, height: 24)
//                    
//                } else if image == "google" {
//                    
//                    Image("google_logo") // แนะนำให้นำไอคอน google เข้ามาใน Assets
//                    
//                        .resizable()
//                    
//                        .scaledToFit()
//                    
//                        .frame(width: 24, height: 24)
//                    
//                } else {
////                    
////                    Image(systemName: "applelogo")
////                    
////                        .foregroundColor(.white)
////                    
////                        .font(.system(size: 28))
//                    
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    NavigationStack {
//        LoginView()
//            .environmentObject(AuthManager())
//    }
//}



//
// LoginView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 7/10/2568 BE.
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
    
    // States สำหรับปุ่มแสดง/ซ่อนรหัสผ่าน
    @State private var isPasswordVisible = false
    
    // States สำหรับ Alert
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // States สำหรับ Forgot Password
    @State private var showForgotPasswordAlert = false
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.98, green: 0.97, blue: 0.91)
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
                    
                    Text("Sign in")
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
                        
                        if !email.isEmpty && !isValidEmail(email) {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.caption2)
                                Text("รูปแบบอีเมลไม่ถูกต้อง")
                            }
                            .foregroundColor(.red)
                            .font(.caption2)
                        }
                    }
                    
                    // Password
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Password")
                                .font(.caption).fontWeight(.semibold)
                            
                            Spacer()
                            
                            // ปุ่มลืมรหัสผ่าน
                            Button {
                                showForgotPasswordAlert = true
                            } label: {
                                Text("ลืมรหัสผ่าน?")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        ZStack(alignment: .trailing) {
                            if isPasswordVisible {
                                TextField("Enter your password", text: $password)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Enter your password", text: $password)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                                    .frame(width: 40, height: 40)
                            }
                            .padding(.trailing, 8)
                        }
                        
                        if !password.isEmpty && password.count < 6 {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.caption2)
                                Text("รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร")
                            }
                            .foregroundColor(.orange)
                            .font(.caption2)
                        }
                    }
                    
                    // Error Message
                    if let error = authManager.errorMessage ?? errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                            Text(error)
                        }
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
                        
                        // Google (comment ออกถ้าไม่ใช้)
                         socialButton(image: "google", color: Color.white) {
                             Task { await authManager.signInWithGoogle() }
                         }
                    }
                    
                    // MARK: - Footer
                    HStack {
                        Text("Don't have an account?")
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
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            Profile()
        }
        .navigationDestination(isPresented: $showRegister) {
            RegisterView()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("ตกลง", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("ลืมรหัสผ่าน", isPresented: $showForgotPasswordAlert) {
            Button("ยกเลิก", role: .cancel) { }
            
            Button("ส่งอีเมล") {
                Task {
                    await handleForgotPassword()
                }
            }
        } message: {
            Text("เราจะส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลที่คุณกรอกในช่อง Email ด้านบน\n\nกรุณาตรวจสอบให้แน่ใจว่าอีเมลถูกต้อง")
        }
    }
    
    // MARK: - Functions
    
    private func handleSignIn() {
        if !validateLoginForm() {
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            await authManager.signIn(email: email, password: password)
            
            isLoading = false
            
            if authManager.isAuthenticated {
                alertTitle = "เข้าสู่ระบบสำเร็จ! ✅"
                alertMessage = "ยินดีต้อนรับกลับมา!"
                showAlert = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    navigateToProfile = true
                }
            } else {
                handleLoginError()
            }
        }
    }
    
    private func handleForgotPassword() async {
        guard !email.isEmpty else {
            alertTitle = "ข้อมูลไม่ครบ"
            alertMessage = "กรุณากรอกอีเมลในช่อง Email ก่อนกด 'ลืมรหัสผ่าน'"
            showAlert = true
            return
        }
        
        guard isValidEmail(email) else {
            alertTitle = "อีเมลไม่ถูกต้อง"
            alertMessage = "กรุณากรอกอีเมลให้ถูกต้อง"
            showAlert = true
            return
        }
        
        await authManager.sendPasswordResetEmail(email: email)
        
        alertTitle = "ส่งอีเมลสำเร็จ ✅"
        alertMessage = "เราได้ส่งลิงก์รีเซ็ตรหัสผ่านไปที่\n\(email)\n\nกรุณาตรวจสอบอีเมลของคุณ"
        showAlert = true
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let identityToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: identityToken, encoding: .utf8) else {
                    authManager.errorMessage = "Failed to get Apple ID token"
                    alertTitle = "เกิดข้อผิดพลาด"
                    alertMessage = "ไม่สามารถเข้าสู่ระบบด้วย Apple ID ได้\nกรุณาลองใหม่อีกครั้ง"
                    showAlert = true
                    return
                }
                
                let nonce = UUID().uuidString
                
                Task {
                    await authManager.signInWithApple(idToken: idTokenString, nonce: nonce)
                    if authManager.isAuthenticated {
                        navigateToProfile = true
                    } else {
                        handleLoginError()
                    }
                }
            }
        case .failure(let error):
            authManager.errorMessage = error.localizedDescription
            alertTitle = "เกิดข้อผิดพลาด"
            alertMessage = "ไม่สามารถเข้าสู่ระบบด้วย Apple ได้\n\(error.localizedDescription)"
            showAlert = true
        }
    }
    
    // MARK: - Validation Functions
    
    private func validateLoginForm() -> Bool {
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            alertTitle = "ข้อมูลไม่ครบ"
            alertMessage = "กรุณากรอกอีเมล"
            showAlert = true
            return false
        }
        
        if !isValidEmail(email) {
            alertTitle = "อีเมลไม่ถูกต้อง"
            alertMessage = "กรุณากรอกอีเมลให้ถูกต้อง\nตัวอย่าง: example@mail.com"
            showAlert = true
            return false
        }
        
        if password.isEmpty {
            alertTitle = "ข้อมูลไม่ครบ"
            alertMessage = "กรุณากรอกรหัสผ่าน"
            showAlert = true
            return false
        }
        
        if password.count < 6 {
            alertTitle = "รหัสผ่านไม่ถูกต้อง"
            alertMessage = "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร"
            showAlert = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func handleLoginError() {
        guard let error = authManager.errorMessage else { return }
        
        if error.contains("wrong-password") || error.contains("invalid-credential") {
            alertTitle = "รหัสผ่านไม่ถูกต้อง ❌"
            alertMessage = "รหัสผ่านที่คุณกรอกไม่ถูกต้อง\nกรุณาตรวจสอบและลองใหม่อีกครั้ง"
        } else if error.contains("user-not-found") || error.contains("invalid-email") {
            alertTitle = "ไม่พบบัญชีผู้ใช้ ❌"
            alertMessage = "ไม่พบอีเมลนี้ในระบบ\nกรุณาตรวจสอบอีเมลหรือสมัครสมาชิกใหม่"
        } else if error.contains("network") || error.contains("connection") {
            alertTitle = "ปัญหาการเชื่อมต่อ 📡"
            alertMessage = "ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้\nกรุณาตรวจสอบการเชื่อมต่อและลองใหม่"
        } else if error.contains("too-many-requests") {
            alertTitle = "พยายามเข้าสู่ระบบมากเกินไป ⏱️"
            alertMessage = "คุณพยายามเข้าสู่ระบบหลายครั้งเกินไป\nกรุณารอสักครู่แล้วลองใหม่อีกครั้ง"
        } else if error.contains("user-disabled") {
            alertTitle = "บัญชีถูกระงับ 🚫"
            alertMessage = "บัญชีของคุณถูกระงับการใช้งาน\nกรุณาติดต่อผู้ดูแลระบบ"
        } else {
            alertTitle = "เข้าสู่ระบบไม่สำเร็จ ❌"
            alertMessage = "เกิดข้อผิดพลาด: \(error)\nกรุณาลองใหม่อีกครั้ง"
        }
        
        showAlert = true
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
                    Image("google_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthManager.shared)
    }
}
