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
    
    func signUp(email: String, password: String, nickname: String) async {
        errorMessage = nil
        
        do {
            // 1. Sign up with Supabase
            try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            // 2. Get current user
            let session = try await supabase.auth.session
            
            // 3. Create profile
            let profileData: [String: String] = [
                "id": session.user.id.uuidString,
                "nickname": nickname
            ]
            
            try await supabase
                .from("profiles")
                .insert(profileData)
                .execute()
            
            self.currentUser = session.user
            self.isAuthenticated = true
            
            print("✅ Sign up successful")
            
        } catch {
            errorMessage = "สมัครสมาชิกล้มเหลว: \(error.localizedDescription)"
            print("❌ Sign up error: \(error)")
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
