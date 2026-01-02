//
//  AuthViewModel.swift
//  Plantar
//
//  Created by ncp on 2/1/2569 BE.
//

import Foundation
import SwiftUI
import AuthenticationServices
import Supabase

class AuthViewModel: ObservableObject {
    
    func signInWithGoogle() async {
        do {
            let authURL = try await SupabaseManager.shared.client.auth.getOAuthSignInURL(
                provider: .google,
                redirectTo: URL(string: "plantarapp://login-callback")!
            )
            
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "plantarapp"
            ) { callbackURL, error in
                guard let url = callbackURL else { return }
                
                Task {
                    do {
                        try await SupabaseManager.shared.client.auth.session(from: url)
                        print("Google login success")
                    } catch {
                        print("Failed to parse session: \(error)")
                    }
                }
            }
            
            session.presentationContextProvider = PresentationAnchorProvider()
            session.prefersEphemeralWebBrowserSession = true
            session.start()
            
        } catch {
            print("Google login error:", error.localizedDescription)
        }
    }
}

// ใช้สำหรับรองรับหน้าต่าง ASWebAuthenticationSession
class PresentationAnchorProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? ASPresentationAnchor()
    }
}

