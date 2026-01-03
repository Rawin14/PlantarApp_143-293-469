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
    
    // ตัวแปรเช็คว่าเปิดแอปครั้งแรกไหม (หน้า Welcome)
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // เช็คสถานะตามลำดับ
                if isFirstLaunch {
                    ContentView() // หน้า Splash -> Welcome
                } else if authManager.isAuthenticated {
                    // ล็อกอินแล้ว -> เช็คว่ากรอกประวัติเสร็จยัง?
                    if authManager.isDataComplete {
                        HomeView() // ถ้าครบแล้ว ไปหน้า Home เลย (ไม่ว่า Login ด้วยวิธีไหน)
                    } else {
                        Profile() // ถ้าไม่ครบ ไปหน้ากรอกข้อมูล
                    }
                } else {
                    LoginView() // ยังไม่ล็อกอิน
                }
            }
            .id(authManager.isAuthenticated) // รีเฟรชเมื่อสถานะล็อกอินเปลี่ยน
            .environmentObject(userProfile)
            .environmentObject(authManager)
        }
    }
}
