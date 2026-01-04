//
//  NotificationView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

struct NotificationView: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // ✅ ใช้ @ObservedObject เพราะเป็น Singleton
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedTime = Date()
    @State private var showTimePicker = false
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255)
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button(action: { dismiss() }) {
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
                                        // ✅ การทำงานแบบ Async ต้องรอ
                                        let granted = await notificationManager.requestAuthorization()
                                        
                                        // ✅ อัปเดต UI ต้องทำบน Main Actor
                                        await MainActor.run {
                                            if granted {
                                                // สิทธิ์ผ่าน: ตั้งเวลาแจ้งเตือน
                                                let calendar = Calendar.current
                                                let hour = calendar.component(.hour, from: selectedTime)
                                                let minute = calendar.component(.minute, from: selectedTime)
                                                
                                                Task {
                                                    await notificationManager.scheduleDailyNotifications(hour: hour, minute: minute)
                                                }
                                            } else {
                                                // สิทธิ์ไม่ผ่าน: ปิด Toggle และแจ้งเตือน
                                                notificationManager.isNotificationEnabled = false
                                                alertMessage = "กรุณาเปิดการแจ้งเตือนในการตั้งค่าเครื่อง"
                                                showingAlert = true
                                            }
                                        }
                                    } else {
                                        // ปิดการแจ้งเตือน
                                        await MainActor.run {
                                            notificationManager.isNotificationEnabled = false
                                            notificationManager.cancelAllNotifications()
                                        }
                                    }
                                }
                            }
                        ))
                        .tint(primaryColor)
                    }
                    
                    Divider()
                    
                    // Time Picker Button
                    Button(action: {
                        withAnimation {
                            showTimePicker.toggle()
                        }
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
                                .rotationEffect(.degrees(showTimePicker ? 90 : 0))
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Time Picker Wheel
                    if showTimePicker {
                        VStack {
                            DatePicker(
                                "",
                                selection: $selectedTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .environment(\.colorScheme, .light)
                            .onChange(of: selectedTime) { newValue in
                                if notificationManager.isNotificationEnabled {
                                    Task {
                                        let calendar = Calendar.current
                                        let hour = calendar.component(.hour, from: newValue)
                                        let minute = calendar.component(.minute, from: newValue)
                                        await notificationManager.scheduleDailyNotifications(hour: hour, minute: minute)
                                    }
                                }
                            }
                            
                            Button(action: {
                                withAnimation { showTimePicker = false }
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
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                
                // MARK: - Notifications List
                ScrollView {
                    if notificationManager.isLoading {
                        // กรณีโหลดยังไม่เสร็จ
                        ProgressView()
                            .padding(.top, 50)
                    } else if notificationManager.notifications.isEmpty {
                        // กรณีไม่มีข้อมูล
                        VStack(spacing: 12) {
                            Image(systemName: "bell.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("ไม่มีการแจ้งเตือน")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        // กรณีมีข้อมูล (แสดงรายการ)
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("รายการแจ้งเตือน")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 0) {
                                    ForEach(notificationManager.notifications) { notification in
                                        NotificationRow(notification: notification)
                                        
                                        // เส้นขีดคั่น (Divider)
                                        if notification.id != notificationManager.notifications.last?.id {
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
                .refreshable {
                    // ดึงลงเพื่อรีเฟรชข้อมูลใหม่
                    await notificationManager.fetchNotifications()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
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
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "th_TH")
        return formatter.string(from: date)
    }
}

// MARK: - Notification Row Component
struct NotificationRow: View {
    let notification: AppNotification // ✅ เปลี่ยน Type เป็น AppNotification ให้ตรงกับ Manager
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black)
                    .frame(width: 70, height: 70)
                
                Image(systemName: "bell.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color(red: 139/255, green: 122/255, blue: 184/255))
            }
            
            // เนื้อหาข้อความ
            VStack(alignment: .leading, spacing: 6) {
                Text(notification.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                Text(notification.displayDate)
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.7))
            }
            
            Spacer()
            
            // จุดแดง (ถ้ายังไม่อ่าน)
            if !notification.is_read {
                Circle()
                    .fill(Color(red: 172/255, green: 187/255, blue: 98/255))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        // 🔥 Swipe to delete
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task {
                    await NotificationManager.shared.deleteNotification(id: notification.id)
                }
            } label: {
                Label("ลบ", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NotificationView()
}
