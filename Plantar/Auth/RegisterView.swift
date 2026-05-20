//
// RegisterView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

struct RegisterView: View {
    
    // MARK: - Properties
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    // Form Fields
    @State private var nickname = ""
    @State private var email = ""
    @State private var password = ""
    
    // UI States
    @State private var isLoading = false
    @State private var isPasswordVisible = false
    @State private var errorMessage: String? // ✅ ตัวแปรเก็บ Error สำหรับโชว์ในกล่องแดง
    
    // Alert States (ใช้สำหรับแจ้งเตือนตอนสำเร็จเท่านั้น)
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var showTerms = false
    @State private var currentNonce: String?
    
    var isFormValid: Bool {
        !nickname.isEmpty &&
        !email.isEmpty &&
        password.count >= 6
    }
    
    // ✅ แปลง Error Message เป็นภาษาไทยสำหรับหน้าสมัครสมาชิก
    var localizedErrorMessage: String? {
        guard let error = errorMessage ?? authManager.errorMessage else { return nil }
        let errorStr = error.lowercased()
        
        if errorStr.contains("กรุณา") || errorStr.contains("รหัสผ่าน") || errorStr.contains("ข้อมูลไม่ครบ") {
            return error // ถ้าเป็นภาษาไทยที่ตั้งไว้ใน Validate ฟอร์ม ให้โชว์เลย
        } else if errorStr.contains("email-already-in-use") || errorStr.contains("user-already-exists") {
            return "อีเมลนี้มีผู้ใช้งานแล้ว กรุณาใช้อีเมลอื่นหรือเข้าสู่ระบบ"
        } else if errorStr.contains("invalid-email") {
            return "รูปแบบอีเมลไม่ถูกต้อง"
        } else if errorStr.contains("weak-password") {
            return "รหัสผ่านอ่อนแอเกินไป กรุณาตั้งให้ยากขึ้น"
        } else if errorStr.contains("network") || errorStr.contains("connection") {
            return "ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้ กรุณาตรวจสอบการเชื่อมต่อ"
        } else if errorStr.contains("nonce") {
            return "ระบบความปลอดภัยล้มเหลว กรุณาลองใหม่อีกครั้ง"
        } else {
            return "การลงทะเบียนไม่สำเร็จ กรุณาลองใหม่อีกครั้ง"
        }
    }
    
    var body: some View {
        ZStack {
            // Background Color
            Color(red: 0.98, green: 0.97, blue: 0.91)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // MARK: - Logo Header
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
                    .padding(.top, 10)
                    
                    // MARK: - Main Card
                    VStack(spacing: 20) {
                        Text("ลงทะเบียนสร้างบัญชี")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.black)
                        
                        // MARK: - Social Buttons
                        VStack(spacing: 16) {
                            // ปุ่ม Google
                            Button(action: {
                                Task { await authManager.signInWithGoogle() }
                            }) {
                                HStack(spacing: 12) {
                                    Image("google_logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                    
                                    Text("ลงชื่อใช้งานด้วย Google")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            .padding(.horizontal, 24)
                            
                            // ปุ่ม Apple
                            SignInWithAppleButton(.signUp) { request in
                                request.requestedScopes = [.email, .fullName]
                                let nonce = randomNonceString()
                                currentNonce = nonce
                                request.nonce = sha256(nonce)
                            } onCompletion: { result in
                                handleAppleSignIn(result)
                            }
                            .signInWithAppleButtonStyle(.black)
                            .frame(height: 52)
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                        }
                        
                        // Divider
                        HStack {
                            line
                            Text("หรือ")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            line
                        }
                        
                        // MARK: - Input Fields
                        
                        // Nickname Row
                        VStack(alignment: .leading) {
                            Text("ชื่อ")
                                .font(.caption).fontWeight(.semibold)
                            TextField("กรอกนามแฝงของคุณ", text: $nickname)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.words)
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: 4) {
                            Text("อีเมล")
                                .font(.caption).fontWeight(.semibold)
                            TextField("กรอกอีเมล@gmail.com", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            if !email.isEmpty && !isValidEmail(email) {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.caption2)
                                    Text("กรุณากรอกอีเมลให้ถูกต้อง (เช่น example@mail.com)")
                                }
                                .foregroundColor(.red)
                                .font(.caption2)
                            }
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: 4) {
                            Text("รหัสผ่าน")
                                .font(.caption).fontWeight(.semibold)
                            
                            ZStack(alignment: .trailing) {
                                if isPasswordVisible {
                                    TextField("กรอกรหัสผ่าน (อย่างน้อย 6 ตัวอักษร)", text: $password)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .autocapitalization(.none)
                                } else {
                                    SecureField("กรอกรหัสผ่าน (อย่างน้อย 6 ตัวอักษร)", text: $password)
                                        .textFieldStyle(CustomTextFieldStyle())
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
                            
                            // แสดงคำแนะนำถ้ารหัสผ่านไม่ถึง 6 ตัว
                            if !password.isEmpty && password.count < 6 {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.caption2)
                                    Text("รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร (ปัจจุบัน: \(password.count) ตัว)")
                                }
                                .foregroundColor(.red)
                                .font(.caption2)
                            }
                            
                            // แสดงความแข็งแกร่งของรหัสผ่าน
                            if password.count >= 6 {
                                HStack(spacing: 4) {
                                    Image(systemName: passwordStrength().icon)
                                        .font(.caption2)
                                    Text("ความปลอดภัย: \(passwordStrength().text)")
                                }
                                .foregroundColor(passwordStrength().color)
                                .font(.caption2)
                            }
                        }
                        
                        // MARK: - 🚨 Error Message Box 🚨
                        if let errorText = localizedErrorMessage {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 16))
                                    .padding(.top, 2)
                                
                                Text(errorText)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                            .animation(.easeInOut, value: localizedErrorMessage)
                        }
                        
                        // MARK: - Submit Button
                        Button(action: {
                            handleSignUp()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("สร้างบัญชี")
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
                        HStack(spacing: 0) {
                            Text("นโยบายส่วนตัว")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .onTapGesture {
                                    showTerms = true
                                }

                            Text(" และ ")
                                .foregroundColor(.gray)

                            Text("เงื่อนไขการให้บริการ")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .onTapGesture {
                                    showTerms = true
                                }
                        }
                        .sheet(isPresented: $showTerms) {
                            TermsView()
                        }
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        
                        // MARK: - Sign In Link
                        HStack {
                            Text("คุณมีบัญชีเรียบร้อยแล้ว?")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Button(action: {
                                dismiss()
                            }) {
                                Text("เข้าสู่ระบบ")
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
        // MARK: - Alert สำหรับแจ้งเตือนสมัครสำเร็จเท่านั้น
        .alert(alertTitle, isPresented: $showAlert) {
            Button("ตกลง", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Functions
    
    private func handleSignUp() {
        // รีเซ็ต Error ก่อนเริ่มทำงาน
        errorMessage = nil
        authManager.errorMessage = nil
        
        if !validateForm() {
            return
        }
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            let combinedNickname = "\(nickname)".trimmingCharacters(in: .whitespaces)
            let finalNickname = combinedNickname.isEmpty ? nickname : combinedNickname
            
            await authManager.signUp(
                email: email,
                password: password,
                nickname: finalNickname
            )
            
            // ถ้าสำเร็จ (ไม่มี Error) ให้เด้ง Alert ยินดีต้อนรับแล้วปิดหน้าต่าง
            if authManager.isAuthenticated {
                alertTitle = "สำเร็จ! ✅"
                alertMessage = "สมัครสมาชิกเรียบร้อยแล้ว\nยินดีต้อนรับสู่ Plantar!"
                showAlert = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Validation Functions
    private func validateForm() -> Bool {
        if nickname.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "กรุณากรอกชื่อ (นามแฝง)"
            return false
        }
        
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "กรุณากรอกอีเมล"
            return false
        }
        
        if !isValidEmail(email) {
            errorMessage = "กรุณากรอกรูปแบบอีเมลให้ถูกต้อง (เช่น example@mail.com)"
            return false
        }
        
        if password.isEmpty {
            errorMessage = "กรุณากรอกรหัสผ่าน"
            return false
        }
        
        if password.count < 6 {
            errorMessage = "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร"
            return false
        }
        
        if !isStrongPassword(password) {
            errorMessage = "รหัสผ่านไม่ปลอดภัย แนะนำให้ใช้ตัวอักษรภาษาอังกฤษผสมตัวเลข"
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isStrongPassword(_ password: String) -> Bool {
        let minLength = password.count >= 8
        let hasLetters = password.rangeOfCharacter(from: .letters) != nil
        let hasNumbers = password.rangeOfCharacter(from: .decimalDigits) != nil
        return minLength && hasLetters && hasNumbers
    }
    
    private func passwordStrength() -> (text: String, color: Color, icon: String) {
        if password.count < 6 {
            return ("อ่อนแอ", .red, "xmark.shield.fill")
        } else if password.count < 8 {
            return ("ปานกลาง", .orange, "shield.fill")
        } else if isStrongPassword(password) {
            return ("แข็งแกร่ง", .green, "checkmark.shield.fill")
        } else {
            return ("ปานกลาง", .orange, "shield.fill")
        }
    }
    
    // MARK: - Apple Sign In
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        errorMessage = nil // รีเซ็ต error
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let identityToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: identityToken, encoding: .utf8) else {
                    errorMessage = "ไม่สามารถอ่านข้อมูลจาก Apple ได้"
                    return
                }
                
                guard let nonce = currentNonce else {
                    errorMessage = "ระบบความปลอดภัย Nonce ล้มเหลว"
                    return
                }
                
                Task {
                    isLoading = true
                    await authManager.signInWithApple(idToken: idTokenString, nonce: nonce)
                    isLoading = false
                    
                    if authManager.isAuthenticated {
                        alertTitle = "สำเร็จ! ✅"
                        alertMessage = "ลงทะเบียนด้วย Apple เรียบร้อยแล้ว"
                        showAlert = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }
                }
            }
        case .failure(let error):
            // ถ้า User กดข้ามหรือปิดหน้าต่าง Apple Login เอง ไม่ต้องทำอะไร หรือโชว์ error
            if let asError = error as? ASAuthorizationError, asError.code == .canceled {
                // ผู้ใช้กดยกเลิกเอง ไม่ต้องแสดงข้อผิดพลาด
            } else {
                errorMessage = "ยกเลิกการลงทะเบียน: \(error.localizedDescription)"
            }
        }
    }
    
    private var line: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 1)
    }
}

// MARK: - Styling Helper

func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
    }
    
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    let nonce = randomBytes.map { byte in charset[Int(byte) % charset.count] }
    
    return String(nonce)
}

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.compactMap { String(format: "%02x", $0) }.joined()
}

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

#Preview {
    RegisterView()
        .environmentObject(AuthManager())
}
