//
//  UserProfile.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 3/11/2568 BE.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class UserProfile: ObservableObject {
    // User Data
    @Published var userId: String = ""
    @Published var nickname: String = ""
    @Published var age: Int = 0
    @Published var height: Double = 0.0
    @Published var weight: Double = 0.0
    @Published var gender: String = "female"
    @Published var birthdate: Date = Date()
    
    // Loading States
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    // MARK: - Save to Firebase
    func saveToFirebase() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "ไม่พบผู้ใช้ กรุณา Login ก่อน"
            return
        }
        
        isLoading = true
        
        let data: [String: Any] = [
            "nickname": nickname,
            "age": age,
            "height": height,
            "weight": weight,
            "gender": gender,
            "birthdate": Timestamp(date: birthdate),
            "updatedAt": Timestamp()
        ]
        
        do {
            try await db.collection("users").document(userId).setData(data, merge: true)
            print("✅ บันทึกข้อมูลสำเร็จ")
            isLoading = false
        } catch {
            errorMessage = "เกิดข้อผิดพลาด: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Load from Firebase
    func loadFromFirebase() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "ไม่พบผู้ใช้"
            return
        }
        
        isLoading = true
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            
            if let data = document.data() {
                // Parse ข้อมูล
                await MainActor.run {
                    self.nickname = data["nickname"] as? String ?? ""
                    self.age = data["age"] as? Int ?? 0
                    self.height = data["height"] as? Double ?? 0.0
                    self.weight = data["weight"] as? Double ?? 0.0
                    self.gender = data["gender"] as? String ?? "female"
                    
                    if let timestamp = data["birthdate"] as? Timestamp {
                        self.birthdate = timestamp.dateValue()
                    }
                    
                    self.isLoading = false
                    print("✅ โหลดข้อมูลสำเร็จ")
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "โหลดข้อมูลล้มเหลว: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Calculate BMI
    func calculateBMI() -> Double {
        guard height > 0, weight > 0 else { return 0 }
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    // MARK: - Delete from Firebase
    func deleteFromFirebase() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db.collection("users").document(userId).delete()
            print("✅ ลบข้อมูลสำเร็จ")
        } catch {
            errorMessage = "ลบข้อมูลล้มเหลว: \(error.localizedDescription)"
        }
    }
}
