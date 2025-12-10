//
//  PlantarApp.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//

import SwiftUI

@main
struct PlantarApp: App {
    @StateObject var userProfile = UserProfile()
    @StateObject var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // เช็คสถานะการล็อกอินตรงนี้
                if authManager.isAuthenticated {
                    // ถ้าล็อกอินแล้ว ไปหน้า Profile (หรือ HomeView ตาม Flow ของคุณ)
                    Profile()
                } else {
                    // ⚠️ แก้ตรงนี้: ถ้าไม่ได้ล็อกอิน (หรือกด Logout) ให้เรียก LoginView โดยตรง
                    // จากเดิม: ContentView()
                    LoginView()
                }
            }
                .environmentObject(userProfile)
                .environmentObject(authManager)
        }
    }
}

