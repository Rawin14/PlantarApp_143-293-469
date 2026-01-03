//
//  AuthManager.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 19/11/2568 BE.
//

import SwiftUI
import Supabase
import AuthenticationServices // 1. เพิ่มตัวนี้เข้ามา

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @State private var isLoading = false
    @Published var isDataComplete: Bool = false
    
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
        await MainActor.run { self.isLoading = true; self.errorMessage = nil }
        
        defer {
            Task { await MainActor.run { self.isLoading = false } }
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
                }
                print("✅ Sign up successful -> Switching View")
            }
        } catch {
            print("❌ Error: \(error)")
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
    }
    
    // MARK: - Sign In (Email/Pass)
    func signIn(email: String, password: String) async {
        await MainActor.run { self.isLoading = true; self.errorMessage = nil }
        
        defer {
            Task { await MainActor.run { self.isLoading = false } }
        }
        
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            
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
    
    // MARK: - Sign In with Google (New Logic)
    func signInWithGoogle() async {
        do {
            // 1. ขอ URL สำหรับ Login จาก Supabase
            // ต้องตรงกับที่ตั้งใน Supabase Dashboard และ Info.plist
            let authURL = try await supabase.auth.getOAuthSignInURL(
                provider: .google,
                redirectTo: URL(string: "plantarapp://login-callback")!
            )
            
            // 2. เปิด Web Browser ภายในแอปเพื่อ Login
            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "plantarapp") { callbackURL, error in
                            guard let url = callbackURL else { return }
                            
                            Task {
                                do {
                                    // ได้ Session แล้ว
                                    let session = try await self.supabase.auth.session(from: url)
                                    
                                    await MainActor.run {
                                        self.currentUser = session.user
                                        self.isAuthenticated = true
                                    }
                                    
                                    // ✅ เช็คข้อมูล Profile ทันที!
                                    await self.checkUserStatus()}
                                catch {
                        print("❌ Failed to parse session: \(error)")
                        await MainActor.run {
                            self.errorMessage = "Login Google ไม่สำเร็จ: \(error.localizedDescription)"
                        }
                    }
                }
            }
            
            // การตั้งค่าเพิ่มเติมสำหรับการแสดงผล
            let contextProvider = PresentationAnchorProvider()
            session.presentationContextProvider = contextProvider
            session.prefersEphemeralWebBrowserSession = true // true = ไม่จำ Cookie เดิม (Login ใหม่ทุกรอบ)
            
            self.webAuthSession = session // เก็บค่าไว้ไม่ให้ตัวแปรตาย
            session.start() // เริ่มทำงาน
            
            print("✅ Google sign in initiated via WebAuthSession")
            
        } catch {
            errorMessage = "Google sign in failed: \(error.localizedDescription)"
        }
    }
    
        func checkUserStatus() async {
                do {
                    // เรียกใช้ UserProfile เพื่อดึงข้อมูลมาเช็ค
                    // ต้องแน่ใจว่า UserProfile มีฟังก์ชัน fetchCurrentProfile ตามที่แก้ไปรอบก่อน
                    let profile = try await UserProfile.shared.fetchCurrentProfile()
                    
                    await MainActor.run {
                        // ถ้าข้อมูลครบ (isComplete == true) ให้ isDataComplete เป็น true
                        self.isDataComplete = profile.isComplete
                        
                        print("👤 Profile Status: \(profile.isComplete ? "Complete" : "Incomplete")")
                    }
                } catch {
                    print("ℹ️ Profile fetch failed (New User): \(error)")
                    await MainActor.run {
                        self.isDataComplete = false // ยังไม่มีข้อมูล
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

// Helper Class สำหรับบอกตำแหน่งหน้าต่าง Web View
class PresentationAnchorProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? ASPresentationAnchor()
    }
}
