//
// NotificationView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

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
                        dismiss() // กลับไปหน้า HomeView
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
                
                // MARK: - Notifications List
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Today Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Today")
                                .font(.headline)
                                .foregroundColor(.secondary)
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
                                .foregroundColor(.secondary)
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
                    .fill(Color.black)
                    .frame(width: 70, height: 70)
                
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
            
            // Unread Indicator (สีม่วง)
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
