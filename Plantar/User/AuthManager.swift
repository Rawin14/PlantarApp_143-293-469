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
    
    // ฟังก์ชันสมัครสมาชิก
    func signUp(email: String, password: String, nickname: String) async {
        await MainActor.run { self.isLoading = true; self.errorMessage = nil }
        
        defer {
            Task { await MainActor.run { self.isLoading = false } }
        }
        
        do {
            // 1. ยิง API สมัคร
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            // 2. เช็คว่าได้ Session มาเลยไหม (ถ้าปิด Confirm Email จะได้มาเลย)
            if let session = response.session {
                // บันทึก Profile ลงฐานข้อมูล
                let profileData: [String: String] = [
                    "id": session.user.id.uuidString,
                    "nickname": nickname
                ]
                try await supabase.from("profiles").insert(profileData).execute()
                
                // ✅ จุดสำคัญ: เปลี่ยนสถานะตรงนี้เพื่อให้ PlantarApp สลับหน้า
                await MainActor.run {
                    self.currentUser = session.user
                    self.isAuthenticated = true
                }
                print("✅ Sign up successful -> Switching View")
            }
        } catch {
            print("❌ Error: \(error)")
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
    }
    
    // MARK: - Sign In
    
    func signIn(email: String, password: String) async {
        await MainActor.run { self.isLoading = true; self.errorMessage = nil }
        
        defer {
            Task { await MainActor.run { self.isLoading = false } }
        }
        
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            
            // ✅ จุดสำคัญ: เปลี่ยนสถานะตรงนี้
            await MainActor.run {
                self.currentUser = session.user
                self.isAuthenticated = true
            }
            print("✅ Login successful -> Switching View")
        } catch {
            print("❌ Error: \(error)")
            await MainActor.run { self.errorMessage = "อีเมลหรือรหัสผ่านไม่ถูกต้อง" }
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
        await MainActor.run {
            self.isAuthenticated = false
            self.currentUser = nil
            
            UserDefaults.standard.set(false, forKey: "isProfileSetupCompleted")
        }
        
        do {
            try await supabase.auth.signOut()
            print("✅ Signed out form Server")
        } catch {
            print("⚠️ Logout server error: \(error.localizedDescription)")
        }
    }
}
