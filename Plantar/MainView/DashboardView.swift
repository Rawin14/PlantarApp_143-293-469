//
//  DashboardView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 31/10/2568 BE.
//

import SwiftUI

struct DashboardView: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // ม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียวมะนาว
    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255) // ครีม
    
    // --- Computed Properties ---
    var bmiValue: Double { userProfile.calculateBMI() }
    var height: Double { userProfile.height }
    var weight: Double { userProfile.weight }
    
    var bmiColor: Color {
        switch bmiValue {
        case ..<18.5: return Color(red: 173/255, green: 216/255, blue: 230/255) // ฟ้า
        case 18.5..<25.0: return accentColor // เขียว
        case 25.0..<30.0: return Color(red: 255/255, green: 182/255, blue: 193/255) // ชมพู
        default: return Color.red.opacity(0.8) // แดง
        }
    }
    
    var bmiStatus: String {
        switch bmiValue {
        case ..<18.5: return "ผอม"
        case 18.5..<25.0: return "ปกติ"
        case 25.0..<30.0: return "ท้วม"
        default: return "อ้วน"
        }
    }
    
    var body: some View {
        ZStack {
            cardBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Top Navigation Bar (✅ แก้ไข: เปิดใช้งานปุ่มกลับ)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(backgroundColor) // น้ำตาล
                    }
                    
                    Spacer()
                    
                    Text("Dashboard")
                        .font(.headline)
                        .foregroundColor(backgroundColor)
                    
                    Spacer()
                    
                    // Placeholder เพื่อจัด Title ให้อยู่ตรงกลาง (ขนาดเท่าปุ่มซ้าย)
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                .background(cardBackground)
                
                // MARK: - Main Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Main Progress Circle (Video Progress)
                        mainProgressCard
                        
                        // Stats Grid (Streak & Entries)
                        statsGrid
                        
                        // BMI Card
                        bmiCard
                        
                        // Additional Metrics (Mood)
                        metricsSection
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await userProfile.fetchDiaryEntries()
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("ความคืบหน้าของคุณ")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(backgroundColor)
            Spacer()
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 24))
                .foregroundColor(accentColor)
        }
    }
    
    // MARK: - Main Progress Card
    private var mainProgressCard: some View {
        VStack(spacing: 16) {
            Text("คลิปที่ดูแล้ว")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(backgroundColor)
            
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                // Progress Circle
                Circle()
                    .trim(from: 0, to: userProfile.videoProgress)
                    .stroke(
                        accentColor,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: userProfile.videoProgress)
                
                // Center Text
                VStack(spacing: 4) {
                    Text("\(Int(userProfile.videoProgress * 100))%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(backgroundColor)
                    Text("เสร็จสมบูรณ์")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            
            // Text Detail
            Text("\(userProfile.watchedVideoIDs.count) จาก \(userProfile.getRecommendedVideos().count) คลิป")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "flame.fill",
                title: "วันต่อเนื่อง",
                value: "\(userProfile.consecutiveDays)",
                subtitle: "วัน",
                color: primaryColor,
                backgroundColor: primaryColor.opacity(0.1)
            )
            
            StatCard(
                icon: "calendar",
                title: "บันทึกทั้งหมด",
                value: "\(userProfile.diaryEntries.count)",
                subtitle: "ครั้ง",
                color: accentColor,
                backgroundColor: accentColor.opacity(0.1)
            )
        }
    }
    
    // MARK: - BMI Card
    private var bmiCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(bmiColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: "figure.stand")
                        .font(.system(size: 24))
                        .foregroundColor(bmiColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("ค่าดัชนีมวลกาย (BMI)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(backgroundColor)
                    Text(bmiStatus)
                        .font(.system(size: 14))
                        .foregroundColor(bmiColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(bmiColor.opacity(0.15))
                        .cornerRadius(12)
                }
                
                Spacer()
                
                Text(String(format: "%.1f", bmiValue))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(bmiColor)
            }
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ส่วนสูง")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(Int(height))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(backgroundColor)
                        Text("CM")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("น้ำหนัก")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(Int(weight))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(backgroundColor)
                        Text("KG")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Metrics Section
    private var metricsSection: some View {
        VStack(spacing: 16) {
            MetricProgressCard(
                title: "อารมณ์เฉลี่ย",
                icon: "face.smiling",
                progress: userProfile.averageMoodScore,
                color: primaryColor,
                backgroundColor: primaryColor.opacity(0.15)
            )
            
            MetricProgressCard(
                title: "รู้สึกดีขึ้น",
                icon: "heart.fill",
                progress: userProfile.feelingBetterPercentage,
                color: accentColor,
                backgroundColor: accentColor.opacity(0.15)
            )
            
            weeklySummaryCard
        }
    }
    
    // MARK: - Weekly Summary Card
    private var weeklySummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(accentColor)
                Text("สรุปสัปดาห์นี้")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(backgroundColor)
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(0..<7) { day in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(day < 5 ? accentColor : Color.gray.opacity(0.2))
                            .frame(width: 35, height: CGFloat.random(in: 40...100))
                        Text(["จ", "อ", "พ", "พฤ", "ศ", "ส", "อา"][day])
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Components (Reuse)

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 94/255, green: 84/255, blue: 68/255))
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct MetricProgressCard: View {
    let title: String
    let icon: String
    let progress: Double
    let color: Color
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 20))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 94/255, green: 84/255, blue: 68/255))
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 12)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DashboardView()
                .environmentObject(UserProfile.preview)
        }
    }
}
