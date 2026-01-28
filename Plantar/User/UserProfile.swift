////
////  UserProfile.swift
////  Plantar
////
////  Created by Jeerapan Chirachanchai on 3/11/2568 BE.
////
//
//import SwiftUI
//import Supabase
//
//// MARK: - Profile Models
//
//struct ProfileInsert: Encodable {
//    let id: String
//    let nickname: String
//    let age: Int?
//    let height: Double?
//    let weight: Double?
//    let gender: String?
//    let birthdate: String?
//    let bmi: Double?
//    let evaluate_score: Double?
//    let risk_level: String?
//    let has_completed_scan: Bool?
//}
//
//struct ProfileData: Codable {
//    let id: String
//    let nickname: String?
//    let age: Int?
//    let height: Double?
//    let weight: Double?
//    let gender: String?
//    let birthdate: String?
//    let evaluate_score: Double?
//    let has_completed_scan: Bool?
//    let created_at: String?
//    let updated_at: String?
//}
//
//struct DiaryEntryModel: Codable, Identifiable {
//    let id: UUID
//    let user_id: UUID
//    let entry_date: String // แก้จาก date เป็น entry_date
//    let feeling_level: Int
//    let note: String?
//    let created_at: String?
//}
//
//struct FootScanModel: Codable {
//    let id: String
//    let pf_severity: String?
//    let pf_score: Double?
//    let images_url: [String]? // แก้จาก image_url (String) เป็น images_url ([String])
//    let created_at: String?
//    
//    // Helper: ดึงรูปแรกมาโชว์ (ถ้ามี)
//    var firstImage: String? {
//        return images_url?.first
//    }
//}
//
//// MARK: - Shared Models (Video & Exercise)
//
//struct VideoExercise: Identifiable, Codable {
//    var id: String { videoUrl }
//    let thumbnail: String
//    let title: String
//    let duration: String
//    let difficulty: String
//    let videoUrl: String
//}
//
//struct ExerciseStep: Identifiable {
//    let id = UUID()
//    let number: String
//    let title: String
//    let description: String
//}
//
//// MARK: - UserProfile Class
//
//@MainActor
//class UserProfile: ObservableObject {
//    
//    static let shared = UserProfile()
//    
//    static let supabase = SupabaseClient(
//        supabaseURL: URL(string: AppConfig.supabaseURL)!,
//        supabaseKey: AppConfig.supabaseAnonKey,
//        options: SupabaseClientOptions(
//            auth: .init(
//                emitLocalSessionAsInitialSession: true
//            )
//        )
//    )
//    
//    // User Data
//    @Published var userId: String = ""
//    @Published var nickname: String = ""
//    @Published var email: String = ""
//    @Published var age: Int = 0
//    @Published var height: Double = 0.0
//    @Published var weight: Double = 0.0
//    @Published var gender: String = "female"
//    @Published var birthdate: Date = Date()
//    @Published var evaluateScore: Double = 0.0
//    @Published var hasCompletedScan: Bool = false
//    
//    // App Data
//    @Published var latestScan: FootScanModel?
//    @Published var diaryEntries: [DiaryEntryModel] = []
//    @Published var watchedVideoIDs: Set<String> = []
//    
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    
//    // MARK: - Computed Properties
//    
//    var bmiScore: Int {
//        let bmi = calculateBMI()
//        if bmi < 25.0 { return 1 }
//        else if bmi < 30.0 { return 2 }
//        else { return 3 }
//    }
//    
//    var totalRiskScore: Double {
//        return evaluateScore + Double(bmiScore)
//    }
//    
//    var riskSeverity: String {
//        let score = totalRiskScore
//        if score <= 7 { return "low" }
//        else if score <= 13 { return "medium" }
//        else { return "high" }
//    }
//    
//    var videoProgress: Double {
//        let total = getRecommendedVideos().count
//        guard total > 0 else { return 0 }
//        return Double(watchedVideoIDs.count) / Double(total)
//    }
//    
//    func dbDateFormatter() -> DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.calendar = Calendar(identifier: .gregorian)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone.current
//        return formatter
//    }
//    
//    // แก้ไขการคำนวณ Streak
//    var consecutiveDays: Int {
//        let formatter = dbDateFormatter() // เรียกใช้ตัวนี้
//        
//        let sortedDates = diaryEntries
//        // ✅ ใช้ formatter ตัวเดียวกันแปลงกลับ
//            .compactMap { formatter.date(from: $0.entry_date) }
//            .map { Calendar.current.startOfDay(for: $0) }
//            .sorted(by: >)
//        
//        // ... (Logic นับวันเหมือนเดิม) ...
//        let uniqueDates = Array(Set(sortedDates)).sorted(by: >)
//        var streak = 0
//        var currentDate = Calendar.current.startOfDay(for: Date())
//        
//        if !uniqueDates.contains(currentDate) {
//            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
//        }
//        
//        for date in uniqueDates {
//            if Calendar.current.isDate(date, inSameDayAs: currentDate) {
//                streak += 1
//                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
//            } else {
//                break
//            }
//        }
//        return streak
//    }
//    
//    var averageMoodScore: Double {
//        guard !diaryEntries.isEmpty else { return 0.5 }
//        let total = diaryEntries.reduce(0) { $0 + $1.feeling_level }
//        return Double(total) / Double(diaryEntries.count) / 5.0
//    }
//    
//    var feelingBetterPercentage: Double {
//        guard !diaryEntries.isEmpty else { return 0.0 }
//        let goodDays = diaryEntries.filter { $0.feeling_level >= 4 }.count
//        return Double(goodDays) / Double(diaryEntries.count)
//    }
//    
//    // Formatter Helper
//    func dateFormatter() -> DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.calendar = Calendar(identifier: .gregorian)
//        return formatter
//    }
//    
//    // MARK: - Init
//    init() {
//        loadWatchedVideos()
//    }
//    
//    // MARK: - Video Logic
//    func markVideoAsWatched(id: String) {
//        if !watchedVideoIDs.contains(id) {
//            watchedVideoIDs.insert(id)
//            saveWatchedVideos()
//            objectWillChange.send()
//        }
//    }
//    
//    private func saveWatchedVideos() {
//        let array = Array(watchedVideoIDs)
//        UserDefaults.standard.set(array, forKey: "watchedVideoIDs_\(userId)")
//    }
//    
//    private func loadWatchedVideos() {
//        if let saved = UserDefaults.standard.array(forKey: "watchedVideoIDs_\(userId)") as? [String] {
//            self.watchedVideoIDs = Set(saved)
//        }
//    }
//    
//    // MARK: - Video Data
//    func getRecommendedVideos() -> [VideoExercise] {
//        switch riskSeverity {
//        case "high":
//            return [
//                VideoExercise(thumbnail: "video1", title: "ยืดเหยียดเอ็นฝ่าเท้า", duration: "1:56", difficulty: "Easy", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/1.mp4"),
//                VideoExercise(thumbnail: "video2", title: "บริหารข้อเท้า", duration: "0:42", difficulty: "Easy", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/2.mp4"),
//                VideoExercise(thumbnail: "video3", title: "ยืดกล้ามเนื้อน่อง", duration: "3:22", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/3.mp4"),
//                VideoExercise(thumbnail: "video4", title: "เขย่งปลายเท้า", duration: "0:38", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/4.mp4"),
//                VideoExercise(thumbnail: "video5", title: "นวดกดจุดฝ่าเท้า", duration: "4:33", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/5.mp4")
//            ]
//        case "medium":
//            return [
//                VideoExercise(thumbnail: "video3", title: "ยืดกล้ามเนื้อน่อง", duration: "3:22", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/3.mp4"),
//                VideoExercise(thumbnail: "video4", title: "เขย่งปลายเท้า", duration: "1:56", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/4.mp4"),
//                VideoExercise(thumbnail: "video5", title: "นวดกดจุดฝ่าเท้า", duration: "4:33", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/5.mp4")
//            ]
//        default:
//            return [
//                VideoExercise(thumbnail: "video1", title: "ยืดเหยียดเอ็นฝ่าเท้า", duration: "1:56", difficulty: "Easy", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/1.mp4"),
//                VideoExercise(thumbnail: "video2", title: "บริหารข้อเท้า", duration: "0:42", difficulty: "Easy", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/2.mp4")
//            ]
//        }
//    }
//    
//    func getRecommendedExercises() -> [ExerciseStep] {
//        switch riskSeverity {
//        case "high":
//            return [
//                ExerciseStep(number: "1", title: "ประคบเย็น", description: "ใช้น้ำแข็งประคบบริเวณส้นเท้า 15-20 นาที"),
//                ExerciseStep(number: "2", title: "ยืดผ้าขนหนู", description: "ใช้ผ้าขนหนูคล้องปลายเท้าแล้วดึงเข้าหาตัว"),
//                ExerciseStep(number: "3", title: "พักการใช้งาน", description: "หลีกเลี่ยงการยืนนานๆ และใส่รองเท้านุ่มๆ")
//            ]
//        case "medium":
//            return [
//                ExerciseStep(number: "1", title: "ยืดน่องกับกำแพง", description: "ยืนดันกำแพง ขาหลังเหยียดตึง ส้นเท้าติดพื้น"),
//                ExerciseStep(number: "2", title: "คลึงลูกบอล", description: "ใช้ฝ่าเท้ากลิ้งลูกบอลเทนนิสไปมา"),
//                ExerciseStep(number: "3", title: "ฝึกขยำผ้า", description: "ใช้นิ้วเท้าจิกผ้าขนหนูเข้าหาตัว")
//            ]
//        default:
//            return [
//                ExerciseStep(number: "1", title: "ยืดฝ่าเท้า", description: "ใช้มือดึงนิ้วเท้าเข้าหาตัวช้าๆ"),
//                ExerciseStep(number: "2", title: "หมุนข้อเท้า", description: "หมุนข้อเท้าเป็นวงกลมทั้งสองข้าง"),
//                ExerciseStep(number: "3", title: "นวดผ่อนคลาย", description: "นวดบริเวณฝ่าเท้าเบาๆ")
//            ]
//        }
//    }
//    
//    // MARK: - Fetch Profile
//    func fetchCurrentProfile() async throws -> ProfileData? {
//        let session = try await Self.supabase.auth.session
//        let uid = session.user.id.uuidString
//        
//        let response: [ProfileData] = try await Self.supabase
//            .from("profiles")
//            .select()
//            .eq("id", value: uid)
//            .limit(1)
//            .execute()
//            .value
//        
//        let profile = response.first
//        
//        if let profile = profile {
//            await MainActor.run {
//                self.userId = profile.id
//                self.nickname = profile.nickname ?? ""
//                self.age = profile.age ?? 0
//                self.height = profile.height ?? 0.0
//                self.weight = profile.weight ?? 0.0
//                self.gender = profile.gender ?? "female"
//                self.evaluateScore = profile.evaluate_score ?? 0.0
//                self.hasCompletedScan = profile.has_completed_scan ?? false
//                
//                self.loadWatchedVideos()
//            }
//        }
//        return profile
//    }
//    
//    func updateNickname(_ newName: String) async {
//        self.nickname = newName
//        await saveToSupabase()
//    }
//    
//    func setEmail(_ email: String) { self.email = email }
//    
//    func calculateBMI() -> Double {
//        guard height > 0, weight > 0 else { return 0 }
//        let h = height / 100
//        return weight / (h * h)
//    }
//    
//    // MARK: - Save/Load
//    func saveToSupabase() async {
//        isLoading = true
//        errorMessage = nil
//        do {
//            let session = try await Self.supabase.auth.session
//            let userId = session.user.id.uuidString
//            let currentBMI = calculateBMI()
//            let profileData = ProfileInsert(
//                id: userId, nickname: nickname, age: age > 0 ? age : nil, height: height > 0 ? height : nil,
//                weight: weight > 0 ? weight : nil, gender: gender.isEmpty ? nil : gender,
//                birthdate: ISO8601DateFormatter().string(from: birthdate), bmi: currentBMI > 0 ? currentBMI : nil,
//                evaluate_score: self.evaluateScore, risk_level: self.riskSeverity, has_completed_scan: self.hasCompletedScan
//            )
//            try await Self.supabase.from("profiles").upsert(profileData).execute()
//            print("✅ Profile saved")
//        } catch {
//            errorMessage = "บันทึกข้อมูลล้มเหลว: \(error.localizedDescription)"
//            print("❌ Error saving: \(error)")
//        }
//        isLoading = false
//    }
//    
//    func loadFromSupabase() async {
//        isLoading = true
//        errorMessage = nil
//        do {
//            let _ = try await fetchCurrentProfile()
//            await fetchDiaryEntries()
//            await fetchLatestScan()
//            print("✅ Profile & Data loaded")
//        } catch {
//            errorMessage = "โหลดข้อมูลล้มเหลว: \(error.localizedDescription)"
//            print("❌ Error loading: \(error)")
//        }
//        isLoading = false
//    }
//    
//    func deleteFromSupabase() async {
//        do {
//            let session = try await Self.supabase.auth.session
//            let userId = session.user.id.uuidString
//            try await Self.supabase.from("profiles").delete().eq("id", value: userId).execute()
//            print("✅ Profile deleted")
//        } catch {
//            errorMessage = "ลบข้อมูลล้มเหลว: \(error.localizedDescription)"
//        }
//    }
//    
//    // MARK: - Foot Scan
//    func fetchLatestScan() async {
//        do {
//            let session = try await Self.supabase.auth.session
//            let userId = session.user.id.uuidString
//            
//            let response: [FootScanModel] = try await Self.supabase
//                .from("foot_scans")
//                .select("id, pf_severity, pf_score, images_url, created_at")
//                .eq("user_id", value: userId)
//                .order("created_at", ascending: false)
//                .limit(1)
//                .execute()
//                .value
//            
//            if let scan = response.first {
//                await MainActor.run {
//                    self.latestScan = scan
//                }
//            }
//        } catch {
//            print("❌ Error fetching latest scan: \(error)")
//        }
//    }
//    
//    // MARK: - Diary
//    func fetchDiaryEntries() async {
//        do {
//            let session = try await Self.supabase.auth.session
//            let userId = session.user.id.uuidString
//            
//            let response: [DiaryEntryModel] = try await Self.supabase
//                .from("diary_entries")
//                .select()
//                .eq("user_id", value: userId)
//                .order("entry_date", ascending: false)
//                .execute()
//                .value
//            
//            await MainActor.run {
//                self.diaryEntries = response
//            }
//        } catch {
//            print("ℹ️ Diary fetch info: \(error.localizedDescription)")
//        }
//    }
//    
//    func updateScanStatus(isCompleted: Bool) async {
//            self.hasCompletedScan = isCompleted
//            // อัปเดตเฉพาะ field นี้ใน DB เพื่อความรวดเร็ว
//            do {
//                let session = try await Self.supabase.auth.session
//                let userId = session.user.id.uuidString
//                try await Self.supabase.from("profiles")
//                    .update(["has_completed_scan": isCompleted])
//                    .eq("id", value: userId)
//                    .execute()
//                print("✅ Updated scan status to: \(isCompleted)")
//            } catch {
//                print("❌ Failed to update scan status: \(error)")
//            }
//        }
//}
//
//// MARK: - Extension Check Profile
//extension ProfileData {
//    var isComplete: Bool {
//        // ✅ ต้องกรอกข้อมูลครบ AND สแกนเสร็จแล้ว
//        return (weight ?? 0) > 0
//            && (height ?? 0) > 0
//            && (age ?? 0) > 0
//            && (has_completed_scan == true)
//    }
//}
//// MARK: - Preview Data
//#if DEBUG
//extension UserProfile {
//    static var preview: UserProfile {
//        let profile = UserProfile()
//        profile.nickname = "John Doe"
//        profile.age = 25
//        profile.height = 175.0
//        profile.weight = 70.0
//        profile.gender = "male"
//        return profile
//    }
//    static var previewEmpty: UserProfile { return UserProfile() }
//}
//#endif

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
    let has_completed_scan: Bool?
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
    let has_completed_scan: Bool?
    let created_at: String?
    let updated_at: String?
}
struct DiaryEntryModel: Codable, Identifiable {
    let id: UUID
    let user_id: UUID
    let entry_date: String // แก้จาก date เป็น entry_date
    let feeling_level: Int
    let note: String?
    let created_at: String?
}
struct FootScanModel: Codable {
    let id: String
    let pf_severity: String?
    let pf_score: Double?
    let images_url: [String]? // แก้จาก image_url (String) เป็น images_url ([String])
    let created_at: String?
    
    // Helper: ดึงรูปแรกมาโชว์ (ถ้ามี)
    var firstImage: String? {
        return images_url?.first
    }
}
// MARK: - Shared Models (Video & Exercise)
struct VideoExercise: Identifiable, Codable {
    var id: String { videoUrl }
    let thumbnail: String
    let title: String
    let duration: String
    let difficulty: String
    let videoUrl: String
}
struct ExerciseStep: Identifiable {
    let id = UUID()
    let number: String
    let title: String
    let description: String
}
// MARK: - UserProfile Class
@MainActor
class UserProfile: ObservableObject {
    
    static let shared = UserProfile()
    
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
    @Published var userId: String = "" {
        didSet {
            // ✅ เมื่อ userId เปลี่ยน ให้โหลด watchedVideos ใหม่
            if !userId.isEmpty {
                loadWatchedVideos()
            }
        }
    }
    @Published var nickname: String = ""
    @Published var email: String = ""
    @Published var age: Int = 0
    @Published var height: Double = 0.0
    @Published var weight: Double = 0.0
    @Published var gender: String = "female"
    @Published var birthdate: Date = Date()
    @Published var evaluateScore: Double = 0.0
    @Published var hasCompletedScan: Bool = false
    
    // App Data
    @Published var latestScan: FootScanModel?
    @Published var diaryEntries: [DiaryEntry] = []
    @Published var watchedVideoIDs: Set<String> = [] {
        didSet {
            // ✅ เมื่อ watchedVideoIDs เปลี่ยน ให้บันทึกทันที
            if !userId.isEmpty {
                saveWatchedVideos()
            }
        }
    }
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    
    // MARK: - Computed Properties
    
    var bmiScore: Int {
        let bmi = calculateBMI()
        if bmi < 25.0 { return 1 }
        else if bmi < 30.0 { return 2 }
        else { return 3 }
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
    
    // ✅ แก้ไข: คำนวณ progress ถูกต้อง และรองรับกรณีไม่มีวิดีโอ
    var videoProgress: Double {
        let total = getRecommendedVideos().count
        guard total > 0 else { return 0.0 } // ✅ ถ้าไม่มีวิดีโอแนะนำ = 0%
        return Double(watchedVideoIDs.count) / Double(total)
    }
    
    func dbDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    // แก้ไขการคำนวณ Streak
    var consecutiveDays: Int {
        let formatter = dbDateFormatter() // เรียกใช้ตัวนี้
        
        let sortedDates = diaryEntries
            .map { Calendar.current.startOfDay(for: $0.date) }
            .map { Calendar.current.startOfDay(for: $0) }
            .sorted(by: >)
        
        let uniqueDates = Array(Set(sortedDates)).sorted(by: >)
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        if !uniqueDates.contains(currentDate) {
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        for date in uniqueDates {
            if Calendar.current.isDate(date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        return streak
    }
    
    var averageMoodScore: Double {
        guard !diaryEntries.isEmpty else { return 0 }
        let total = diaryEntries.reduce(0.0) { $0 + $1.normalizedScore }
        return total / Double(diaryEntries.count)
    }
    var feelingBetterPercentage: Double {
        guard diaryEntries.count > 1 else { return 0 }
        let sorted = diaryEntries.sorted { $0.date < $1.date }
        var improveCount = 0
        for i in 1..<sorted.count {
            if sorted[i].feelingLevel > sorted[i - 1].feelingLevel {
                improveCount += 1
            }
        }
        return Double(improveCount) / Double(sorted.count - 1)
    }
    var weeklyMoodData: [(date: Date, score: Double?)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            let entry = diaryEntries.first {
                calendar.isDate($0.date, inSameDayAs: day)
            }
            return (day, entry?.normalizedScore)
        }
    }
    
    var last7DaysEntries: [DiaryEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let start = calendar.date(byAdding: .day, value: -6, to: today) else {
            return []
        }
        return diaryEntries
            .filter {
                let d = calendar.startOfDay(for: $0.date)
                return d >= start && d <= today
            }
            .sorted { $0.date < $1.date }
    }
    // Formatter Helper
    func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }
    
    // MARK: - Init
    init() {
        // ✅ ไม่โหลด watchedVideos ที่นี่ เพราะ userId ยังไม่มี
        // จะโหลดเมื่อ userId ถูกตั้งค่าแล้ว (ดู didSet ข้างบน)
    }
    
    // MARK: - Video Logic
    
    // ✅ แก้ไข: ทำให้ชัดเจนและบันทึกอัตโนมัติ
    func markVideoAsWatched(id: String) {
        guard !id.isEmpty else { return }
        
        if !watchedVideoIDs.contains(id) {
            watchedVideoIDs.insert(id)
            print("✅ Video marked as watched: \(id)")
            print("📊 Progress: \(watchedVideoIDs.count)/\(getRecommendedVideos().count)")
            // ✅ การบันทึกจะทำงานอัตโนมัติใน didSet ของ watchedVideoIDs
        }
    }
    
    // ✅ แก้ไข: ใช้ userId เป็น key
    private func saveWatchedVideos() {
        guard !userId.isEmpty else {
            print("⚠️ Cannot save watched videos: userId is empty")
            return
        }
        
        let array = Array(watchedVideoIDs)
        let key = "watchedVideoIDs_\(userId)"
        UserDefaults.standard.set(array, forKey: key)
        print("💾 Saved \(array.count) watched videos for user: \(userId)")
    }
    
    // ✅ แก้ไข: โหลดเฉพาะเมื่อ userId มีค่า
    private func loadWatchedVideos() {
        guard !userId.isEmpty else {
            print("⚠️ Cannot load watched videos: userId is empty")
            return
        }
        
        let key = "watchedVideoIDs_\(userId)"
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            self.watchedVideoIDs = Set(saved)
            print("📂 Loaded \(saved.count) watched videos for user: \(userId)")
        } else {
            // ✅ ผู้ใช้ใหม่: เริ่มที่ Set ว่าง
            self.watchedVideoIDs = []
            print("🆕 New user - initialized empty watched videos")
        }
    }
    
    // ✅ เพิ่ม: ฟังก์ชันล้างข้อมูลวิดีโอ (สำหรับ testing หรือ reset)
    func resetWatchedVideos() {
        watchedVideoIDs.removeAll()
        if !userId.isEmpty {
            UserDefaults.standard.removeObject(forKey: "watchedVideoIDs_\(userId)")
            print("🔄 Reset watched videos for user: \(userId)")
        }
    }
    
        // MARK: - Video Data
        func getRecommendedVideos() -> [VideoExercise] {
            switch riskSeverity {
            case "high":
                return [
                    VideoExercise(thumbnail: "video1", title: "ยืดเหยียดเอ็นฝ่าเท้า", duration: "1:56", difficulty: "Easy", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/1.mp4"),
                    VideoExercise(thumbnail: "video2", title: "บริหารข้อเท้า", duration: "0:42", difficulty: "Easy", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/2.mp4"),
                    VideoExercise(thumbnail: "video3", title: "ยืดกล้ามเนื้อน่อง", duration: "3:22", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/3.mp4"),
                    VideoExercise(thumbnail: "video4", title: "เขย่งปลายเท้า", duration: "0:38", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/4.mp4"),
                    VideoExercise(thumbnail: "video5", title: "นวดกดจุดฝ่าเท้า", duration: "4:33", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/5.mp4")
                ]
            case "medium":
                return [
                    VideoExercise(thumbnail: "video3", title: "ยืดกล้ามเนื้อน่อง", duration: "3:22", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/3.mp4"),
                    VideoExercise(thumbnail: "video4", title: "เขย่งปลายเท้า", duration: "1:56", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/4.mp4"),
                    VideoExercise(thumbnail: "video5", title: "นวดกดจุดฝ่าเท้า", duration: "4:33", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/5.mp4")
                ]
            default:
                return [
                    VideoExercise(thumbnail: "video1", title: "ยืดเหยียดเอ็นฝ่าเท้า", duration: "1:56", difficulty: "Easy", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/1.mp4"),
                    VideoExercise(thumbnail: "video2", title: "บริหารข้อเท้า", duration: "0:42", difficulty: "Easy", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/2.mp4")
                ]
            }
        }
    
    func getRecommendedExercises() -> [ExerciseStep] {
        switch riskSeverity {
        case "high":
            return [
                ExerciseStep(number: "1", title: "ประคบเย็น", description: "ใช้น้ำแข็งประคบบริเวณส้นเท้า 15-20 นาที"),
                ExerciseStep(number: "2", title: "ยืดผ้าขนหนู", description: "ใช้ผ้าขนหนูคล้องปลายเท้าแล้วดึงเข้าหาตัว"),
                ExerciseStep(number: "3", title: "พักการใช้งาน", description: "หลีกเลี่ยงการยืนนานๆ และใส่รองเท้านุ่มๆ")
            ]
        case "medium":
            return [
                ExerciseStep(number: "1", title: "ยืดน่องกับกำแพง", description: "ยืนดันกำแพง ขาหลังเหยียดตึง ส้นเท้าติดพื้น"),
                ExerciseStep(number: "2", title: "คลึงลูกบอล", description: "ใช้ฝ่าเท้ากลิ้งลูกบอลเทนนิสไปมา"),
                ExerciseStep(number: "3", title: "ฝึกขยำผ้า", description: "ใช้นิ้วเท้าจิกผ้าขนหนูเข้าหาตัว")
            ]
        default:
            return [
                ExerciseStep(number: "1", title: "ยืดฝ่าเท้า", description: "ใช้มือดึงนิ้วเท้าเข้าหาตัวช้าๆ"),
                ExerciseStep(number: "2", title: "หมุนข้อเท้า", description: "หมุนข้อเท้าเป็นวงกลมทั้งสองข้าง"),
                ExerciseStep(number: "3", title: "นวดผ่อนคลาย", description: "นวดบริเวณฝ่าเท้าเบาๆ")
            ]
        }
    }
    
    // MARK: - Fetch Profile
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
                self.userId = profile.id // ✅ ตั้งค่า userId ก่อน (จะ trigger didSet)
                self.nickname = profile.nickname ?? ""
                self.age = profile.age ?? 0
                self.height = profile.height ?? 0.0
                self.weight = profile.weight ?? 0.0
                self.gender = profile.gender ?? "female"
                self.evaluateScore = profile.evaluate_score ?? 0.0
                self.hasCompletedScan = profile.has_completed_scan ?? false
                
                // ✅ ไม่ต้องเรียก loadWatchedVideos() ที่นี่
                // เพราะ didSet ของ userId จะเรียกให้อัตโนมัติแล้ว
            }
        }
        return profile
    }
    
    func updateNickname(_ newName: String) async {
        self.nickname = newName
        await saveToSupabase()
    }
    
    func setEmail(_ email: String) { self.email = email }
    
    func calculateBMI() -> Double {
        guard height > 0, weight > 0 else { return 0 }
        let h = height / 100
        return weight / (h * h)
    }
    
    // MARK: - Save/Load
    func saveToSupabase() async {
        isLoading = true
        errorMessage = nil
        do {
            let session = try await Self.supabase.auth.session
            let userId = session.user.id.uuidString
            let currentBMI = calculateBMI()
            let profileData = ProfileInsert(
                id: userId, nickname: nickname, age: age > 0 ? age : nil, height: height > 0 ? height : nil,
                weight: weight > 0 ? weight : nil, gender: gender.isEmpty ? nil : gender,
                birthdate: ISO8601DateFormatter().string(from: birthdate), bmi: currentBMI > 0 ? currentBMI : nil,
                evaluate_score: self.evaluateScore, risk_level: self.riskSeverity, has_completed_scan: self.hasCompletedScan
            )
            try await Self.supabase.from("profiles").upsert(profileData).execute()
            print("✅ Profile saved")
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
            await fetchDiaryEntries()
            await fetchLatestScan()
            print("✅ Profile & Data loaded")
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
            try await Self.supabase.from("profiles").delete().eq("id", value: userId).execute()
            print("✅ Profile deleted")
        } catch {
            errorMessage = "ลบข้อมูลล้มเหลว: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Foot Scan
    func fetchLatestScan() async {
        do {
            let session = try await Self.supabase.auth.session
            let userId = session.user.id.uuidString
            
            let response: [FootScanModel] = try await Self.supabase
                .from("foot_scans")
                .select("id, pf_severity, pf_score, images_url, created_at")
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
                .value
            
            if let scan = response.first {
                await MainActor.run {
                    self.latestScan = scan
                }
            }
        } catch {
            print("❌ Error fetching latest scan: \(error)")
        }
    }
    
    // MARK: - Diary
    func fetchDiaryEntries() async {
        do {
            let session = try await Self.supabase.auth.session
            let userId = session.user.id.uuidString
            
            let response: [DiaryEntryDB] = try await Self.supabase
                .from("diary_entries")
                .select()
                .eq("user_id", value: userId)
                .order("entry_date", ascending: false)
                .execute()
                .value
            await MainActor.run {
                self.diaryEntries = response.map { DiaryEntry(from: $0) }
            }
        } catch {
            print("ℹ️ Diary fetch info: \(error.localizedDescription)")
        }
    }
    
    func updateScanStatus(isCompleted: Bool) async {
        self.hasCompletedScan = isCompleted
        do {
            let session = try await Self.supabase.auth.session
            let userId = session.user.id.uuidString
            try await Self.supabase.from("profiles")
                .update(["has_completed_scan": isCompleted])
                .eq("id", value: userId)
                .execute()
            print("✅ Updated scan status to: \(isCompleted)")
        } catch {
            print("❌ Failed to update scan status: \(error)")
        }
    }
}
// MARK: - Extension Check Profile
extension ProfileData {
    var isComplete: Bool {
        return (weight ?? 0) > 0
            && (height ?? 0) > 0
            && (age ?? 0) > 0
            && (has_completed_scan == true)
    }
}
// MARK: - Preview Data
#if DEBUG
extension UserProfile {
    static var preview: UserProfile {
        let profile = UserProfile()
        profile.userId = "preview-user-123"
        profile.nickname = "John Doe"
        profile.age = 25
        profile.height = 175.0
        profile.weight = 70.0
        profile.gender = "male"
        profile.evaluateScore = 5.0
        profile.hasCompletedScan = true
        return profile
    }
    static var previewEmpty: UserProfile { return UserProfile() }
}
#endif

