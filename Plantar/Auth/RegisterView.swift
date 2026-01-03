//
//  register.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//
//
//import SwiftUI
//
//struct RegisterView: View {
//    @State private var firstName = ""
//    @State private var lastName = ""
//    @State private var email = ""
//    @State private var password = ""
//    
//    @State private var isgotoLogin = false
//    
//    var body: some View {
//        if isgotoLogin {
//            LoginView()
//        }
//        else {
//            ZStack {
//                Color(.systemGray6)
//                    .ignoresSafeArea()
//                
//                VStack(spacing: 20) {
//                    
//                    // วงกลมด้านบน
//                    Circle()
//                        .fill(Color(red: 0.8, green: 0.85, blue: 0.3))
//                        .frame(width: 100, height: 100)
//                        .padding(.top, 40)
//                    
//                    // กล่องโฟม
//                    VStack(spacing: 15) {
//                        
//                        Text("Create an account")
//                            .font(.system(size: 24, weight: .medium))
//                            .foregroundColor(.black)
//                        
//                        // ปุ่ม Social Login
//                        HStack(spacing: 16) {
//                            socialButton(image: "facebook", color: Color.blue)
//                            socialButton(image: "google", color: Color.white)
//                            socialButton(image: "applelogo", color: Color.black)
//                        }
//                        
//                        HStack {
//                            line
//                            Text("Or")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            line
//                        }
//                        
//                        // ชื่อ
//                        HStack(spacing: 12) {
//                            VStack(alignment: .leading) {
//                                Text("First Name")
//                                    .font(.caption)
//                                    .fontWeight(.semibold)
//                                TextField("First Name", text: $firstName)
//                                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                            }
//                            VStack(alignment: .leading) {
//                                Text("Last Name")
//                                    .font(.caption)
//                                    .fontWeight(.semibold)
//                                TextField("Last Name", text: $lastName)
//                                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                            }
//                        }
//                        
//                        // Email
//                        VStack(alignment: .leading) {
//                            Text("Email")
//                                .font(.caption)
//                                .fontWeight(.semibold)
//                            TextField("Enter your email", text: $email)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .keyboardType(.emailAddress)
//                        }
//                        
//                        // Password
//                        VStack(alignment: .leading) {
//                            Text("Password")
//                                .font(.caption)
//                                .fontWeight(.semibold)
//                            SecureField("Enter your password", text: $password)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                        }
//                        
//                        // ปุ่มสมัคร
//                        Button(action: {
//                            print("Create account tapped")
//                        }) {
//                            Text("Create account")
//                                .fontWeight(.semibold)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.black)
//                                .foregroundColor(.white)
//                                .cornerRadius(30)
//                                .shadow(radius: 5)
//                        }
//                        .padding(.top, 10)
//                        
//                        // Privacy Policy
//                        VStack(spacing: 4) {
//                            Text("Signing up for an Application \naccount means you agree to the ")
//                                .font(.footnote)
//                                .foregroundColor(.gray)
//                            +
//                            Text("Privacy Policy")
//                                .font(.footnote)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.black)
//                            +
//                            Text(" and ")
//                                .font(.footnote)
//                                .foregroundColor(.gray)
//                            +
//                            Text("Terms of Service")
//                                .font(.footnote)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.black)
//                        }
//                        .multilineTextAlignment(.center)
//                        .lineLimit(nil) //ป้องกันไม่ให้แสดงเป็น ...
//                        .fixedSize(horizontal: false, vertical: true) //ให้ขยายความสูงอัตโนมัติ
//                        .padding(.top, 4)
//                        
//                        // ลิงก์เข้าสู่ระบบ
//                        HStack {
//                            Text("Have an account ")
//                                .font(.footnote)
//                                .foregroundColor(.gray)
//                            Button(action: {
//                                isgotoLogin = true
//                                print("Go to login")
//                            }) {
//                                Text("Sign up")
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
//                    .shadow(radius: 3)
//                    .padding(.horizontal)
//                    
//                    Spacer()
//                }
//            }
//        }
//    }
//    
//    private var line: some View {
//        Rectangle()
//            .fill(Color.gray.opacity(0.4))
//            .frame(height: 1)
//    }
//    
//    private func socialButton(image: String, color: Color) -> some View {
//        Button(action: {}) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(color)
//                    .frame(width: 80, height: 50)
//                    .shadow(radius: 2)
//                if image == "facebook" {
//                    Image("facebook_logo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 24, height: 24)
//                } else if image == "google" {
//                    Image("google_logo") // แนะนำให้นำไอคอน google เข้ามาใน Assets
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 24, height: 24)
//                } else {
//                    Image(systemName: "applelogo")
//                        .foregroundColor(.white)
//                        .font(.system(size: 28))
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    RegisterView()
//}


import SwiftUI

struct RegisterView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    
    @State private var isgotoLogin = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    
//    @StateObject private var authVM = AuthViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        if isgotoLogin {
            LoginView()
        } else {
            registerContent
        }
    }
    
    private var registerContent: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Circle()
                    .fill(Color(red: 0.8, green: 0.85, blue: 0.3))
                    .frame(width: 100, height: 100)
                    .padding(.top, 40)
                
                VStack(spacing: 15) {
                    
                    Text("Create an account")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.black)
                    
                    // MARK: - Social Login
                    HStack(spacing: 16) {
                        socialButton(image: "facebook_logo", color: .blue) {
                            print("Facebook tapped") // ยังไม่มี auth
                        }
                        socialButton(image: "google_logo", color: .white) {
                            Task { await authVM.signInWithGoogle() }
                        }
                        socialButtonApple()
                    }
                    
                    HStack {
                        line
                        Text("Or")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        line
                    }
                    
                    // MARK: - First Name / Last Name
                    HStack(spacing: 12) {
                        VStack(alignment: .leading) {
                            Text("First Name")
                                .font(.caption)
                                .fontWeight(.semibold)
                            TextField("First Name", text: $firstName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading) {
                            Text("Last Name")
                                .font(.caption)
                                .fontWeight(.semibold)
                            TextField("Last Name", text: $lastName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    // MARK: - Email
                    VStack(alignment: .leading) {
                        Text("Email")
                            .font(.caption)
                            .fontWeight(.semibold)
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                    }
                    
                    // MARK: - Password
                    VStack(alignment: .leading) {
                        Text("Password")
                            .font(.caption)
                            .fontWeight(.semibold)
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // MARK: - Create Account Button
                    Button(action: createAccount) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Create account")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(30)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.top, 10)
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // MARK: - Privacy Policy
                    VStack(spacing: 4) {
                        Text("Signing up for an Application \naccount means you agree to the ")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        +
                        Text("Privacy Policy")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        +
                        Text(" and ")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        +
                        Text("Terms of Service")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                    
                    // MARK: - Login Redirect
                    HStack {
                        Text("Have an account?")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            isgotoLogin = true
                        }) {
                            Text("Login")
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
                .shadow(radius: 3)
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Create Account with Supabase
    private func createAccount() {
        Task {
            isLoading = true
            errorMessage = ""
            
            do {
                try await SupabaseManager.shared.client.auth.signUp(
                    email: email,
                    password: password
                )
                
                isLoading = false
                isgotoLogin = true
                
            } catch {
                isLoading = false
                errorMessage = "Failed to create account: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - UI Components
    
    private var line: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.4))
            .frame(height: 1)
    }
    
    private func socialButton(image: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
                    .frame(width: 80, height: 50)
                    .shadow(radius: 2)
                
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
        }
    }
    
    // Apple Button (system logo)
    private func socialButtonApple() -> some View {
        Button(action: {
            print("Apple tapped")
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black)
                    .frame(width: 80, height: 50)
                    .shadow(radius: 2)
                
                Image(systemName: "applelogo")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
            }
        }
    }
}

#Preview {
    RegisterView()
}

