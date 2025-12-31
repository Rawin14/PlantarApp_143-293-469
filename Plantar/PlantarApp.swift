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
    
    // ✅ เพิ่มตัวแปรนี้: เช็คว่ากรอกข้อมูลส่วนตัว (StartView) เสร็จหรือยัง
    @AppStorage("isProfileSetupCompleted") var isProfileSetupCompleted: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // เช็คสถานะตามลำดับ
                if isFirstLaunch {
                    ContentView() // หน้า Splash -> Welcome
                } else if authManager.isAuthenticated {
                    // ล็อกอินแล้ว -> เช็คว่ากรอกประวัติเสร็จยัง?
                    if isProfileSetupCompleted {
                        HomeView() // ✅ ถ้าเสร็จแล้ว ไปหน้า Home เลย
                    } else {
                        // ⚠️ ถ้ายังไม่เสร็จ ให้ไปหน้าเก็บข้อมูล (StartView)
                        // เปลี่ยน Profile() เป็นหน้าแรกของ StartView ของคุณ เช่น EntryView() หรือ AgeView()
                        Profile()
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
