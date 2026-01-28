//
//  DiaryModels.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 5/1/2569 BE.
//

//import Foundation
//
//// MARK: - Database Model (ตรงกับ Table Structure)
//struct DiaryEntryDB: Codable, Identifiable {
//    let id: UUID
//    let userId: UUID
//    let entryDate: String // Format: "YYYY-MM-DD"
//    let feelingLevel: Int
//    let note: String?
//    let createdAt: String?
//    let updatedAt: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case userId = "user_id"
//        case entryDate = "entry_date"
//        case feelingLevel = "feeling_level"
//        case note
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
//    }
//}
//
//// MARK: - Insert Model (สำหรับ Insert ข้อมูลใหม่)
//struct DiaryEntryInsert: Encodable {
//    let userId: UUID
//    let entryDate: String
//    let feelingLevel: Int
//    let note: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case userId = "user_id"
//        case entryDate = "entry_date"
//        case feelingLevel = "feeling_level"
//        case note
//    }
//}
//
//// MARK: - App Model (ใช้ใน SwiftUI)
//struct DiaryEntry: Identifiable {
//    let id: UUID
//    let date: Date
//    let feelingLevel: Int
//    let note: String?
//    
//    // Convert from Database Model
//    init(from dbEntry: DiaryEntryDB) {
//        self.id = dbEntry.id
//        self.feelingLevel = dbEntry.feelingLevel
//        self.note = dbEntry.note
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.calendar = Calendar(identifier: .gregorian)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        self.date = formatter.date(from: dbEntry.entryDate) ?? Date()
//    }
//    
//    // Init for local use
//    init(id: UUID = UUID(), date: Date, feelingLevel: Int, note: String?) {
//        self.id = id
//        self.date = date
//        self.feelingLevel = feelingLevel
//        self.note = note
//    }
//}
import Foundation
// MARK: - Feeling Comparison Enum
enum FeelingComparison: String, Codable {
    case better = "better"
    case same = "same"
    case worse = "worse"
    
    var displayText: String {
        switch self {
        case .better: return "ดีขึ้น"
        case .same: return "เหมือนเดิม"
        case .worse: return "แย่ลง"
        }
    }
    
    var color: String {
        switch self {
        case .better: return "green"
        case .same: return "yellow"
        case .worse: return "red"
        }
    }
}
// MARK: - Database Model (ตรงกับ Table Structure)
struct DiaryEntryDB: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let entryDate: String // Format: "YYYY-MM-DD"
    let feelingLevel: Int
    let feelingComparison: String? // ✅ เพิ่มฟิลด์ใหม่
    let note: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case entryDate = "entry_date"
        case feelingLevel = "feeling_level"
        case feelingComparison = "feeling_comparison" // ✅ เพิ่ม
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
    let feelingComparison: String? // ✅ เพิ่มฟิลด์ใหม่
    let note: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case entryDate = "entry_date"
        case feelingLevel = "feeling_level"
        case feelingComparison = "feeling_comparison" // ✅ เพิ่ม
        case note
    }
}
// MARK: - App Model (ใช้ใน SwiftUI)
struct DiaryEntry: Identifiable {
    let id: UUID
    let date: Date
    let feelingLevel: Int
    let feelingComparison: FeelingComparison? // ✅ เพิ่มฟิลด์ใหม่
    let note: String?
    
    // Convert from Database Model
    init(from dbEntry: DiaryEntryDB) {
        self.id = dbEntry.id
        self.feelingLevel = dbEntry.feelingLevel
        self.note = dbEntry.note
        
        // ✅ แปลง String เป็น Enum
        if let comparisonString = dbEntry.feelingComparison {
            self.feelingComparison = FeelingComparison(rawValue: comparisonString)
        } else {
            self.feelingComparison = nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        self.date = formatter.date(from: dbEntry.entryDate) ?? Date()
    }
    
    // Init for local use
    init(id: UUID = UUID(), date: Date, feelingLevel: Int, feelingComparison: FeelingComparison? = nil, note: String?) {
        self.id = id
        self.date = date
        self.feelingLevel = feelingLevel
        self.feelingComparison = feelingComparison // ✅ เพิ่ม
        self.note = note
    }
}
extension DiaryEntry {
    // แปลง feelingLevel → 0.0 – 1.0
    var normalizedScore: Double {
        return Double(feelingLevel - 1) / 4.0
    }
    // ใช้สำหรับ "รู้สึกดีขึ้น"
    var isFeelingBetter: Bool {
        return feelingLevel >= 4
    }
}
