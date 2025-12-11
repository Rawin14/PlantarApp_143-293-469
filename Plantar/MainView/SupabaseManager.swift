//
//  SupabaseManager.swift
//  Plantar
//
//  Created by ncp on 10/12/2568 BE.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    // ⚠️ แทนที่ด้วยค่าจริงจาก Supabase Dashboard
    private let supabaseURL = "https://wwdvyjvziujyaymwmrcr.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3ZHZ5anZ6aXVqeWF5bXdtcmNyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzM4MTI2NiwiZXhwIjoyMDc4OTU3MjY2fQ.1vCot8-iIXvsmBIkDxPZQ4vPP-OuSHgYvfhAIUeJfwY"
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )
    }
}
