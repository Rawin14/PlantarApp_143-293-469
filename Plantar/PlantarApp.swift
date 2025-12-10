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
    
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // เช็คสถานะตามลำดับ: ครั้งแรก -> ล็อกอินค้างไว้ -> ยังไม่ล็อกอิน
                if isFirstLaunch {
                    ContentView() // หน้า Splash -> Welcome -> Terms
                } else if authManager.isAuthenticated {
                    Profile() // หรือ HomeView ตาม Flow ของคุณ
                } else {
                    LoginView()
                }
            }
            .id(authManager.isAuthenticated)
            .environmentObject(userProfile)
            .environmentObject(authManager)
        }
    }
}

