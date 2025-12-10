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
    private let supabaseURL = "YOUR_SUPABASE_URL" // เช่น https://xxxxx.supabase.co
    private let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )
    }
}
