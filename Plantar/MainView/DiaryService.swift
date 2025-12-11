//
//  DiaryService.swift
//  Plantar
//
//  Created by ncp on 10/12/2568 BE.

import Foundation
import Supabase

enum DiaryError: Error {
    case invalidUserId
    case saveFailed(String)
    case fetchFailed(String)
    case deleteFailed(String)
}

// ---------- NOTE ----------
// หากโปรเจกต์ของคุณยังไม่มี struct `DiaryEntryInsert`
// ที่มี initializer: `DiaryEntryInsert(userId:entryDate:feelingLevel:note:)`
// ให้ย้ายหรือเพิ่ม struct นั้นไว้ในไฟล์ models ของคุณแทน
// (ไม่ควรประกาศซ้ำชื่อเดียวกันหลายไฟล์)

/// DTO สำหรับการอัปเดต (ชื่อต่างจาก `DiaryEntryInsert` เพื่อไม่ชน)
struct DiaryEntryUpdateDTO: Encodable {
    let feelingLevel: Int
    let note: String?
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case feelingLevel = "feeling_level"
        case note
        case updatedAt = "updated_at"
    }
}

class DiaryService {
    private let supabase = SupabaseManager.shared.client

    // ⚠️ ผูกกับระบบ Auth ของคุณจริง ๆ แทนการใช้ UUID คงที่
    private let currentUserId = UUID()

    // MARK: - Save Diary Entry
    func saveDiaryEntry(date: Date, feelingLevel: Int, note: String?) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        // --- ใช้ initializer แบบ camelCase ตามที่โปรเจกต์คาดไว้ ---
        // หากคุณไม่มี DiaryEntryInsert ให้สร้าง struct เหมือนด้านล่างในไฟล์ models:
        //
        // struct DiaryEntryInsert: Encodable {
        //     let userId: UUID
        //     let entryDate: String
        //     let feelingLevel: Int
        //     let note: String?
        //     enum CodingKeys: String, CodingKey {
        //         case userId = "user_id"
        //         case entryDate = "entry_date"
        //         case feelingLevel = "feeling_level"
        //         case note
        //     }
        // }
        //
        // แต่อย่าไปประกาศซ้ำถ้ามีอยู่แล้ว

        let entry = DiaryEntryInsert(
            userId: currentUserId,
            entryDate: dateString,
            feelingLevel: feelingLevel,
            note: note?.isEmpty == true ? nil : note
        )

        do {
            try await supabase
                .from("diary_entries")
                .insert(entry)
                .execute()

            print("✅ บันทึกสำเร็จ: \(dateString) - Level \(feelingLevel)")
        } catch {
            print("❌ บันทึกล้มเหลว: \(error.localizedDescription)")
            throw DiaryError.saveFailed(error.localizedDescription)
        }
    }

    // MARK: - Fetch Entries for Month
    func fetchEntriesForMonth(date: Date) async throws -> [DiaryEntry] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)

        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
        else { return [] }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = formatter.string(from: startOfMonth)
        let endDate = formatter.string(from: endOfMonth)

        do {
            let response: [DiaryEntryDB] = try await supabase
                .from("diary_entries")
                .select()
                .eq("user_id", value: currentUserId.uuidString)
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
        do {
            let response: [DiaryEntryDB] = try await supabase
                .from("diary_entries")
                .select()
                .eq("user_id", value: currentUserId.uuidString)
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        do {
            let response: [DiaryEntryDB] = try await supabase
                .from("diary_entries")
                .select()
                .eq("user_id", value: currentUserId.uuidString)
                .eq("entry_date", value: dateString)
                .execute()
                .value

            return !response.isEmpty
        } catch {
            throw DiaryError.fetchFailed(error.localizedDescription)
        }
    }

    // MARK: - Update Diary Entry (fixed: use DTO that is Encodable)
    func updateDiaryEntry(date: Date, feelingLevel: Int, note: String?) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        let updateModel = DiaryEntryUpdateDTO(
            feelingLevel: feelingLevel,
            note: note?.isEmpty == true ? nil : note,
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )

        do {
            try await supabase
                .from("diary_entries")
                .update(updateModel)
                .eq("user_id", value: currentUserId.uuidString)
                .eq("entry_date", value: dateString)
                .execute()

            print("✅ อัปเดตสำเร็จ: \(dateString)")
        } catch {
            throw DiaryError.saveFailed(error.localizedDescription)
        }
    }

    // MARK: - Delete Entry
    func deleteDiaryEntry(date: Date) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        do {
            try await supabase
                .from("diary_entries")
                .delete()
                .eq("user_id", value: currentUserId.uuidString)
                .eq("entry_date", value: dateString)
                .execute()

            print("🗑️ ลบสำเร็จ: \(dateString)")
        } catch {
            throw DiaryError.deleteFailed(error.localizedDescription)
        }
    }
}
