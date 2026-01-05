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
    
    // 1. สถานะเปิดแอปครั้งแรก (Welcome Screen)
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    // 2. ✅ เพิ่มสถานะการยอมรับเงื่อนไข (Terms)
    @AppStorage("isTermsAccepted") var isTermsAccepted: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // เช็คสถานะตามลำดับ (Flow ของแอป)
                if isFirstLaunch {
                    // ด่านที่ 1: หน้า Welcome
                    ContentView()
                } else if !isTermsAccepted {
                    // ด่านที่ 2: ✅ ถ้ายังไม่ยอมรับเงื่อนไข -> ไปหน้า Terms
                    // (พอ User กดปุ่มยอมรับ ตัวแปรนี้จะเป็น true แล้วแอปจะดีดไป LoginView เอง)
                    TermsView()
                } else if authManager.isAuthenticated {
                    // ด่านที่ 4: ล็อกอินแล้ว -> เช็คว่ากรอกประวัติครบไหม?
                    if authManager.isDataComplete {
                        HomeView() // ครบจบ -> หน้าหลัก
                    } else {
                        Profile() // ยังไม่ครบ -> หน้ากรอกประวัติ
                    }
                } else {
                    // ด่านที่ 3: ✅ ผ่าน Terms มาแล้ว แต่ยังไม่ล็อกอิน -> หน้า Login
                    LoginView()
                }
            }
            .id(authManager.isAuthenticated) // รีเฟรชเมื่อสถานะล็อกอินเปลี่ยน
            .animation(.easeInOut, value: isFirstLaunch) // เพิ่ม Animation เปลี่ยนหน้าให้นุ่มนวล
            .animation(.easeInOut, value: isTermsAccepted)
            .environmentObject(userProfile)
            .environmentObject(authManager)
        }
    }
}
