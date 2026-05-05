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
    @StateObject var authManager = AuthManager.shared
    @StateObject var diaryViewModel = DiaryViewModel()
    
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @AppStorage("isTermsAccepted") var isTermsAccepted: Bool = false
    
    @State private var showResetPassword = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                
                // ✅ RESET PASSWORD (override มาก่อน แต่ไม่ไปยุ่ง flow หลัก)
                if authManager.isResetPasswordFlow {
                    ResetPasswordView()
                    
                // ✅ FLOW เดิม (เรียงเหมือนที่คุณต้องการ)
                } else if isFirstLaunch {
                    ContentView()
                    
                } else if !isTermsAccepted {
                    TermsView()
                    
                } else if authManager.isAuthenticated {
                    
                    if authManager.isDataComplete {
                        HomeView()
                    } else {
                        Profile()
                    }
                    
                } else {
                    LoginView()
                }
            }
            .id(authManager.isAuthenticated)
            .animation(.easeInOut, value: isFirstLaunch)
            .animation(.easeInOut, value: isTermsAccepted)
            .environmentObject(userProfile)
            .environmentObject(authManager)
            .environmentObject(diaryViewModel)
            .preferredColorScheme(.light)
            
            .onOpenURL { url in
                Task {
                    await authManager.handleIncomingURL(url)
                }
            }
        }
    }
}
