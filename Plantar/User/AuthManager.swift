//
//  AuthManager.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 19/11/2568 BE.
//

import SwiftUI
import Supabase

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @State private var isLoading = false
    
    private let supabase = UserProfile.supabase
    
    init() {
        // Check if already logged in
        Task {
            await checkAuth()
        }
    }
    
    // MARK: - Check Auth Status
    
    func checkAuth() async {
        do {
            let session = try await supabase.auth.session
            self.currentUser = session.user
            self.isAuthenticated = true
            print("✅ User already logged in: \(session.user.email ?? "")")
        } catch {
            self.isAuthenticated = false
            print("ℹ️ No active session")
        }
    }
    
    // MARK: - Sign Up
    
    //  Plantar/User/AuthManager.swift

        func signUp(email: String, password: String, nickname: String) async {
            print("🚀 Start SignUp Process...")
            
            // รีเซ็ตค่า Error
            await MainActor.run {
                self.errorMessage = nil
            }
            
            do {
                // 1. สั่งสมัครสมาชิก และรับค่า response โดยตรง
                let response = try await supabase.auth.signUp(
                    email: email,
                    password: password
                )
                print("✅ SignUp API Response Received")
                
                // 2. เช็คว่าได้ Session มาจาก response หรือไม่
                if let session = response.session {
                    print("✅ Session Found! Creating Profile...")
                    
                    // 3. สร้าง Profile
                    let profileData: [String: String] = [
                        "id": session.user.id.uuidString,
                        "nickname": nickname
                    ]
                    
                    try await supabase
                        .from("profiles")
                        .insert(profileData)
                        .execute()
                    
                    print("✅ Profile Created")
                    
                    // 4. อัปเดตสถานะ (สำคัญ: ต้องทำบน Main Actor)
                    await MainActor.run {
                        self.currentUser = session.user
                        self.isAuthenticated = true
                    }
                    
                } else {
                    // กรณีไม่ได้ Session (ต้องยืนยันอีเมล)
                    print("⚠️ No Session in response. Email confirmation might be ON.")
                    await MainActor.run {
                        self.errorMessage = "สมัครสำเร็จ! แต่ต้องยืนยันอีเมลก่อน (กรุณาเช็คการตั้งค่า Supabase)"
                    }
                }
                
            } catch {
                print("❌ Sign Up Error: \(error)")
                await MainActor.run {
                    self.errorMessage = "เกิดข้อผิดพลาด: \(error.localizedDescription)"
                }
            }
        }
    
    // MARK: - Sign In
    
    func signIn(email: String, password: String) async {
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            self.currentUser = session.user
            self.isAuthenticated = true
            
            print("✅ Sign in successful")
            
        } catch {
            errorMessage = "เข้าสู่ระบบล้มเหลว: \(error.localizedDescription)"
            print("❌ Sign in error: \(error)")
        }
    }
    
    // MARK: - Sign In with Google
    
    func signInWithGoogle() async {
        do {
            try await supabase.auth.signInWithOAuth(provider: .google)
            print("✅ Google sign in initiated")
        } catch {
            errorMessage = "Google sign in failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Sign In with Apple
    
    func signInWithApple(idToken: String, nonce: String) async {
        do {
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )
            
            self.currentUser = session.user
            self.isAuthenticated = true
            
            print("✅ Apple sign in successful")
            
        } catch {
            errorMessage = "Apple sign in failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
            print("✅ Signed out")
        } catch {
            errorMessage = "ออกจากระบบล้มเหลว: \(error.localizedDescription)"
        }
    }
}
