//
//  DiaryService.swift
//  Plantar
//
//  Created by ncp on 10/12/2568 BE.
//

//
//import Foundation
//import Supabase
//
//enum DiaryError: Error {
//    case invalidUserId
//    case saveFailed(String)
//    case fetchFailed(String)
//    case deleteFailed(String)
//    case notAuthenticated // เพิ่มกรณีไม่ได้ล็อกอิน
//}
//
///// DTO สำหรับการอัปเดต (ชื่อต่างจาก `DiaryEntryInsert` เพื่อไม่ชน)
//struct DiaryEntryUpdateDTO: Encodable {
//    let feelingLevel: Int
//    let note: String?
//    let updatedAt: String
//    
//    enum CodingKeys: String, CodingKey {
//        case feelingLevel = "feeling_level"
//        case note
//        case updatedAt = "updated_at"
//    }
//}
//
//class DiaryService {
//    
//    
//    private var dbDateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.calendar = Calendar(identifier: .gregorian)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone.current
//        return formatter
//    }
//    
//    // MARK: - Helper: Get Current User ID
//    // ฟังก์ชันช่วยดึง User ID จาก Supabase Auth Session
//    private func getCurrentUserId() async throws -> UUID {
//        do {
//            let session = try await UserProfile.supabase.auth.session
//            return session.user.id
//        } catch {
//            throw DiaryError.notAuthenticated
//        }
//    }
//    
//    // MARK: - Save Diary Entry
//    func saveDiaryEntry(date: Date, feelingLevel: Int, note: String?) async throws {
//        let userId = try await getCurrentUserId()
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let dateString = dbDateFormatter.string(from: date)
//        
//        // ใช้ Model จากไฟล์ DiaryModels.swift (ต้องมีไฟล์นั้นอยู่)
//        let entry = DiaryEntryInsert(
//            userId: userId,
//            entryDate: dateString,
//            feelingLevel: feelingLevel,
//            note: note?.isEmpty == true ? nil : note
//        )
//        
//        do {
//            try await UserProfile.supabase // ✅ แก้ไข Syntax: เพิ่ม UserProfile.supabase
//                .from("diary_entries")
//                .insert(entry)
//                .execute()
//            
//            print("✅ บันทึกสำเร็จ: \(dateString) - Level \(feelingLevel)")
//        } catch {
//            print("❌ บันทึกล้มเหลว: \(error.localizedDescription)")
//            throw DiaryError.saveFailed(error.localizedDescription)
//        }
//    }
//    
//    // MARK: - Fetch Entries for Month
//    func fetchEntriesForMonth(date: Date) async throws -> [DiaryEntry] {
//        let userId = try await getCurrentUserId()
//        
//        // ✅ ใช้ Gregorian เสมอในการคำนวณวันต้นเดือน/ท้ายเดือน เพื่อให้ตรงกับ DB
//        var calendar = Calendar(identifier: .gregorian)
//        calendar.timeZone = TimeZone.current
//        
//        let components = calendar.dateComponents([.year, .month], from: date)
//        
//        guard let startOfMonth = calendar.date(from: components),
//              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
//        else { return [] }
//        
//        // ✅ ใช้ Formatter ตัวเดิม (ที่เป็น Gregorian อยู่แล้ว)
//        let startDate = dbDateFormatter.string(from: startOfMonth)
//        let endDate = dbDateFormatter.string(from: endOfMonth)
//        
//        print("Fetching range: \(startDate) - \(endDate)") // Debug ดูช่วงเวลา
//        
//        do {
//            let response: [DiaryEntryDB] = try await UserProfile.supabase
//                .from("diary_entries")
//                .select()
//                .eq("user_id", value: userId.uuidString)
//                .gte("entry_date", value: startDate)
//                .lte("entry_date", value: endDate)
//                .order("entry_date", ascending: false)
//                .execute()
//                .value
//            
//            print("📌 ดึงเดือนนี้: \(response.count) รายการ")
//            return response.map { DiaryEntry(from: $0) }
//        } catch {
//            throw DiaryError.fetchFailed(error.localizedDescription)
//        }
//    }
//    
//    // MARK: - Fetch All Entries (statistics)
//    func fetchAllEntries() async throws -> [DiaryEntry] {
//        let userId = try await getCurrentUserId() // ✅ ดึง ID จริง
//        
//        do {
//            let response: [DiaryEntryDB] = try await UserProfile.supabase // ✅ แก้ไข Syntax
//                .from("diary_entries")
//                .select()
//                .eq("user_id", value: userId.uuidString)
//                .order("entry_date", ascending: false)
//                .execute()
//                .value
//            
//            return response.map { DiaryEntry(from: $0) }
//        } catch {
//            throw DiaryError.fetchFailed(error.localizedDescription)
//        }
//    }
//    
//    // MARK: - Check if Entry Exists
//    func entryExists(for date: Date) async throws -> Bool {
//        // กรณีเช็ค entry อาจจะยังไม่ต้อง throw error ถ้าไม่ได้ login (คืนค่า false ไปเลย)
//        guard let userId = try? await getCurrentUserId() else { return false }
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let dateString = dbDateFormatter.string(from: date)
//        
//        do {
//            let response: [DiaryEntryDB] = try await UserProfile.supabase // ✅ แก้ไข Syntax
//                .from("diary_entries")
//                .select()
//                .eq("user_id", value: userId.uuidString)
//                .eq("entry_date", value: dateString)
//                .execute()
//                .value
//            
//            return !response.isEmpty
//        } catch {
//            // ถ้า Error อื่นๆ ให้ถือว่าหาไม่เจอ
//            print("Warning: Failed to check entry existence: \(error)")
//            return false
//        }
//    }
//    
//    // MARK: - Update Diary Entry
//    func updateDiaryEntry(date: Date, feelingLevel: Int, note: String?) async throws {
//        let userId = try await getCurrentUserId() // ✅ ดึง ID จริง
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let dateString = dbDateFormatter.string(from: date)
//        
//        let updateModel = DiaryEntryUpdateDTO(
//            feelingLevel: feelingLevel,
//            note: note?.isEmpty == true ? nil : note,
//            updatedAt: ISO8601DateFormatter().string(from: Date())
//        )
//        
//        do {
//            try await UserProfile.supabase // ✅ แก้ไข Syntax
//                .from("diary_entries")
//                .update(updateModel)
//                .eq("user_id", value: userId.uuidString)
//                .eq("entry_date", value: dateString)
//                .execute()
//            
//            print("✅ อัปเดตสำเร็จ: \(dateString)")
//        } catch {
//            throw DiaryError.saveFailed(error.localizedDescription)
//        }
//    }
//    
//    // MARK: - Delete Entry
//    func deleteDiaryEntry(date: Date) async throws {
//        let userId = try await getCurrentUserId() // ✅ ดึง ID จริง
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let dateString = dbDateFormatter.string(from: date)
//        
//        do {
//            try await UserProfile.supabase // ✅ แก้ไข Syntax
//                .from("diary_entries")
//                .delete()
//                .eq("user_id", value: userId.uuidString)
//                .eq("entry_date", value: dateString)
//                .execute()
//            
//            print("🗑️ ลบสำเร็จ: \(dateString)")
//        } catch {
//            throw DiaryError.deleteFailed(error.localizedDescription)
//        }
//    }
//}




import Foundation
import Supabase

enum DiaryError: Error {
    case invalidUserId
    case saveFailed(String)
    case fetchFailed(String)
    case deleteFailed(String)
    case notAuthenticated
}

/// DTO สำหรับการอัปเดต
struct DiaryEntryUpdateDTO: Encodable {
    let feelingLevel: Int
    let feelingComparison: String? // ✅ เพิ่ม
    let note: String?
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case feelingLevel = "feeling_level"
        case feelingComparison = "feeling_comparison" // ✅ เพิ่ม
        case note
        case updatedAt = "updated_at"
    }
}

class DiaryService {
    
    private var dbDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    // MARK: - Helper: Get Current User ID
    private func getCurrentUserId() async throws -> UUID {
        do {
            let session = try await UserProfile.supabase.auth.session
            return session.user.id
        } catch {
            throw DiaryError.notAuthenticated
        }
    }
    
    // MARK: - Save Diary Entry
    // ✅ เพิ่ม parameter feelingComparison
    func saveDiaryEntry(date: Date, feelingLevel: Int, feelingComparison: FeelingComparison?, note: String?) async throws {
        let userId = try await getCurrentUserId()
        let dateString = dbDateFormatter.string(from: date)
        
        let entry = DiaryEntryInsert(
            userId: userId,
            entryDate: dateString,
            feelingLevel: feelingLevel,
            feelingComparison: feelingComparison?.rawValue, // ✅ เพิ่ม
            note: note?.isEmpty == true ? nil : note
        )
        
        do {
            try await UserProfile.supabase
                .from("diary_entries")
                .insert(entry)
                .execute()
            
            print("✅ บันทึกสำเร็จ: \(dateString) - Level \(feelingLevel) - Comparison: \(feelingComparison?.displayText ?? "ไม่ระบุ")")
        } catch {
            print("❌ บันทึกล้มเหลว: \(error.localizedDescription)")
            throw DiaryError.saveFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Fetch Entries for Month
    func fetchEntriesForMonth(date: Date) async throws -> [DiaryEntry] {
        let userId = try await getCurrentUserId()
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        
        let components = calendar.dateComponents([.year, .month], from: date)
        
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
        else { return [] }
        
        let startDate = dbDateFormatter.string(from: startOfMonth)
        let endDate = dbDateFormatter.string(from: endOfMonth)
        
        print("Fetching range: \(startDate) - \(endDate)")
        
        do {
            let response: [DiaryEntryDB] = try await UserProfile.supabase
                .from("diary_entries")
                .select()
                .eq("user_id", value: userId.uuidString)
                .gte("entry_date", value: startDate)
                .lte("entry_date", value: endDate)
                .order("entry_date", ascending: false)
                .execute()
                .value
            
            print("📌 ดึงเดือนนี้: \(response.count) รายการ")
            return response.map { DiaryEntry(from: $0) }
        } catch {
            throw DiaryError.fetchFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Fetch All Entries (statistics)
    func fetchAllEntries() async throws -> [DiaryEntry] {
        let userId = try await getCurrentUserId()
        
        do {
            let response: [DiaryEntryDB] = try await UserProfile.supabase
                .from("diary_entries")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("entry_date", ascending: false)
                .execute()
                .value
            
            return response.map { DiaryEntry(from: $0) }
        } catch {
            throw DiaryError.fetchFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Check if Entry Exists
    func entryExists(for date: Date) async throws -> Bool {
        guard let userId = try? await getCurrentUserId() else { return false }
        let dateString = dbDateFormatter.string(from: date)
        
        do {
            let response: [DiaryEntryDB] = try await UserProfile.supabase
                .from("diary_entries")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("entry_date", value: dateString)
                .execute()
                .value
            
            return !response.isEmpty
        } catch {
            print("Warning: Failed to check entry existence: \(error)")
            return false
        }
    }
    
    // MARK: - Update Diary Entry
    // ✅ เพิ่ม parameter feelingComparison
    func updateDiaryEntry(date: Date, feelingLevel: Int, feelingComparison: FeelingComparison?, note: String?) async throws {
        let userId = try await getCurrentUserId()
        let dateString = dbDateFormatter.string(from: date)
        
        let updateModel = DiaryEntryUpdateDTO(
            feelingLevel: feelingLevel,
            feelingComparison: feelingComparison?.rawValue, // ✅ เพิ่ม
            note: note?.isEmpty == true ? nil : note,
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
        
        do {
            try await UserProfile.supabase
                .from("diary_entries")
                .update(updateModel)
                .eq("user_id", value: userId.uuidString)
                .eq("entry_date", value: dateString)
                .execute()
            
            print("✅ อัปเดตสำเร็จ: \(dateString)")
        } catch {
            throw DiaryError.saveFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Delete Entry
    func deleteDiaryEntry(date: Date) async throws {
        let userId = try await getCurrentUserId()
        let dateString = dbDateFormatter.string(from: date)
        
        do {
            try await UserProfile.supabase
                .from("diary_entries")
                .delete()
                .eq("user_id", value: userId.uuidString)
                .eq("entry_date", value: dateString)
                .execute()
            
            print("🗑️ ลบสำเร็จ: \(dateString)")
        } catch {
            throw DiaryError.deleteFailed(error.localizedDescription)
        }
    }
}
