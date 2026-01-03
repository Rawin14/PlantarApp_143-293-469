//
//  DiaryModels.swift
//  Plantar
//
//  Created by ncp on 10/12/2568 BE.
//

import Foundation

// MARK: - Database Model (ตรงกับ Table Structure)
struct DiaryEntryDB: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let entryDate: String // Format: "YYYY-MM-DD"
    let feelingLevel: Int
    let note: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case entryDate = "entry_date"
        case feelingLevel = "feeling_level"
        case note
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Insert Model (สำหรับ Insert ข้อมูลใหม่)
struct DiaryEntryInsert: Encodable {
    let userId: UUID
    let entryDate: String
    let feelingLevel: Int
    let note: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case entryDate = "entry_date"
        case feelingLevel = "feeling_level"
        case note
    }
}

// MARK: - App Model (ใช้ใน SwiftUI)
struct DiaryEntry: Identifiable {
    let id: UUID
    let date: Date
    let feelingLevel: Int
    let note: String?
    
    // Convert from Database Model
    init(from dbEntry: DiaryEntryDB) {
        self.id = dbEntry.id
        self.feelingLevel = dbEntry.feelingLevel
        self.note = dbEntry.note
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        self.date = formatter.date(from: dbEntry.entryDate) ?? Date()
    }
    
    // Init for local use
    init(id: UUID = UUID(), date: Date, feelingLevel: Int, note: String?) {
        self.id = id
        self.date = date
        self.feelingLevel = feelingLevel
        self.note = note
    }
}
