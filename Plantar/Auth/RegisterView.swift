////
////  RegisterView.swift
////  Plantar
////
////  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
////
//
//import SwiftUI
//
//struct RegisterView: View {
//    // MARK: - Properties
//    @EnvironmentObject var authManager: AuthManager
//    @Environment(\.dismiss) var dismiss
//    
//    // Form Fields
//    @State private var firstName = ""
//    @State private var lastName = ""
//    @State private var email = ""
//    @State private var password = ""
//    
//    // UI States
//    @State private var isLoading = false
//    var isFormValid: Bool {
//        !firstName.isEmpty &&
//        !lastName.isEmpty &&
//        !email.isEmpty &&
//        password.count >= 6
//    }
//    
//    var body: some View {
//        ZStack {
//            // Background Color
//            Color(red: 0.98, green: 0.97, blue: 0.91) // ใช้สีครีมตามธีมแอพ Plantar เดิม หรือใช้ .systemGray6 ตาม UI ใหม่ก็ได้
//                .ignoresSafeArea()
//            
//            ScrollView { // เพิ่ม ScrollView เผื่อหน้าจอเล็ก
//                VStack(spacing: 20) {
//                    
//                    // MARK: - Logo Header
//                    ZStack {
//                        Circle()
//                            .fill(Color(red: 0.82, green: 0.84, blue: 0.36)) // สีเขียวธีมเดิม
//                            .frame(width: 100, height: 100)
//                        
//                        Image(systemName: "leaf.fill")
//                            .font(.system(size: 50))
//                            .foregroundColor(.white)
//                    }
//                    .padding(.top, 40)
//                    
//                    // MARK: - Main Card
//                    VStack(spacing: 20) {
//                        
//                        Text("Create an account")
//                            .font(.system(size: 24, weight: .medium))
//                            .foregroundColor(.black)
//                        
//                        // MARK: - Social Buttons
//                        HStack(spacing: 16) {
//                            // Facebook (Dummy action)
//                            socialButton(image: "facebook", color: Color(hex: "1877F2")) {
//                                // Action for FB
//                            }
//                            
//                            // Google
//                            socialButton(image: "google", color: Color.white) {
//                                Task { await authManager.signInWithGoogle() }
//                            }
//                            
//                            // Apple
////                            socialButton(image: "applelogo", color: Color.black) {
////                                // Apple Sign in flow usually handled via specific request controller
////                                // But here represents the trigger
////                            }
//                        }
//                        
//                        // Divider
//                        HStack {
//                            line
//                            Text("Or")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            line
//                        }
//                        
//                        // MARK: - Input Fields
//                        
//                        // Name Row
//                        HStack(spacing: 12) {
//                            VStack(alignment: .leading) {
//                                Text("First Name")
//                                    .font(.caption).fontWeight(.semibold)
//                                TextField("First Name", text: $firstName)
//                                    .textFieldStyle(CustomTextFieldStyle())
//                            }
//                            
//                            VStack(alignment: .leading) {
//                                Text("Last Name")
//                                    .font(.caption).fontWeight(.semibold)
//                                TextField("Last Name", text: $lastName)
//                                    .textFieldStyle(CustomTextFieldStyle())
//                            }
//                        }
//                        
//                        // Email
//                        VStack(alignment: .leading) {
//                            Text("Email")
//                                .font(.caption).fontWeight(.semibold)
//                            TextField("Enter your email", text: $email)
//                                .textFieldStyle(CustomTextFieldStyle())
//                                .keyboardType(.emailAddress)
//                                .autocapitalization(.none)
//                        }
//                        
//                        // Password
//                        VStack(alignment: .leading) {
//                            Text("Password")
//                                .font(.caption).fontWeight(.semibold)
//                            SecureField("Enter your password (min 6 chars)", text: $password)
//                                .textFieldStyle(CustomTextFieldStyle())
//                        }
//                        
//                        // Error Message
//                        if let error = authManager.errorMessage {
//                            Text(error)
//                                .foregroundColor(.red)
//                                .font(.caption)
//                                .multilineTextAlignment(.center)
//                        }
//                        
//                        // MARK: - Submit Button
//                        Button(action: {
//                            handleSignUp()
//                        }) {
//                            HStack {
//                                if isLoading {
//                                    ProgressView().tint(.white)
//                                } else {
//                                    Text("Create account")
//                                        .fontWeight(.semibold)
//                                }
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(isFormValid ? Color.black : Color.gray)
//                            .foregroundColor(.white)
//                            .cornerRadius(30)
//                            .shadow(radius: 3)
//                        }
//                        .disabled(!isFormValid || isLoading)
//                        .padding(.top, 10)
//                        
//                        // MARK: - Privacy Policy Text
//                        VStack(spacing: 4) {
//                            Text("Signing up for an Application\naccount means you agree to the ")
//                                .foregroundColor(.gray) +
//                            Text("Privacy Policy").fontWeight(.semibold).foregroundColor(.black) +
//                            Text(" and ").foregroundColor(.gray) +
//                            Text("Terms of Service").fontWeight(.semibold).foregroundColor(.black)
//                        }
//                        .font(.footnote)
//                        .multilineTextAlignment(.center)
//                        .padding(.top, 4)
//                        
//                        // MARK: - Sign In Link
//                        HStack {
//                            Text("Already have an account?")
//                                .font(.footnote)
//                                .foregroundColor(.gray)
//                            
//                            Button(action: {
//                                dismiss() // กลับไปหน้า Login
//                            }) {
//                                Text("Sign in")
//                                    .font(.footnote)
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.black)
//                                    .underline()
//                            }
//                        }
//                        .padding(.bottom, 20)
//                    }
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(30)
//                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                    .padding(.horizontal)
//                    
//                    Spacer()
//                }
//            }
//        }
//    }
//    
//    // MARK: - Functions
//    
//
//    // ใน RegisterView.swift
//
//    private func handleSignUp() {
//        Task {
//            // 1. เริ่มหมุน
//            isLoading = true
//            
//            defer {
//                isLoading = false
//            }
//            
//            let combinedNickname = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
//            let finalNickname = combinedNickname.isEmpty ? firstName : combinedNickname
//            
//            // 2. เรียกใช้ AuthManager เพื่อสมัครสมาชิก
//            await authManager.signUp(
//                email: email,
//                password: password,
//                nickname: finalNickname
//            )
//            
//            // 3. ตรวจสอบสถานะการล็อกอิน
//            if authManager.errorMessage == nil {
//                dismiss() // คำสั่งนี้จะพากลับไปหน้า LoginView
//            }
//        }
//    }
//    
//    // MARK: - Subviews
//    
//    private var line: some View {
//        Rectangle()
//            .fill(Color.gray.opacity(0.2))
//            .frame(height: 1)
//    }
//    
//    private func socialButton(image: String, color: Color, action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(color)
//                    .frame(width: 80, height: 50)
//                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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
//                    
//                    Image(systemName: "applelogo")
//                    
//                        .foregroundColor(.white)
//                    
//                        .font(.system(size: 28))
//                    
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Styling Helper
//// สร้าง Style ให้ Textfield สวยงามเหมือนกันทุกช่อง
//struct CustomTextFieldStyle: TextFieldStyle {
//    func _body(configuration: TextField<Self._Label>) -> some View {
//        configuration
//            .padding(12)
//            .background(Color.white)
//            .cornerRadius(8)
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//            )
//    }
//}
//
//// Extension for Hex Color (Optional Helper)
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (1, 1, 1, 0)
//        }
//        
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue:  Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}
//
//#Preview {
//    RegisterView()
//        .environmentObject(AuthManager())
//}

//
// RegisterView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//

//
// RegisterView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 7/10/2568 BE.
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
    @State private var isPasswordVisible = false // เพิ่มตัวแปรสำหรับแสดง/ซ่อนรหัสผ่าน
    
    // Alert States
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        password.count >= 6
    }
    
    var body: some View {
        ZStack {
            // Background Color
            Color(red: 0.98, green: 0.97, blue: 0.91)
                .ignoresSafeArea()
            
            ScrollView {
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
                                    .autocapitalization(.words)
                            }
                            VStack(alignment: .leading) {
                                Text("Last Name")
                                    .font(.caption).fontWeight(.semibold)
                                TextField("Last Name", text: $lastName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .autocapitalization(.words)
                            }
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Email")
                                .font(.caption).fontWeight(.semibold)
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            // แสดงคำแนะนำถ้า Email ไม่ถูกต้อง
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
                        
                        // Password - แก้ไขให้มีปุ่มแสดง/ซ่อนรหัสผ่าน
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Password")
                                .font(.caption).fontWeight(.semibold)
                            
                            // ใช้ ZStack เพื่อวางปุ่มลูกตาทับ
                            ZStack(alignment: .trailing) {
                                // แสดง TextField หรือ SecureField ตามสถานะ
                                if isPasswordVisible {
                                    // แสดงรหัสผ่านแบบเห็นตัวอักษร
                                    TextField("Enter your password (min 6 chars)", text: $password)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .autocapitalization(.none)
                                } else {
                                    // ซ่อนรหัสผ่าน
                                    SecureField("Enter your password (min 6 chars)", text: $password)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                                
                                // ปุ่มลูกตาสำหรับแสดง/ซ่อนรหัสผ่าน
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
                        
                        // Error Message from AuthManager
                        if let error = authManager.errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill")
                                Text(error)
                            }
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
                                dismiss()
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
        // MARK: - Alert Modifier
        .alert(alertTitle, isPresented: $showAlert) {
            Button("ตกลง", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Functions
    
    private func handleSignUp() {
        // ตรวจสอบข้อมูลก่อนส่ง
        if !validateForm() {
            return
        }
        
        Task {
            isLoading = true
            defer {
                isLoading = false
            }
            
            let combinedNickname = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            let finalNickname = combinedNickname.isEmpty ? firstName : combinedNickname
            
            await authManager.signUp(
                email: email,
                password: password,
                nickname: finalNickname
            )
            
            if authManager.errorMessage == nil {
                // แสดง Alert สำเร็จก่อนปิด
                alertTitle = "สำเร็จ! ✅"
                alertMessage = "สมัครสมาชิกเรียบร้อยแล้ว\nยินดีต้อนรับสู่ Plantar!"
                showAlert = true
                
                // รอ Alert ปิดแล้วค่อย dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Validation Functions
    
    /// ตรวจสอบความถูกต้องของฟอร์มทั้งหมด
    private func validateForm() -> Bool {
        // 1. ตรวจสอบชื่อ
        if firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            alertTitle = "ข้อมูลไม่ครบ"
            alertMessage = "กรุณากรอกชื่อจริง"
            showAlert = true
            return false
        }
        
        // 2. ตรวจสอบนามสกุล
        if lastName.trimmingCharacters(in: .whitespaces).isEmpty {
            alertTitle = "ข้อมูลไม่ครบ"
            alertMessage = "กรุณากรอกนามสกุล"
            showAlert = true
            return false
        }
        
        // 3. ตรวจสอบอีเมล
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            alertTitle = "ข้อมูลไม่ครบ"
            alertMessage = "กรุณากรอกอีเมล"
            showAlert = true
            return false
        }
        
        // 4. ตรวจสอบรูปแบบอีเมล
        if !isValidEmail(email) {
            alertTitle = "อีเมลไม่ถูกต้อง"
            alertMessage = "กรุณากรอกอีเมลให้ถูกต้อง\nตัวอย่าง: example@mail.com"
            showAlert = true
            return false
        }
        
        // 5. ตรวจสอบรหัสผ่าน
        if password.isEmpty {
            alertTitle = "ข้อมูลไม่ครบ"
            alertMessage = "กรุณากรอกรหัสผ่าน"
            showAlert = true
            return false
        }
        
        // 6. ตรวจสอบความยาวรหัสผ่าน
        if password.count < 6 {
            alertTitle = "รหัสผ่านไม่ปลอดภัย"
            alertMessage = "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร\n(ปัจจุบันมี \(password.count) ตัว)"
            showAlert = true
            return false
        }
        
        // 7. ตรวจสอบรหัสผ่านแบบละเอียด
        if !isStrongPassword(password) {
            alertTitle = "รหัสผ่านไม่ปลอดภัยพอ"
            alertMessage = "แนะนำให้ใช้รหัสผ่านที่มี:\n• ตัวอักษรภาษาอังกฤษ (a-z, A-Z)\n• ตัวเลข (0-9)\n• ความยาวอย่างน้อย 8 ตัวอักษร"
            showAlert = true
            return false
        }
        
        return true
    }
    
    /// ตรวจสอบรูปแบบอีเมล
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// ตรวจสอบความแข็งแกร่งของรหัสผ่าน
    private func isStrongPassword(_ password: String) -> Bool {
        // อย่างน้อย 8 ตัว มีตัวอักษรและตัวเลข
        let minLength = password.count >= 8
        let hasLetters = password.rangeOfCharacter(from: .letters) != nil
        let hasNumbers = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        return minLength && hasLetters && hasNumbers
    }
    
    /// แสดงระดับความปลอดภัยของรหัสผ่าน
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
                    Image("google_logo")
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

// Extension for Hex Color
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
