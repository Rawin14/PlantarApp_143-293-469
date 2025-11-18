//
//  Config.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 19/11/2568 BE.
//

import Foundation

struct AppConfig {
    // Supabase Configuration
    static let supabaseURL = "https://wwdvyjvziujyaymwmrcr.supabase.co" // 👈 แก้ไข
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3ZHZ5anZ6aXVqeWF5bXdtcmNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzODEyNjYsImV4cCI6MjA3ODk1NzI2Nn0.MiXSrh5Oal5XN7fyV5Z0mM5CnTotLt7-hGU7hxAU7ns" // 👈 แก้ไข (ใช้ anon key)
    
    // API Gateway (ถ้า deploy แล้ว)
    //        static let apiGatewayURL = "https://plantar-api-gateway.onrender.com"
    
    // ML Service (ถ้า deploy แล้ว)
    //        static let mlServiceURL = "https://plantar-ml-service.onrender.com"
    
    // Local Development (uncomment ถ้ารัน local)
    static let apiGatewayURL = "http://localhost:4000"
    static let mlServiceURL = "http://localhost:8000"
}
