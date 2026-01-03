//
//  NotificationManager.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 4/1/2569 BE.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationEnabled = false
    
    private init() {}
    
    // ขอสิทธิ์แจ้งเตือน
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                self.isNotificationEnabled = granted
            }
            
            if granted {
                await scheduleDailyNotifications()
            }
            
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    // ตรวจสอบสิทธิ์ปัจจุบัน
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        
        await MainActor.run {
            self.isNotificationEnabled = settings.authorizationStatus == .authorized
        }
    }
    
    // ตั้งค่าการแจ้งเตือนประจำวัน
    func scheduleDailyNotifications(hour: Int = 17, minute: Int = 0) async {
        // ยกเลิกการแจ้งเตือนเก่าทั้งหมดก่อน
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // สร้างการแจ้งเตือน 2 แบบ
        let notifications: [(id: String, title: String, body: String)] = [
            (
                id: "exercise_reminder",
                title: "ก๊อกๆ",
                body: "วันนี้คุณออกกำลังกายตามเราหรือยัง อย่าลืมเปิดแอปมาทำนะ"
            ),
            (
                id: "feeling_check",
                title: "เป็นห่วงนะ!",
                body: "วันนี้คุณรู้สึกอย่างไรบ้าง เข้าแอปมาบันทึกให้เรารู้ที"
            )
        ]
        
        for (index, notification) in notifications.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = .default
            content.badge = NSNumber(value: index + 1)
            
            // ตั้งเวลาตามที่ระบุ
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute + index  // ข้อความที่ 2 จะส่งหลังจาก 1 นาที
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )
            
            let request = UNNotificationRequest(
                identifier: notification.id,
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
                print("✅ Scheduled notification: \(notification.id)")
                print("   Title: \(notification.title)")
                print("   ⏰ Time: \(String(format: "%02d:%02d", hour, minute + index))")
            } catch {
                print("❌ Error scheduling notification: \(error)")
            }
        }
        
        print("✅ การแจ้งเตือนถูกตั้งค่าที่ \(String(format: "%02d:%02d", hour, minute)) และ \(String(format: "%02d:%02d", hour, minute + 1)) น. ทุกวัน")
        await listPendingNotifications()
    }
    
    // ยกเลิกการแจ้งเตือนทั้งหมด
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🚫 All notifications cancelled")
    }
    
    // ดูการแจ้งเตือนที่รอส่ง
    func listPendingNotifications() async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        print("📋 Pending notifications: \(requests.count)")
        for request in requests {
            print("  - \(request.identifier): \(request.content.title)")
        }
    }
    
    // ทดสอบแจ้งเตือนทันที (สำหรับ debug)
    func sendTestNotification() async {
        // เช็คสถานะการอนุญาตก่อน
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        print("🔔 Current notification settings:")
        print("   Authorization Status: \(settings.authorizationStatus.rawValue)")
        print("   Alert Setting: \(settings.alertSetting.rawValue)")
        print("   Sound Setting: \(settings.soundSetting.rawValue)")
        print("   Badge Setting: \(settings.badgeSetting.rawValue)")
        
        guard settings.authorizationStatus == .authorized else {
            print("❌ Notifications not authorized!")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "ทดสอบการแจ้งเตือน"
        content.body = "นี่คือการแจ้งเตือนทดสอบ - ถ้าเห็นข้อความนี้แสดงว่าทำงาน!"
        content.sound = .default
        content.badge = 1
        
        // ส่งทันทีโดยไม่มี trigger
        let request = UNNotificationRequest(
            identifier: "test_notification_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil  // ส่งทันที
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Test notification sent successfully at \(Date())")
        } catch {
            print("❌ Error sending test notification: \(error.localizedDescription)")
        }
    }
}
