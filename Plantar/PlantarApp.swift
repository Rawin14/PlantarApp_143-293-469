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
                    if authManager.isAuthenticated {
                        // แสดงหน้าหลัก
                        ProfileView()
                            .onAppear {
                                // 🔴 ใส่โค้ดนี้ชั่วคราว เพื่อบังคับ Logout ทันทีที่หน้านี้แสดง
                                    Task { await authManager.signOut() }
                            }
                    } else {
                        // แสดงหน้า Login
                        ContentView()
                    }
                }
                .environmentObject(userProfile)
                .environmentObject(authManager)
            }
        }
}
