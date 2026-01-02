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

struct DiaryEntryModel: Codable, Identifiable {
    let id: UUID
    let user_id: UUID
    let date: String // ISO String
    let feeling_level: Int
    let note: String?
    let created_at: String?
}

struct FootScanModel: Codable {
    let id: String
    let pf_severity: String?
    let pf_score: Double?
    let created_at: String?
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
    @Published var email: String = ""
    @Published var age: Int = 0
    @Published var height: Double = 0.0
    @Published var weight: Double = 0.0
    @Published var gender: String = "female"
    @Published var birthdate: Date = Date()
    @Published var evaluateScore: Double = 0.0
    
    // App Data
    @Published var latestScan: FootScanModel? // เก็บผลสแกนล่าสุด
    @Published var diaryEntries: [DiaryEntryModel] = [] // เก็บไดอารี่
    
    // Loading States
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var bmiScore: Int {
            let bmi = calculateBMI()
            if bmi < 25.0 {
                return 1 // ต่ำ/ปกติ (Low Risk)
            } else if bmi < 30.0 {
                return 2 // เริ่มอ้วน (Medium Risk)
            } else {
                return 3 // อ้วน (High Risk)
            }
        }
    
    var totalRiskScore: Double {
            return evaluateScore + Double(bmiScore)
        }
    
    var riskSeverity: String {
            let score = totalRiskScore
            // เกณฑ์คะแนน (ปรับตามความเหมาะสมของคะแนนเต็ม ~23)
            if score <= 7 {
                return "low"
            } else if score <= 13 {
                return "medium"
            } else {
                return "high"
            }
        }
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
                bmi: currentBMI > 0 ? currentBMI : nil,
                evaluate_score: self.evaluateScore,
                risk_level: self.riskSeverity
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
                self.evaluateScore = profile.evaluate_score ?? 0.0
                
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
    // เพิ่มฟังก์ชันดึงข้อมูล Scan ล่าสุด
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
    
    // เพิ่มฟังก์ชันดึง Diary
    func fetchDiaryEntries() async {
        do {
            let session = try await Self.supabase.auth.session
            let userId = session.user.id.uuidString
            
            let response: [DiaryEntryModel] = try await Self.supabase
                .from("diary_entries") // สมมติว่ามีตารางนี้
                .select()
                .eq("user_id", value: userId)
                .order("date", ascending: false)
                .execute()
                .value
            
            self.diaryEntries = response
        } catch {
            print("ℹ️ Diary fetch info: \(error.localizedDescription) (Table might not exist yet)")
        }
    }
    
    // เพิ่มฟังก์ชันบันทึก Diary
    func saveDiaryEntry(date: Date, feeling: Int, note: String) async {
        do {
            let session = try await Self.supabase.auth.session
            let userId = session.user.id
            
            let newEntry = DiaryEntryModel(
                id: UUID(),
                user_id: userId,
                date: ISO8601DateFormatter().string(from: date),
                feeling_level: feeling,
                note: note,
                created_at: nil
            )
            
            try await Self.supabase
                .from("diary_entries")
                .insert(newEntry)
                .execute()
            
            await fetchDiaryEntries() // รีโหลดข้อมูล
            print("✅ Diary saved")
        } catch {
            print("❌ Error saving diary: \(error)")
        }
    }
    
    // Helper สำหรับดึง Email (เรียกตอน Login สำเร็จ)
    func setEmail(_ email: String) {
        self.email = email
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
