//
//  NotificationManager.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 5/1/2569 BE.
//

import SwiftUI
import UserNotifications
import Supabase

// MARK: - Model (จาก Supabase)
struct AppNotification: Identifiable, Codable {
    let id: UUID
    let title: String
    let message: String
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
}

@MainActor
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    
    // --- State Variables ---
    @Published var notifications: [AppNotification] = [] // ข้อมูลจาก Supabase
    @Published var isNotificationEnabled: Bool = false   // สถานะเปิด/ปิดแจ้งเตือน (สำหรับ Toggle)
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Task {
            await checkAuthorizationStatus() // เช็คสถานะตอนเริ่มแอป
        }
    }
    
    // MARK: - 1. Permission & Settings
    
    // ขอสิทธิ์แจ้งเตือน
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
    
    // เช็คสถานะปัจจุบัน (ใช้ตอนเปิดหน้านี้มา)
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            self.isNotificationEnabled = (settings.authorizationStatus == .authorized)
        }
    }
    
    // MARK: - 2. Local Notification (ตั้งเวลาเตือนรายวัน)
    
    func scheduleDailyNotifications(hour: Int, minute: Int) async {
        // 1. ลบของเก่าออกก่อน (กันซ้ำ)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // 2. เตรียมเนื้อหา
        let content = UNMutableNotificationContent()
        content.title = "ได้เวลายืดเหยียดแล้ว! 🦶"
        content.body = "อย่าลืมดูแลสุขภาพเท้าของคุณในวันนี้นะครับ"
        content.sound = .default
        
        // 3. ตั้งเวลา (ทุกวัน)
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_stretch", content: content, trigger: trigger)
        
        // 4. บันทึก
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ ตั้งเวลาเตือนสำเร็จ: \(hour):\(String(format: "%02d", minute)) น.")
            
            // อัปเดตสถานะปุ่ม
            await MainActor.run { self.isNotificationEnabled = true }
        } catch {
            print("❌ Error scheduling: \(error)")
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🚫 ยกเลิกการแจ้งเตือนทั้งหมดแล้ว")
    }
    
    // MARK: - 3. Remote Notification (ดึงประวัติจาก Supabase)
    
    func fetchNotifications() async {
        // ต้องมี User ID
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
            
            // ลบออกจาก List ในหน้าจอทันที
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
    
    // MARK: - Delegate Methods (ให้แจ้งเตือนเด้งแม้เปิดแอปอยู่)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
