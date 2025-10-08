//
//  login.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var acceptTerms = false
    
    var body: some View {
        
        ZStack {
                    Color(red: 0.98, green: 0.97, blue: 0.91) // ครีมอ่อน
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        
                        // โลโก้ (วงกลมสีเขียว)
                        Circle()
                            .fill(Color(red: 0.82, green: 0.84, blue: 0.36))
                            .frame(width: 100, height: 100)
                            .padding(.top, 40)
                        
                        // กล่องเนื้อหาหลัก
                        VStack(spacing: 20) {
                            
                            Text("Sign up")
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(.black)
                            
                            // Email
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Email")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                TextField("Your email", text: $email)
                                    .padding(10)
                                    .background(Color.white)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                                    )
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Password")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                SecureField("Enter your password", text: $password)
                                    .padding(10)
                                    .background(Color.white)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                                    )
                            }
                            
                            // Checkbox Terms
                            HStack {
                                Button(action: { acceptTerms.toggle() }) {
                                    Image(systemName: acceptTerms ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(acceptTerms ? .black : .gray)
                                }
                                Text("I accept the terms and privacy policy")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.top, 10)
                            
                            // ปุ่ม Sign Up
                            Button(action: {
                                print("Sign Up tapped")
                            }) {
                                Text("Sign up")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .shadow(radius: 3)
                            }
                            .padding(.top, 10)
                            
                            // Divider + Social login
                            HStack {
                                Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
                                Text("Or Register with")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
                            }
                            .padding(.vertical, 10)
                            
                            // Social Buttons
                            HStack(spacing: 16) {
                                socialButton(image: "facebook", color: Color.blue)
                                socialButton(image: "google", color: Color.white)
                                socialButton(image: "applelogo", color: Color.black)
                            }
                            
                            // Footer
                            HStack {
                                Text("Already have an account?")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                Button(action: {
                                    print("Go to resgister")
                                }) {
                                    Text("Sign in")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .underline()
                                }
                            }
                            .padding(.bottom, 15)
                            
                        }
                        .padding()
                        .background(Color(white: 0.9))
                        .cornerRadius(30)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
            
            // ปุ่มโซเชียล
            private func socialButton(image: String, color: Color) -> some View {
                Button(action: {}) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color)
                            .frame(width: 80, height: 50)
                            .shadow(radius: 1)
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

#Preview {
    LoginView()
}
