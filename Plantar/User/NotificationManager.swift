//
//  NotificationManager.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 5/1/2569 BE.
//
//
//import SwiftUI
//import UserNotifications
//import Supabase
//
//// MARK: - Model (จาก Supabase)
//struct AppNotification: Identifiable, Codable {
//    let id: UUID
//    let title: String
//    let message: String
//    let created_at: String
//    var is_read: Bool
//    
//    // Helper: แปลงวันที่เป็น String สวยๆ
//    var displayDate: String {
//        let formatter = ISO8601DateFormatter()
//        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        
//        if let date = formatter.date(from: created_at) {
//            let displayFormatter = DateFormatter()
//            displayFormatter.dateFormat = "dd MMM HH:mm"
//            displayFormatter.locale = Locale(identifier: "th_TH")
//            displayFormatter.calendar = Calendar(identifier: .gregorian)
//            return displayFormatter.string(from: date)
//        }
//        return ""
//    }
//}
//
//@MainActor
//class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
//    
//    static let shared = NotificationManager()
//    
//    // --- State Variables ---
//    @Published var notifications: [AppNotification] = [] // ข้อมูลจาก Supabase
//    @Published var isNotificationEnabled: Bool = false   // สถานะเปิด/ปิดแจ้งเตือน (สำหรับ Toggle)
//    
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    override init() {
//        super.init()
//        UNUserNotificationCenter.current().delegate = self
//        Task {
//            await checkAuthorizationStatus() // เช็คสถานะตอนเริ่มแอป
//        }
//    }
//    
//    // MARK: - 1. Permission & Settings
//    
//    // ขอสิทธิ์แจ้งเตือน
//    func requestAuthorization() async -> Bool {
//        do {
//            let granted = try await UNUserNotificationCenter.current()
//                .requestAuthorization(options: [.alert, .badge, .sound])
//            
//            await MainActor.run {
//                self.isNotificationEnabled = granted
//            }
//            return granted
//        } catch {
//            print("❌ Request Authorization Failed: \(error)")
//            return false
//        }
//    }
//    
//    // เช็คสถานะปัจจุบัน (ใช้ตอนเปิดหน้านี้มา)
//    func checkAuthorizationStatus() async {
//        let settings = await UNUserNotificationCenter.current().notificationSettings()
//        await MainActor.run {
//            self.isNotificationEnabled = (settings.authorizationStatus == .authorized)
//        }
//    }
//    
//    // MARK: - 2. Local Notification (ตั้งเวลาเตือนรายวัน)
//    
//    func scheduleDailyNotifications(hour: Int, minute: Int) async {
//        // 1. ลบของเก่าออกก่อน (กันซ้ำ)
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        
//        // 2. เตรียมเนื้อหา
//        let content = UNMutableNotificationContent()
//        content.title = "ได้เวลายืดเหยียดแล้ว! 🦶"
//        content.body = "อย่าลืมดูแลสุขภาพเท้าของคุณในวันนี้นะครับ"
//        content.sound = .default
//        
//        // 3. ตั้งเวลา (ทุกวัน)
//        var dateComponents = DateComponents()
//        dateComponents.hour = hour
//        dateComponents.minute = minute
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//        let request = UNNotificationRequest(identifier: "daily_stretch", content: content, trigger: trigger)
//        
//        // 4. บันทึก
//        do {
//            try await UNUserNotificationCenter.current().add(request)
//            print("✅ ตั้งเวลาเตือนสำเร็จ: \(hour):\(String(format: "%02d", minute)) น.")
//            
//            // อัปเดตสถานะปุ่ม
//            await MainActor.run { self.isNotificationEnabled = true }
//        } catch {
//            print("❌ Error scheduling: \(error)")
//        }
//    }
//    
//    func cancelAllNotifications() {
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        print("🚫 ยกเลิกการแจ้งเตือนทั้งหมดแล้ว")
//    }
//    
//    // MARK: - 3. Remote Notification (ดึงประวัติจาก Supabase)
//    
//    func fetchNotifications() async {
//        // ต้องมี User ID
//        guard let userId = AuthManager.shared.currentUser?.id else {
//            print("⚠️ ไม่มี User ID (ยังไม่ล็อกอิน)")
//            return
//        }
//        
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            let response: [AppNotification] = try await UserProfile.supabase
//                .from("notifications")
//                .select()
//                .eq("user_id", value: userId)
//                .order("created_at", ascending: false)
//                .execute()
//                .value
//            
//            await MainActor.run {
//                self.notifications = response
//                self.isLoading = false
//            }
//            print("✅ โหลดข้อมูลแจ้งเตือนสำเร็จ: \(response.count) รายการ")
//            
//        } catch {
//            print("❌ Error fetching Supabase: \(error)")
//            await MainActor.run {
//                self.errorMessage = "ไม่สามารถโหลดข้อมูลได้"
//                self.isLoading = false
//            }
//        }
//    }
//    
//    func deleteNotification(id: UUID) async {
//        do {
//            try await UserProfile.supabase
//                .from("notifications")
//                .delete()
//                .eq("id", value: id)
//                .execute()
//            
//            // ลบออกจาก List ในหน้าจอทันที
//            await MainActor.run {
//                if let index = notifications.firstIndex(where: { $0.id == id }) {
//                    notifications.remove(at: index)
//                }
//            }
//            print("🗑️ ลบแจ้งเตือนสำเร็จ")
//        } catch {
//            print("❌ Delete failed: \(error)")
//        }
//    }
//    
//    // MARK: - Delegate Methods (ให้แจ้งเตือนเด้งแม้เปิดแอปอยู่)
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.banner, .sound, .badge])
//    }
//}





import SwiftUI
import UserNotifications
import Supabase

// MARK: - Model (จาก Supabase)
struct AppNotification: Identifiable, Codable {
    let id: UUID
    let user_id: UUID
    let title: String
    let message: String
    let notification_type: String? // เช่น "daily_reminder", "exercise", "achievement"
    let created_at: String
    var is_read: Bool
    
    // Helper: แปลงวันที่เป็น String สวยๆ
    var displayDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: created_at) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd MMM HH:mm"
            displayFormatter.locale = Locale(identifier: "th_TH")
            displayFormatter.calendar = Calendar(identifier: .gregorian)
            return displayFormatter.string(from: date)
        }
        return ""
    }
    
    // สีไอคอนตาม type
    var iconColor: Color {
        switch notification_type {
        case "daily_reminder": return Color(red: 139/255, green: 122/255, blue: 184/255)
        case "exercise": return Color(red: 172/255, green: 187/255, blue: 98/255)
        case "achievement": return Color.orange
        default: return Color.gray
        }
    }
    
    // ไอคอนตาม type
    var iconName: String {
        switch notification_type {
        case "daily_reminder": return "bell.fill"
        case "exercise": return "figure.walk"
        case "achievement": return "star.fill"
        default: return "bell.fill"
        }
    }
}

@MainActor
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    
    // --- State Variables ---
    @Published var notifications: [AppNotification] = [] // ข้อมูลจาก Supabase
    @Published var isNotificationEnabled: Bool = false   // สถานะเปิด/ปิดแจ้งเตือน
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // ✅ ข้อความแจ้งเตือนแบบหมุนเวียน (หลากหลาย)
    private let dailyMessages = [
        ("ได้เวลายืดเหยียดแล้ว! 🦶", "อย่าลืมดูแลสุขภาพเท้าของคุณในวันนี้นะครับ"),
        ("พักเท้าสักหน่อย 💆‍♀️", "ลองนวดกดจุดฝ่าเท้าเบาๆ ผ่อนคลายกล้ามเนื้อ"),
        ("ออกกำลังกายกัน! 🏃‍♂️", "ทำแบบฝึกหัดง่ายๆ 5 นาที เพื่อเท้าที่แข็งแรง"),
        ("เช็คอาการวันนี้ 📝", "บันทึกความรู้สึกของคุณใน Pain Diary กันเถอะ"),
        ("ดื่มน้ำกันหน่อย 💧", "การดื่มน้ำเพียงพอช่วยลดอาการอักเสบได้นะ"),
        ("ตรวจรองเท้า 👟", "ใส่รองเท้าที่รองรับฝ่าเท้าดีๆ จะช่วยลดอาการปวดได้"),
        ("พักผ่อนให้เพียงพอ 😴", "การนอนหลับคุณภาพดีช่วยให้ร่างกายฟื้นฟูได้ดีขึ้น")
    ]
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - 1. Permission & Settings
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            
            await MainActor.run {
                self.isNotificationEnabled = granted
            }
            return granted
        } catch {
            print("❌ Request Authorization Failed: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            self.isNotificationEnabled = (settings.authorizationStatus == .authorized)
        }
    }
    
    // MARK: - 2. Local Notification (ตั้งเวลาเตือนรายวัน)
    
    func scheduleDailyNotifications(hour: Int, minute: Int) async {
        // ลบของเก่าออกก่อน
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // ✅ สุ่มข้อความแต่ละวัน (7 วัน)
        for dayOffset in 0..<7 {
            let messageIndex = dayOffset % dailyMessages.count
            let (title, body) = dailyMessages[messageIndex]
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            content.badge = 1
            
            // ✅ เก็บข้อมูลเพิ่มเติมสำหรับบันทึกลง Supabase ภายหลัง
            content.userInfo = [
                "title": title,
                "message": body,
                "type": "daily_reminder"
            ]
            
            // กำหนดเวลา
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.weekday = (dayOffset % 7) + 1 // 1=Sun, 2=Mon, ...
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = "daily_\(dayOffset)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            do {
                try await UNUserNotificationCenter.current().add(request)
                print("✅ ตั้งเวลาสำเร็จ [\(identifier)]: \(title)")
            } catch {
                print("❌ Error scheduling [\(identifier)]: \(error)")
            }
        }
        
        await MainActor.run {
            self.isNotificationEnabled = true
        }
        print("✅ ตั้งเวลาเตือน 7 วันสำเร็จ เวลา \(hour):\(String(format: "%02d", minute)) น.")
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🚫 ยกเลิกการแจ้งเตือนทั้งหมดแล้ว")
    }
    
    // MARK: - 3. ✅ บันทึกการแจ้งเตือนลง Supabase (เมื่อถูกส่ง)
    
    // ✅ DTO สำหรับ Insert
    struct NotificationInsert: Encodable {
        let user_id: UUID
        let title: String
        let message: String
        let notification_type: String
        let is_read: Bool
    }
    
    func saveNotificationToDatabase(title: String, message: String, type: String = "daily_reminder") async {
        guard let userId = AuthManager.shared.currentUser?.id else {
            print("⚠️ ไม่สามารถบันทึกได้: ไม่มี User ID")
            return
        }
        
        let newNotification = NotificationInsert(
            user_id: userId,
            title: title,
            message: message,
            notification_type: type,
            is_read: false
        )
        
        do {
            try await UserProfile.supabase
                .from("notifications")
                .insert(newNotification)
                .execute()
            
            print("✅ บันทึกการแจ้งเตือนลง Supabase สำเร็จ")
            
            // รีเฟรชข้อมูล
            await fetchNotifications()
            
        } catch {
            print("❌ Error saving notification: \(error)")
        }
    }
    
    // MARK: - 4. Remote Notification (ดึงประวัติจาก Supabase)
    
    func fetchNotifications() async {
        guard let userId = AuthManager.shared.currentUser?.id else {
            print("⚠️ ไม่มี User ID (ยังไม่ล็อกอิน)")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [AppNotification] = try await UserProfile.supabase
                .from("notifications")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(50) // จำกัด 50 รายการล่าสุด
                .execute()
                .value
            
            await MainActor.run {
                self.notifications = response
                self.isLoading = false
            }
            print("✅ โหลดข้อมูลแจ้งเตือนสำเร็จ: \(response.count) รายการ")
            
        } catch {
            print("❌ Error fetching Supabase: \(error)")
            await MainActor.run {
                self.errorMessage = "ไม่สามารถโหลดข้อมูลได้"
                self.isLoading = false
            }
        }
    }
    
    func deleteNotification(id: UUID) async {
        do {
            try await UserProfile.supabase
                .from("notifications")
                .delete()
                .eq("id", value: id)
                .execute()
            
            await MainActor.run {
                if let index = notifications.firstIndex(where: { $0.id == id }) {
                    notifications.remove(at: index)
                }
            }
            print("🗑️ ลบแจ้งเตือนสำเร็จ")
        } catch {
            print("❌ Delete failed: \(error)")
        }
    }
    
//    // ✅ ทำเครื่องหมายว่าอ่านแล้ว
//    func markAsRead(id: UUID) async {
//        do {
//            try await UserProfile.supabase
//                .from("notifications")
//                .update(["is_read": true])
//                .eq("id", value: id)
//                .execute()
//            
//            await MainActor.run {
//                if let index = notifications.firstIndex(where: { $0.id == id }) {
//                    notifications[index].is_read = true
//                }
//            }
//            print("✅ ทำเครื่องหมายอ่านแล้ว")
//        } catch {
//            print("❌ Mark as read failed: \(error)")
//        }
//    }
    
    func markAsRead(id: UUID) async {
        do {
            // ✅ 1. อัปเดต Local ก่อน (Optimistic Update)
            await MainActor.run {
                if let index = notifications.firstIndex(where: { $0.id == id }) {
                    notifications[index].is_read = true
                }
            }
            
            // ✅ 2. อัปเดต Database
            try await UserProfile.supabase
                .from("notifications")
                .update(["is_read": true])
                .eq("id", value: id)
                .execute()
            
            print("✅ อัปเดตสถานะอ่านแล้วสำเร็จ (ID: \(id))")
            
        } catch {
            print("❌ Mark as read failed: \(error.localizedDescription)")
            
            // ✅ 3. ถ้าล้มเหลว ให้ rollback กลับ
            await MainActor.run {
                if let index = notifications.firstIndex(where: { $0.id == id }) {
                    notifications[index].is_read = false
                }
            }
        }
    }
    
    // MARK: - 5. Delegate Methods
    
    // ✅ เมื่อมีการแจ้งเตือนเข้ามา (บันทึกลง Database)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // ดึงข้อมูลจาก notification
        let userInfo = notification.request.content.userInfo
        if let title = userInfo["title"] as? String,
           let message = userInfo["message"] as? String,
           let type = userInfo["type"] as? String {
            
            // บันทึกลง Supabase
            Task {
                await saveNotificationToDatabase(title: title, message: message, type: type)
            }
        }
        
        // แสดง notification แม้แอปเปิดอยู่
        completionHandler([.banner, .sound, .badge])
    }
    
    // เมื่อผู้ใช้กดที่ notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("📬 User tapped notification: \(response.notification.request.content.title)")
        completionHandler()
    }
}
