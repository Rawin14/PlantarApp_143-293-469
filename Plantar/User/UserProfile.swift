//
//  UserProfile.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 3/11/2568 BE.
//


import SwiftUI
import Supabase

// MARK: - Profile Models

struct ProfileInsert: Encodable {
    let id: String
    let nickname: String
    let age: Int?
    let height: Double?
    let weight: Double?
    let gender: String?
    let birthdate: String?
    let bmi: Double?
}

struct ProfileData: Codable {
    let id: String
    let nickname: String?
    let age: Int?
    let height: Double?
    let weight: Double?
    let gender: String?
    let birthdate: String?
    let created_at: String?
    let updated_at: String?
}

// MARK: - UserProfile Class

@MainActor
class UserProfile: ObservableObject {
    
    // Supabase Client
    // ในไฟล์ UserProfile.swift

    static let supabase = SupabaseClient(
        supabaseURL: URL(string: AppConfig.supabaseURL)!,
        supabaseKey: AppConfig.supabaseAnonKey,
        options: SupabaseClientOptions(
            auth: .init(
                emitLocalSessionAsInitialSession: true // 👈 เพิ่มบรรทัดนี้เพื่อแก้ Warning
            )
        )
    )
    
    // User Data
    @Published var userId: String = ""
    @Published var nickname: String = ""
    @Published var age: Int = 0
    @Published var height: Double = 0.0
    @Published var weight: Double = 0.0
    @Published var gender: String = "female"
    @Published var birthdate: Date = Date()
    @Published var evaluateScore: Double = 0.0
    
    // Loading States
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Save to Supabase
    
    func saveToSupabase() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await Self.supabase.auth.session
            let userId = session.user.id.uuidString
            
            let currentBMI = calculateBMI()
            
            // สร้าง ProfileInsert struct
            let profileData = ProfileInsert(
                id: userId,
                nickname: nickname,
                age: age > 0 ? age : nil,
                height: height > 0 ? height : nil,
                weight: weight > 0 ? weight : nil,
                gender: gender.isEmpty ? nil : gender,
                birthdate: ISO8601DateFormatter().string(from: birthdate),
                bmi: currentBMI > 0 ? currentBMI : nil
            )
            
            // Upsert to Supabase
            try await Self.supabase
                .from("profiles")
                .upsert(profileData)
                .execute()
            
            print("✅ Profile saved to Supabase")
            print("   - Nickname: \(nickname)")
            print("   - Age: \(age)")
            print("   - Height: \(height)")
            print("   - Weight: \(weight)")
            print("✅ Profile saved (with BMI: \(String(format: "%.1f", currentBMI)))")
            
        } catch {
            errorMessage = "บันทึกข้อมูลล้มเหลว: \(error.localizedDescription)"
            print("❌ Error saving: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Load from Supabase
    
    func loadFromSupabase() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await Self.supabase.auth.session
            let userId = session.user.id.uuidString
            
            // Query profile
            let response: [ProfileData] = try await Self.supabase
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            
            if let profile = response.first {
                self.userId = profile.id
                self.nickname = profile.nickname ?? ""
                self.age = profile.age ?? 0
                self.height = profile.height ?? 0.0
                self.weight = profile.weight ?? 0.0
                self.gender = profile.gender ?? "female"
                
                if let birthdateString = profile.birthdate,
                   let date = ISO8601DateFormatter().date(from: birthdateString) {
                    self.birthdate = date
                }
                
                print("✅ Profile loaded from Supabase")
            } else {
                print("ℹ️ No profile found, will create new one")
            }
            
        } catch {
            errorMessage = "โหลดข้อมูลล้มเหลว: \(error.localizedDescription)"
            print("❌ Error loading: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Calculate BMI
    
    func calculateBMI() -> Double {
        guard height > 0, weight > 0 else { return 0 }
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    // MARK: - Delete Profile
    
    func deleteFromSupabase() async {
        do {
            let session = try await Self.supabase.auth.session
            let userId = session.user.id.uuidString
            
            try await Self.supabase
                .from("profiles")
                .delete()
                .eq("id", value: userId)
                .execute()
            
            print("✅ Profile deleted")
            
        } catch {
            errorMessage = "ลบข้อมูลล้มเหลว: \(error.localizedDescription)"
        }
    }
}

// MARK: - Preview Data

#if DEBUG
extension UserProfile {
    static var preview: UserProfile {
        let profile = UserProfile()
        profile.nickname = "John Doe"
        profile.age = 25
        profile.height = 175.0
        profile.weight = 70.0
        profile.gender = "male"
        return profile
    }
    
    static var previewEmpty: UserProfile {
        return UserProfile()
    }
}
#endif
