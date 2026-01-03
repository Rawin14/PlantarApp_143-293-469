//
//  PlantarApp.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//
//
//import SwiftUI
//import FirebaseCore
//import Supabase
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//    return true
//  }
//}
//
//@main
//struct PlantarApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var Delegate
//    @StateObject var userProfile = UserProfile()
//
//    var body: some Scene {
//        WindowGroup {
//            NavigationStack{
//                DiaryTodayView()
//            }
//            .environmentObject(userProfile)
//        }
//    }
//}
//


import SwiftUI
import FirebaseCore
import Supabase
import UserNotifications

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // ตั้งค่า Firebase
        FirebaseApp.configure()
        
        // ตั้งค่า Notification Delegate
        UNUserNotificationCenter.current().delegate = self
        
        print("🚀 PlantarApp launched successfully")
        
        return true
    }
    
    // MARK: - Notification Permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                print("✅ Notification permission granted")
                
                // ตั้งค่าการแจ้งเตือนประจำวันทันที
                Task {
                    await NotificationManager.shared.scheduleDailyNotifications()
                }
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print("⚠️ Notification permission denied by user")
            }
        }
    }
    
    // MARK: - Notification Delegate Methods
    
    /// เรียกเมื่อผู้ใช้กดที่การแจ้งเตือน
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let identifier = response.notification.request.identifier
        let notificationTitle = response.notification.request.content.title
        let notificationBody = response.notification.request.content.body
        
        print("👆 User tapped notification:")
        print("   ID: \(identifier)")
        print("   Title: \(notificationTitle)")
        print("   Body: \(notificationBody)")
        
        // เคลียร์ badge บน app icon
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        // จัดการตาม notification ID
        switch identifier {
        case "exercise_reminder":
            print("📱 User should be navigated to Exercise page")
            // TODO: เพิ่ม deep linking ไปหน้าออกกำลังกาย
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToExercise"), object: nil)
            
        case "feeling_check":
            print("📱 User should be navigated to Feeling Log page")
            // TODO: เพิ่ม deep linking ไปหน้าบันทึกความรู้สึก
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToFeeling"), object: nil)
            
        case "test_notification":
            print("🧪 Test notification tapped")
            
        default:
            print("ℹ️ Unknown notification identifier: \(identifier)")
        }
        
        completionHandler()
    }
    
    /// เรียกเมื่อได้รับการแจ้งเตือนขณะที่แอปเปิดอยู่ (Foreground)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let identifier = notification.request.identifier
        print("📬 Notification received while app is in foreground: \(identifier)")
        
        // แสดงการแจ้งเตือนแม้ว่าแอปจะเปิดอยู่
        if #available(iOS 14.0, *) {
            // iOS 14+ รองรับ .banner
            completionHandler([.banner, .sound, .badge])
        } else {
            // iOS 13 ใช้ .alert แทน .banner
            completionHandler([.alert, .sound, .badge])
        }
    }
}

// MARK: - Main App
@main
struct PlantarApp: App {
    // เชื่อมต่อ AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // ViewModels
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userProfile = UserProfile()
    
    // Notification Manager
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RegisterView()
            }
            .environmentObject(authViewModel)
            .environmentObject(userProfile)
            .onAppear {
                setupApp()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // เมื่อแอปกลับมาเป็น foreground
                handleAppForegrounded()
            }
        }
    }

    
    // MARK: - App Setup
    private func setupApp() {
        print("🎨 Setting up PlantarApp...")
        
        // ตรวจสอบสถานะการแจ้งเตือน
        Task {
            await notificationManager.checkAuthorizationStatus()
            
            // Debug: แสดงจำนวนการแจ้งเตือนที่รอส่ง
            await notificationManager.listPendingNotifications()
        }
        
        // เคลียร์ badge เมื่อเปิดแอป
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // MARK: - App Lifecycle
    private func handleAppForegrounded() {
        print("App entered foreground")
        
        // เคลียร์ badge
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // ตรวจสอบสถานะการแจ้งเตือนใหม่
        Task {
            await notificationManager.checkAuthorizationStatus()
        }
    }
}

// MARK: - Notification Names Extension (สำหรับ Deep Linking)
extension Notification.Name {
    static let navigateToExercise = Notification.Name("NavigateToExercise")
    static let navigateToFeeling = Notification.Name("NavigateToFeeling")
}
