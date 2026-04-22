//
//  ResetPasswordView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 20/4/2569 BE.
//

import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 48))
                        .foregroundColor(Color(red: 0.82, green: 0.84, blue: 0.36))
                    
                    Text("ตั้งรหัสผ่านใหม่")
                        .font(.title2).fontWeight(.semibold)
                    
                    Text("กรอกรหัสผ่านใหม่ของคุณ")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                VStack(spacing: 14) {
                    // รหัสใหม่
                    VStack(alignment: .leading, spacing: 6) {
                        Text("รหัสผ่านใหม่")
                            .font(.caption).fontWeight(.semibold)
                        
                        ZStack(alignment: .trailing) {
                            Group {
                                if isPasswordVisible {
                                    TextField("อย่างน้อย 6 ตัวอักษร", text: $newPassword)
                                } else {
                                    SecureField("อย่างน้อย 6 ตัวอักษร", text: $newPassword)
                                }
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .autocapitalization(.none)
                            
                            Button { isPasswordVisible.toggle() } label: {
                                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 40, height: 40)
                            }
                            .padding(.trailing, 6)
                        }
                    }
                    
                    // ยืนยันรหัสใหม่
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ยืนยันรหัสผ่านใหม่")
                            .font(.caption).fontWeight(.semibold)
                        
                        SecureField("กรอกรหัสผ่านอีกครั้ง", text: $confirmPassword)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .autocapitalization(.none)
                        
                        if !confirmPassword.isEmpty && confirmPassword != newPassword {
                            Label("รหัสผ่านไม่ตรงกัน", systemImage: "exclamationmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Error
                if let err = errorMessage {
                    Label(err, systemImage: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                // ปุ่มบันทึก
                Button(action: { Task { await savePassword() } }) {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("บันทึกรหัสผ่านใหม่")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSubmit ? Color.black : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                }
                .disabled(!canSubmit || isLoading)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ยกเลิก") { dismiss() }
                }
            }
        }
    }
    
    private var canSubmit: Bool {
        newPassword.count >= 6 && newPassword == confirmPassword
    }
    
    private func savePassword() async {
        isLoading = true
        errorMessage = nil
        let success = await authManager.resetPassword(newPassword: newPassword)
        isLoading = false
        
        if success {
            authManager.isResetPasswordFlow = false
            await authManager.signOut()
            
            errorMessage = "เปลี่ยนรหัสผ่านสำเร็จ กรุณาเข้าสู่ระบบใหม่"
        }
    }
}
