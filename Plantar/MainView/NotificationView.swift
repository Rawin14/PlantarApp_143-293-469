//
// NotificationView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

//import SwiftUI
//
//// MARK: - Notification Model
//struct NotificationItem: Identifiable {
//    let id = UUID()
//    let icon: String
//    let iconColor: Color
//    let title: String
//    let isUnread: Bool
//    let section: String
//}
//
//struct NotificationView: View {
//    // --- Environment ---
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var notificationManager = NotificationManager.shared
//    @State private var showingAlert = false
//    @State private var alertMessage = ""
//    
//    // --- Custom Colors ---
//    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255)
//    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255)
//    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
//    
//    // --- Sample Notifications ---
//    let notifications: [NotificationItem] = [
//        NotificationItem(
//            icon: "figure.walk",
//            iconColor: Color(red: 172/255, green: 187/255, blue: 98/255),
//            title: "เวลาออกกำลังกายแล้ว! มาทำท่ายืดเหยียดเท้ากันเถอะ",
//            isUnread: true,
//            section: "Today"
//        ),
//        NotificationItem(
//            icon: "figure.yoga",
//            iconColor: Color(red: 139/255, green: 122/255, blue: 184/255),
//            title: "อย่าลืมทำท่ายืดเหยียดเท้า 5 นาที เพื่อป้องกันอาการปวดส้นเท้า",
//            isUnread: true,
//            section: "Today"
//        ),
//        NotificationItem(
//            icon: "bell.fill",
//            iconColor: Color.orange,
//            title: "แจ้งเตือน: ถึงเวลาทำท่ายืดเหยียดประจำวันแล้ว",
//            isUnread: true,
//            section: "Today"
//        ),
//        NotificationItem(
//            icon: "figure.flexibility",
//            iconColor: Color(red: 172/255, green: 187/255, blue: 98/255),
//            title: "ลองท่ายืดเหยียดใหม่: Plantar Fascia Stretch",
//            isUnread: false,
//            section: "This week"
//        ),
//        NotificationItem(
//            icon: "star.fill",
//            iconColor: Color.yellow,
//            title: "ยินดีด้วย! คุณปรับปรุงความยืดหยุ่นของเท้าได้ 20%",
//            isUnread: false,
//            section: "This week"
//        ),
//        NotificationItem(
//            icon: "heart.fill",
//            iconColor: Color.pink,
//            title: "อย่าลืม: การยืดเหยียดสม่ำเสมอช่วยลดความเสี่ยง",
//            isUnread: false,
//            section: "This week"
//        )
//    ]
//    
//    var body: some View {
//        ZStack {
//            backgroundColor.ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // MARK: - Header
//                HStack {
//                    // Back Button
//                    Button(action: {
//                        dismiss()
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .font(.title2)
//                            .foregroundColor(.black)
//                    }
//                    
//                    Spacer()
//                    
//                    // Settings/Test Button
//                    Menu {
//                        Button(action: {
//                            Task {
//                                await notificationManager.sendTestNotification()
//                                alertMessage = "ส่งการแจ้งเตือนทดสอบแล้ว"
//                                showingAlert = true
//                            }
//                        }) {
//                            Label("ทดสอบการแจ้งเตือน", systemImage: "bell.badge")
//                        }
//                        
//                        Button(action: {
//                            Task {
//                                await notificationManager.listPendingNotifications()
//                            }
//                        }) {
//                            Label("ดูการแจ้งเตือนที่รอส่ง", systemImage: "list.bullet")
//                        }
//                        
//                        Button(role: .destructive, action: {
//                            notificationManager.cancelAllNotifications()
//                            alertMessage = "ยกเลิกการแจ้งเตือนทั้งหมดแล้ว"
//                            showingAlert = true
//                        }) {
//                            Label("ยกเลิกการแจ้งเตือนทั้งหมด", systemImage: "xmark.circle")
//                        }
//                    } label: {
//                        Image(systemName: "ellipsis.circle")
//                            .font(.title2)
//                            .foregroundColor(.black)
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 16)
//                .padding(.bottom, 8)
//                
//                // Title
//                HStack(alignment: .top, spacing: 12) {
//                    Text("Notifications")
//                        .font(.system(size: 36, weight: .bold))
//                        .foregroundColor(.black)
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 20)
//                .padding(.bottom, 20)
//                
//                // MARK: - Notification Settings Card
//                VStack(spacing: 16) {
//                    HStack {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("การแจ้งเตือนประจำวัน")
//                                .font(.headline)
//                                .foregroundColor(.black)
//                            
//                            Text("รับการแจ้งเตือนทุกวันเวลา 17:00 น.")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        Spacer()
//                        
//                        Toggle("", isOn: Binding(
//                            get: { notificationManager.isNotificationEnabled },
//                            set: { newValue in
//                                Task {
//                                    if newValue {
//                                        let granted = await notificationManager.requestAuthorization()
//                                        if !granted {
//                                            alertMessage = "กรุณาเปิดการแจ้งเตือนในการตั้งค่าเครื่อง"
//                                            showingAlert = true
//                                        } else {
//                                            alertMessage = "เปิดการแจ้งเตือนเรียบร้อย ✅"
//                                            showingAlert = true
//                                        }
//                                    } else {
//                                        notificationManager.cancelAllNotifications()
//                                        alertMessage = "ปิดการแจ้งเตือนแล้ว"
//                                        showingAlert = true
//                                    }
//                                }
//                            }
//                        ))
//                        .tint(primaryColor)
//                    }
//                }
//                .padding(20)
//                .background(Color.white)
//                .cornerRadius(15)
//                .padding(.horizontal, 20)
//                .padding(.bottom, 10)
//                
//                // MARK: - Notifications List
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 24) {
//                        // Today Section
//                        VStack(alignment: .leading, spacing: 16) {
//                            Text("Today")
//                                .font(.headline)
//                                .foregroundColor(.secondary)
//                                .padding(.horizontal, 20)
//                            
//                            VStack(spacing: 0) {
//                                ForEach(notifications.filter { $0.section == "Today" }) { notification in
//                                    NotificationRow(notification: notification)
//                                    
//                                    if notification.id != notifications.filter({ $0.section == "Today" }).last?.id {
//                                        Divider()
//                                            .padding(.leading, 100)
//                                    }
//                                }
//                            }
//                            .background(Color.white)
//                            .cornerRadius(15)
//                            .padding(.horizontal, 20)
//                        }
//                        
//                        // This Week Section
//                        VStack(alignment: .leading, spacing: 16) {
//                            Text("This week")
//                                .font(.headline)
//                                .foregroundColor(.secondary)
//                                .padding(.horizontal, 20)
//                            
//                            VStack(spacing: 0) {
//                                ForEach(notifications.filter { $0.section == "This week" }) { notification in
//                                    NotificationRow(notification: notification)
//                                    
//                                    if notification.id != notifications.filter({ $0.section == "This week" }).last?.id {
//                                        Divider()
//                                            .padding(.leading, 100)
//                                    }
//                                }
//                            }
//                            .background(Color.white)
//                            .cornerRadius(15)
//                            .padding(.horizontal, 20)
//                        }
//                    }
//                    .padding(.top, 10)
//                    .padding(.bottom, 100)
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//        .task {
//            await notificationManager.checkAuthorizationStatus()
//        }
//        .alert("การแจ้งเตือน", isPresented: $showingAlert) {
//            Button("ตกลง", role: .cancel) { }
//        } message: {
//            Text(alertMessage)
//        }
//    }
//}
//
//// MARK: - Notification Row Component
//struct NotificationRow: View {
//    let notification: NotificationItem
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 16) {
//            // Icon with Character Placeholder
//            ZStack {
//                RoundedRectangle(cornerRadius: 15)
//                    .fill(Color.black)
//                    .frame(width: 70, height: 70)
//                
//                // Character Image Placeholder
//                Image(systemName: notification.icon)
//                    .font(.system(size: 30))
//                    .foregroundColor(notification.iconColor)
//            }
//            
//            // Text Content
//            VStack(alignment: .leading, spacing: 4) {
//                Text(notification.title)
//                    .font(.body)
//                    .foregroundColor(.black)
//                    .lineLimit(3)
//            }
//            
//            Spacer()
//            
//            // Unread Indicator
//            if notification.isUnread {
//                Circle()
//                    .fill(Color(red: 139/255, green: 122/255, blue: 184/255))
//                    .frame(width: 10, height: 10)
//            }
//        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 16)
//    }
//}
//
//#Preview {
//    NavigationStack {
//        NotificationView()
//    }
//}

import SwiftUI

// MARK: - Notification Model
struct NotificationItem: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let isUnread: Bool
    let section: String
}

struct NotificationView: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedTime = Date()
    @State private var showTimePicker = false
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255)
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255)
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
    
    // --- Sample Notifications ---
    let notifications: [NotificationItem] = [
        NotificationItem(
            icon: "figure.walk",
            iconColor: Color(red: 172/255, green: 187/255, blue: 98/255),
            title: "เวลาออกกำลังกายแล้ว! มาทำท่ายืดเหยียดเท้ากันเถอะ",
            isUnread: true,
            section: "Today"
        ),
        NotificationItem(
            icon: "figure.yoga",
            iconColor: Color(red: 139/255, green: 122/255, blue: 184/255),
            title: "อย่าลืมทำท่ายืดเหยียดเท้า 5 นาที เพื่อป้องกันอาการปวดส้นเท้า",
            isUnread: true,
            section: "Today"
        ),
        NotificationItem(
            icon: "bell.fill",
            iconColor: Color.orange,
            title: "แจ้งเตือน: ถึงเวลาทำท่ายืดเหยียดประจำวันแล้ว",
            isUnread: true,
            section: "Today"
        ),
        NotificationItem(
            icon: "figure.flexibility",
            iconColor: Color(red: 172/255, green: 187/255, blue: 98/255),
            title: "ลองท่ายืดเหยียดใหม่: Plantar Fascia Stretch",
            isUnread: false,
            section: "This week"
        ),
        NotificationItem(
            icon: "star.fill",
            iconColor: Color.yellow,
            title: "ยินดีด้วย! คุณปรับปรุงความยืดหยุ่นของเท้าได้ 20%",
            isUnread: false,
            section: "This week"
        ),
        NotificationItem(
            icon: "heart.fill",
            iconColor: Color.pink,
            title: "อย่าลืม: การยืดเหยียดสม่ำเสมอช่วยลดความเสี่ยง",
            isUnread: false,
            section: "This week"
        )
    ]
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    // Back Button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Title
                HStack(alignment: .top, spacing: 12) {
                    Text("Notifications")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // MARK: - Notification Settings Card
                VStack(spacing: 16) {
                    // Toggle Switch
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("การแจ้งเตือนประจำวัน")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Text("สามารถเลือกเวลาแจ้งเตือน")
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { notificationManager.isNotificationEnabled },
                            set: { newValue in
                                Task {
                                    if newValue {
                                        let granted = await notificationManager.requestAuthorization()
                                        if granted {
                                            notificationManager.isNotificationEnabled = true   // ✅ เพิ่ม
                                            let calendar = Calendar.current
                                            let hour = calendar.component(.hour, from: selectedTime)
                                            let minute = calendar.component(.minute, from: selectedTime)
                                            await notificationManager.scheduleDailyNotifications(
                                                hour: hour,
                                                minute: minute
                                            )
                                        } else {
                                            notificationManager.isNotificationEnabled = false  // ✅ เพิ่ม
                                            alertMessage = "กรุณาเปิดการแจ้งเตือนในการตั้งค่าเครื่อง"
                                            showingAlert = true
                                        }
                                    } else {
                                        notificationManager.isNotificationEnabled = false       // ✅ เพิ่ม
                                        notificationManager.cancelAllNotifications()
                                    }
                                }
                            }
                        ))
                        .tint(primaryColor)

                    }
                    
                    // Divider
                    Divider()
                    
                    // Time Picker Button
                    Button(action: {
                        showTimePicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(primaryColor)
                            
                            Text("เวลาแจ้งเตือน")
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text(timeString(from: selectedTime))
                                .foregroundColor(.black)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Time Picker (แสดงเมื่อกดปุ่ม)
                    if showTimePicker {
                        DatePicker(
                            "",
                            selection: $selectedTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .environment(\.colorScheme, .light) // ✅ สำคัญมาก
                        .tint(.black)
                        .onChange(of: selectedTime) { newValue in
                            if notificationManager.isNotificationEnabled {
                                Task {
                                    let calendar = Calendar.current
                                    let hour = calendar.component(.hour, from: newValue)
                                    let minute = calendar.component(.minute, from: newValue)
                                    await notificationManager.scheduleDailyNotifications(
                                        hour: hour,
                                        minute: minute
                                    )
                                }
                            }
                        }

                        
                        // ปุ่มเสร็จสิ้น
                        Button(action: {
                            showTimePicker = false
                        }) {
                            Text("เสร็จสิ้น")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(primaryColor)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                
                // MARK: - Notifications List
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Today Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Today")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                ForEach(notifications.filter { $0.section == "Today" }) { notification in
                                    NotificationRow(notification: notification)
                                    
                                    if notification.id != notifications.filter({ $0.section == "Today" }).last?.id {
                                        Divider()
                                            .padding(.leading, 100)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(15)
                            .padding(.horizontal, 20)
                        }
                        
                        // This Week Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("This week")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                ForEach(notifications.filter { $0.section == "This week" }) { notification in
                                    NotificationRow(notification: notification)
                                    
                                    if notification.id != notifications.filter({ $0.section == "This week" }).last?.id {
                                        Divider()
                                            .padding(.leading, 100)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(15)
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // ตั้งค่าเริ่มต้นเป็น 17:00
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour = 17
            components.minute = 0
            selectedTime = calendar.date(from: components) ?? Date()
        }
        .task {
            await notificationManager.checkAuthorizationStatus()
        }
        .alert("การแจ้งเตือน", isPresented: $showingAlert) {
            Button("ตกลง", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // Helper function to format time
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "th_TH")
        return formatter.string(from: date)
    }
}

// MARK: - Notification Row Component
struct NotificationRow: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon with Character Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
                
                // Character Image Placeholder
                Image(systemName: notification.icon)
                    .font(.system(size: 30))
                    .foregroundColor(notification.iconColor)
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.body)
                    .foregroundColor(.black)
                    .lineLimit(3)
            }
            
            Spacer()
            
            // Unread Indicator
            if notification.isUnread {
                Circle()
                    .fill(Color(red: 139/255, green: 122/255, blue: 184/255))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    NavigationStack {
        NotificationView()
    }
}
