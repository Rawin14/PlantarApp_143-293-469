//
// AuthManager.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 19/11/2568 BE.
//

//
// AuthManager.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 19/11/2568 BE.
//

import SwiftUI
import Supabase
import AuthenticationServices

@MainActor
class AuthManager: ObservableObject {
    
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isDataComplete: Bool = false
    @Published var isLoading = false
    
    // ใช้ Client เดิมที่มีอยู่แล้วในโปรเจกต์
    private let supabase = UserProfile.supabase
    
    // ตัวแปรสำหรับเก็บ Web Session ไม่ให้หายไปก่อน Login เสร็จ
    private var webAuthSession: ASWebAuthenticationSession?
    
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
            await checkUserStatus()
            print("✅ User already logged in: \(session.user.email ?? "")")
        } catch {
            self.isAuthenticated = false
            print("ℹ️ No active session")
        }
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, nickname: String) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        defer {
            Task {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            if let session = response.session {
                let profileData: [String: String] = [
                    "id": session.user.id.uuidString,
                    "nickname": nickname
                ]
                
                try await supabase.from("profiles").insert(profileData).execute()
                
                await MainActor.run {
                    self.currentUser = session.user
                    self.isAuthenticated = true
                    self.isDataComplete = false
                }
                
                print("✅ Sign up successful -> Switching View")
            }
        } catch {
            await MainActor.run {
                if error.localizedDescription.contains("User already registered") {
                    self.errorMessage = "อีเมลนี้ถูกใช้งานแล้ว กรุณาใช้อีเมลอื่น"
                } else if error.localizedDescription.contains("Password should be at least") {
                    self.errorMessage = "รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร"
                } else if error.localizedDescription.contains("invalid email") {
                    self.errorMessage = "รูปแบบอีเมลไม่ถูกต้อง"
                } else {
                    self.errorMessage = "เกิดข้อผิดพลาด: \(error.localizedDescription)"
                }
                print("❌ Sign up error: \(error)")
            }
        }
    }
    
    // MARK: - Sign In (Email/Pass)
    
    func signIn(email: String, password: String) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        defer {
            Task {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            
            await MainActor.run {
                self.currentUser = session.user
            }
            
            await checkUserStatus()
            print("✅ Login successful -> Switching View")
            
        } catch {
            print("❌ Error: \(error)")
            await MainActor.run {
                self.errorMessage = "อีเมลหรือรหัสผ่านไม่ถูกต้อง"
            }
        }
    }
    
    // MARK: - Sign In with Google (ถ้าไม่ใช้ให้ comment ออก)
    
    func signInWithGoogle() async {
        await MainActor.run {
            self.errorMessage = "ฟีเจอร์ Google Sign In ยังไม่พร้อมใช้งาน"
        }
        print("⚠️ Google Sign In not implemented")
        
        /* ถ้าต้องการใช้ Google Sign In ให้ uncomment โค้ดด้านล่าง
        do {
            let authURL = try await supabase.auth.getOAuthSignInURL(
                provider: .google,
                redirectTo: URL(string: "plantarapp://login-callback")!
            )
            
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "plantarapp"
            ) { callbackURL, error in
                guard let url = callbackURL else { return }
                
                Task {
                    do {
                        let session = try await self.supabase.auth.session(from: url)
                        
                        await MainActor.run {
                            self.currentUser = session.user
                            self.isAuthenticated = true
                        }
                        
                        await self.checkUserStatus()
                        
                    } catch {
                        print("❌ Failed to parse session: \(error)")
                        await MainActor.run {
                            self.errorMessage = "Login Google ไม่สำเร็จ: \(error.localizedDescription)"
                        }
                    }
                }
            }
            
            let contextProvider = PresentationAnchorProvider()
            session.presentationContextProvider = contextProvider
            session.prefersEphemeralWebBrowserSession = true
            
            self.webAuthSession = session
            session.start()
            
            print("✅ Google sign in initiated via WebAuthSession")
            
        } catch {
            errorMessage = "Google sign in failed: \(error.localizedDescription)"
        }
        */
    }
    
    // MARK: - Check User Status
    
    func checkUserStatus() async {
        do {
            let profile = try await UserProfile.shared.fetchCurrentProfile()
            
            await MainActor.run {
                self.isAuthenticated = true
                
                if let profile = profile {
                    self.isDataComplete = profile.isComplete
                    print("👤 Old User: \(profile.isComplete ? "Complete" : "Incomplete")")
                } else {
                    self.isDataComplete = false
                    print("🆕 New User: No profile found (Go to setup)")
                }
            }
        } catch {
            print("❌ System Error: \(error)")
            await MainActor.run {
                self.isAuthenticated = true
                self.isDataComplete = false
            }
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
            
            await checkUserStatus()
            
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
            self.isDataComplete = false
            UserDefaults.standard.set(false, forKey: "isProfileSetupCompleted")
        }
        
        do {
            try await supabase.auth.signOut()
            print("✅ Signed out from Server")
        } catch {
            print("⚠️ Logout server error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Password Management
    
    /// เปลี่ยนรหัสผ่าน (ต้องยืนยันรหัสผ่านเก่าก่อน)
    func changePassword(current: String, new: String) async -> Bool {
        do {
            guard let email = currentUser?.email else {
                print("❌ No current user email found")
                await MainActor.run {
                    self.errorMessage = "ไม่พบข้อมูลผู้ใช้"
                }
                return false
            }
            
            // Verify current password
            do {
                let _ = try await supabase.auth.signIn(
                    email: email,
                    password: current
                )
                print("✅ Current password verified")
            } catch {
                print("❌ Current password verification failed")
                await MainActor.run {
                    self.errorMessage = "รหัสผ่านปัจจุบันไม่ถูกต้อง"
                }
                return false
            }
            
            // Change password
            try await supabase.auth.update(
                user: UserAttributes(password: new)
            )
            
            print("✅ Password changed successfully")
            await MainActor.run {
                self.errorMessage = nil
            }
            return true
            
        } catch {
            print("❌ Change password error: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "เปลี่ยนรหัสผ่านไม่สำเร็จ"
            }
            return false
        }
    }
    
    /// ส่งอีเมลรีเซ็ตรหัสผ่าน
    func sendPasswordResetEmail(email: String) async {
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            
            print("✅ Password reset email sent to \(email)")
            await MainActor.run {
                self.errorMessage = nil
            }
            
        } catch {
            print("❌ Reset password error: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "ส่งอีเมลรีเซ็ตรหัสผ่านไม่สำเร็จ"
            }
        }
    }
    
    /// รีเซ็ตรหัสผ่านใหม่ (หลังจากคลิกลิงก์จากอีเมล)
    func resetPassword(newPassword: String) async -> Bool {
        do {
            try await supabase.auth.update(
                user: UserAttributes(password: newPassword)
            )
            
            print("✅ Password reset successfully")
            await MainActor.run {
                self.errorMessage = nil
            }
            return true
            
        } catch {
            print("❌ Reset password error: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "รีเซ็ตรหัสผ่านไม่สำเร็จ"
            }
            return false
        }
    }
}

// MARK: - Helper Class

/// Helper Class สำหรับบอกตำแหน่งหน้าต่าง Web View
class PresentationAnchorProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? ASPresentationAnchor()
    }
}
