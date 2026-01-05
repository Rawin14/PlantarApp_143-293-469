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
    
    // ✅ 1. ต้องประกาศ AppStorage ให้ครบทั้ง 2 ตัว (เพื่อให้แอปรู้เมื่อค่าเปลี่ยน)
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @AppStorage("isTermsAccepted") var isTermsAccepted: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // ✅ 2. เรียงลำดับ Flow ให้ถูกต้อง
                if isFirstLaunch {
                    // ด่าน 1: หน้า Welcome
                    ContentView()
                } else if !isTermsAccepted {
                    // ด่าน 2: ถ้ายังไม่ยอมรับเงื่อนไข -> ไปหน้า Terms
                    TermsView()
                } else if authManager.isAuthenticated {
                    // ด่าน 4: ล็อกอินแล้ว -> เช็คประวัติ
                    if authManager.isDataComplete {
                        HomeView()
                    } else {
                        Profile()
                    }
                } else {
                    // ด่าน 3: ยังไม่ล็อกอิน -> ไปหน้า Login
                    LoginView()
                }
            }
            .animation(.easeInOut, value: isFirstLaunch) // เพิ่ม Animation เปลี่ยนหน้า
            .animation(.easeInOut, value: isTermsAccepted)
            .environmentObject(userProfile)
            .environmentObject(authManager)
        }
    }
}
