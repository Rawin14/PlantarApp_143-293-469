////
////  PlantarApp.swift
////  Plantar
////
////  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
////
//
//import SwiftUI
//
//@main
//struct PlantarApp: App {
//    @StateObject var userProfile = UserProfile()
//    @StateObject var authManager = AuthManager()
//    
//    // ตัวแปรเช็คว่าเปิดแอปครั้งแรกไหม (หน้า Welcome)
//    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
//    
//    
//    var body: some Scene {
//        WindowGroup {
//            NavigationStack {
//                // เช็คสถานะตามลำดับ
//                if isFirstLaunch {
//                    ContentView() // หน้า Splash -> Welcome
//                } else if authManager.isAuthenticated {
//                    // ล็อกอินแล้ว -> เช็คว่ากรอกประวัติเสร็จยัง?
//                    if authManager.isDataComplete {
//                        HomeView() // ถ้าครบแล้ว ไปหน้า Home เลย (ไม่ว่า Login ด้วยวิธีไหน)
//                    } else {
//                        Profile() // ถ้าไม่ครบ ไปหน้ากรอกข้อมูล
//                    }
//                } else {
//                    LoginView() // ยังไม่ล็อกอิน
//                }
//            }
//            .id(authManager.isAuthenticated) // รีเฟรชเมื่อสถานะล็อกอินเปลี่ยน
//            .environmentObject(userProfile)
//            .environmentObject(authManager)
//        }
//    }
//}

//
//  PlantarApp.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//

import SwiftUI

@main
struct PlantarApp: App {
    // ใช้ Shared Instance เพื่อให้ข้อมูลตรงกันทั้งแอป (แนะนำให้ใช้ .shared ถ้ามี)
    @StateObject var userProfile = UserProfile.shared
    @StateObject var authManager = AuthManager.shared
    
    // ตัวแปรเช็คว่าเปิดแอปครั้งแรกไหม (หน้า Welcome)
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    // ✅ 1. เพิ่มตัวแปรเช็คสถานะการยอมรับเงื่อนไข (เก็บในเครื่อง)
    @AppStorage("isTermsAccepted") var isTermsAccepted: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // เช็คสถานะตามลำดับ Priority
                if isFirstLaunch {
                    ContentView() // หน้า Splash -> Welcome
                } else if authManager.isAuthenticated {
                    
                    // ✅ 2. เพิ่ม Logic: ต้องยอมรับ Terms ก่อน ถึงจะไปต่อได้
                    if !isTermsAccepted {
                        TermsView() // แสดงหน้าเงื่อนไข
                    }
                    // ถ้า Login และ ยอมรับ Terms แล้ว -> เช็คว่ากรอกประวัติเสร็จยัง?
                    else if authManager.isDataComplete {
                        HomeView() // ข้อมูลครบ -> ไปหน้า Home
                    } else {
                        Profile() // ข้อมูลไม่ครบ -> ไปหน้ากรอกประวัติ (Profile Setup)
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
