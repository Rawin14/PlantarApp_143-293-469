//
//  AuthViewModel.swift
//  Plantar
//
//  Created by ncp on 2/1/2569 BE.
//
//
//import Foundation
//import SwiftUI
//import AuthenticationServices
//import Supabase
//
//class AuthViewModel: ObservableObject {
//    
//    func signInWithGoogle() async {
//        do {
//            let authURL = try await SupabaseManager.shared.client.auth.getOAuthSignInURL(
//                provider: .google,
//                redirectTo: URL(string: "plantarapp://login-callback")!
//            )
//            
//            let session = ASWebAuthenticationSession(
//                url: authURL,
//                callbackURLScheme: "plantarapp"
//            ) { callbackURL, error in
//                guard let url = callbackURL else { return }
//                
//                Task {
//                    do {
//                        try await SupabaseManager.shared.client.auth.session(from: url)
//                        print("Google login success")
//                    } catch {
//                        print("Failed to parse session: \(error)")
//                    }
//                }
//            }
//            
//            session.presentationContextProvider = PresentationAnchorProvider()
//            session.prefersEphemeralWebBrowserSession = true
//            session.start()
//            
//        } catch {
//            print("Google login error:", error.localizedDescription)
//        }
//    }
//}
//
//// ใช้สำหรับรองรับหน้าต่าง ASWebAuthenticationSession
//class PresentationAnchorProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        return UIApplication.shared.connectedScenes
//            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
//            .first ?? ASPresentationAnchor()
//    }
//}
//



import Foundation
import SwiftUI
import AuthenticationServices
import Supabase

//@MainActor
//final class AuthViewModel: ObservableObject {
//
//    // 🔑 ต้องเก็บ strong reference
//    private var authSession: ASWebAuthenticationSession?
//
//    func signInWithGoogle() async {
//        do {
//            let authURL = try await SupabaseManager.shared.client.auth.getOAuthSignInURL(
//                provider: .google,
//                redirectTo: URL(string: "plantarapp://login-callback")!
//            )
//
//            // 🔥 ห้ามเป็น local variable
//            authSession = ASWebAuthenticationSession(
//                url: authURL,
//                callbackURLScheme: "plantarapp"
//            ) { [weak self] callbackURL, error in
//
//                guard let url = callbackURL else {
//                    print("Google Sign-In cancelled or failed:", error?.localizedDescription ?? "")
//                    return
//                }
//
//                Task {
//                    do {
//                        try await SupabaseManager.shared.client.auth.session(from: url)
//                        print("✅ Google login success")
//                        self?.authSession = nil   // cleanup
//                    } catch {
//                        print("❌ Failed to parse session:", error)
//                    }
//                }
//            }
//
//            authSession?.presentationContextProvider = PresentationAnchorProvider()
//            authSession?.prefersEphemeralWebBrowserSession = true
//
//            let started = authSession?.start() ?? false
//            print("ASWebAuthenticationSession started:", started)
//
//        } catch {
//            print("❌ Google login error:", error.localizedDescription)
//        }
//    }
//}
//
//final class PresentationAnchorProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        UIApplication.shared
//            .connectedScenes
//            .compactMap { $0 as? UIWindowScene }
//            .first(where: { $0.activationState == .foregroundActive })?
//            .keyWindow ?? ASPresentationAnchor()
//    }
//}

@MainActor
final class AuthViewModel: ObservableObject {

    private var authSession: ASWebAuthenticationSession?

    func signInWithGoogle() {
        Task {
            do {
                let authURL = try await SupabaseManager.shared.client.auth
                    .getOAuthSignInURL(
                        provider: .google,
                        redirectTo: URL(string: "plantarapp://login-callback")!
                    )

                authSession = ASWebAuthenticationSession(
                    url: authURL,
                    callbackURLScheme: "plantarapp"
                ) { callbackURL, _ in
                    guard let url = callbackURL else { return }

                    Task {
                        try await SupabaseManager.shared.client.auth.session(from: url)
                        print("✅ Google login success")
                    }
                }

                authSession?.presentationContextProvider =
                    PresentationAnchorProvider()   // ← ตรงนี้
                authSession?.prefersEphemeralWebBrowserSession = true
                authSession?.start()

            } catch {
                print("❌ Google login error:", error)
            }
        }
    }
}

final class PresentationAnchorProvider: NSObject,
    ASWebAuthenticationPresentationContextProviding {

    func presentationAnchor(
        for session: ASWebAuthenticationSession
    ) -> ASPresentationAnchor {

        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .keyWindow ?? ASPresentationAnchor()
    }
}
