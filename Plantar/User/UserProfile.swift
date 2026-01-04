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
    let evaluate_score: Double?
    let risk_level: String?
}

struct ProfileData: Codable {
    let id: String
    let nickname: String?
    let age: Int?
    let height: Double?
    let weight: Double?
    let gender: String?
    let birthdate: String?
    let evaluate_score: Double?
    let created_at: String?
    let updated_at: String?
}

// ⚠️ ลบ struct DiaryEntryModel ออกแล้ว

struct FootScanModel: Codable {
    let id: String
    let pf_severity: String?
    let pf_score: Double?
    let image_url: String?
    let created_at: String?
}

// MARK: - UserProfile Class

@MainActor
class UserProfile: ObservableObject {
    
    // Singleton Access
    static let shared = UserProfile()
    
    // Supabase Client
    static let supabase = SupabaseClient(
        supabaseURL: URL(string: AppConfig.supabaseURL)!,
        supabaseKey: AppConfig.supabaseAnonKey,
        options: SupabaseClientOptions(
            auth: .init(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
    
    // User Data
    @Published var userId: String = ""
    @Published var nickname: String = ""
    @Published var email: String = ""
    @Published var age: Int = 0
    @Published var height: Double = 0.0
    @Published var weight: Double = 0.0
    @Published var gender: String = "female"
    @Published var birthdate: Date = Date()
    @Published var evaluateScore: Double = 0.0
    
    // App Data
    @Published var latestScan: FootScanModel? // เก็บผลสแกนล่าสุด
    // ⚠️ ลบ diaryEntries ออกแล้ว (ใช้ DiaryService แทน)
    
    // Loading States
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties (Risk Level)
    
    var bmiScore: Int {
        let bmi = calculateBMI()
        if bmi < 25.0 { return 1 } // ต่ำ/ปกติ
        else if bmi < 30.0 { return 2 } // เริ่มอ้วน
        else { return 3 } // อ้วน
    }
    
    var totalRiskScore: Double {
        return evaluateScore + Double(bmiScore)
    }
    
    var riskSeverity: String {
        let score = totalRiskScore
        if score <= 7 { return "low" }
        else if score <= 13 { return "medium" }
        else { return "high" }
    }
    
    // MARK: - Helper Functions
    
    // ฟังก์ชันสำหรับ AuthManager เพื่อดึงข้อมูลมาเช็คสถานะ
    func fetchCurrentProfile() async throws -> ProfileData? {
        let session = try await Self.supabase.auth.session
        let uid = session.user.id.uuidString
        
        let response: [ProfileData] = try await Self.supabase
            .from("profiles")
            .select()
            .eq("id", value: uid)
            .limit(1)
            .execute()
            .value
            
        let profile = response.first
        
        if let profile = profile {
            await MainActor.run {
                self.userId = profile.id
                self.nickname = profile.nickname ?? ""
                self.age = profile.age ?? 0
                self.height = profile.height ?? 0.0
                self.weight = profile.weight ?? 0.0
                self.gender = profile.gender ?? "female"
                self.evaluateScore = profile.evaluate_score ?? 0.0
            }
        }
        return profile
    }
    
    func calculateBMI() -> Double {
        guard height > 0, weight > 0 else { return 0 }
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    func setEmail(_ email: String) {
        self.email = email
    }

    // MARK: - Save/Load Profile
    
    func saveToSupabase() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await Self.supabase.auth.session
            let userId = session.user.id.uuidString
            
            let currentBMI = calculateBMI()
            
            let profileData = ProfileInsert(
                id: userId,
                nickname: nickname,
                age: age > 0 ? age : nil,
                height: height > 0 ? height : nil,
                weight: weight > 0 ? weight : nil,
                gender: gender.isEmpty ? nil : gender,
                birthdate: ISO8601DateFormatter().string(from: birthdate),
                bmi: currentBMI > 0 ? currentBMI : nil,
                evaluate_score: self.evaluateScore,
                risk_level: self.riskSeverity
            )
            
            try await Self.supabase
                .from("profiles")
                .upsert(profileData)
                .execute()
            
            print("✅ Profile saved to Supabase")
            
        } catch {
            errorMessage = "บันทึกข้อมูลล้มเหลว: \(error.localizedDescription)"
            print("❌ Error saving: \(error)")
        }
        
        isLoading = false
    }
    
    func loadFromSupabase() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await fetchCurrentProfile()
            print("✅ Profile loaded via fetchCurrentProfile")
        } catch {
            errorMessage = "โหลดข้อมูลล้มเหลว: \(error.localizedDescription)"
            print("❌ Error loading: \(error)")
        }
        
        isLoading = false
    }
    
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
    
    // MARK: - Foot Scan (ยังเก็บไว้ที่นี่ได้)
    
    func fetchLatestScan() async {
        do {
            let session = try await Self.supabase.auth.session
            let userId = session.user.id.uuidString
            
            let response: [FootScanModel] = try await Self.supabase
                .from("foot_scans")
                .select("id, pf_severity, pf_score, created_at")
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
                .value
            
            if let scan = response.first {
                self.latestScan = scan
            }
        } catch {
            print("❌ Error fetching latest scan: \(error)")
        }
    }
    
    func updateNickname(_ newName: String) async {
            self.nickname = newName
            await saveToSupabase()
        }
    // ⚠️ ลบฟังก์ชัน fetchDiaryEntries และ saveDiaryEntry ออกแล้ว
    // ให้เรียกใช้จาก DiaryService แทน
}

// MARK: - Extension Check Profile
extension ProfileData {
    var isComplete: Bool {
        return (weight ?? 0) > 0 && (height ?? 0) > 0 && (age ?? 0) > 0
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

