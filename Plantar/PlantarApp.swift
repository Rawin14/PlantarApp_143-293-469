//
//  PlantarApp.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct PlantarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var Delegate
    @StateObject var userProfile = UserProfile()

    var body: some Scene {
        WindowGroup {
            NavigationStack{
                ContentView()
            }
            .environmentObject(userProfile)
        }
    }
}
