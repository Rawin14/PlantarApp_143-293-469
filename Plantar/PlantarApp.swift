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
                        ContentView()
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
