//
// DashboardView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 31/10/2568 BE.
//

import SwiftUI

struct DashboardView: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @State private var videoProgress: Double = 0.10
    @State private var moodProgress: Double = 0.75 // 75%
    @State private var consecutiveDays: Int = 12
    @State private var totalDays: Int = 30
    @State private var feelingBetter: Double = 0.68 // 68%
    
    // --- BMI Data (เพิ่มใหม่) ---
    @State private var bmiValue: Double = 22.5 // ค่า BMI
    @State private var height: Double = 170 // CM
    @State private var weight: Double = 65 // KG
    
    // --- Custom Colors (ใช้ธีมเดียวกับแอป) ---
    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // ม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียวมะนาว
    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255) // ครีม
    
    // Computed property สำหรับหาสี BMI
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
        case ..<18.5: return "ต่ำกว่าเกณฑ์"
        case 18.5..<25.0: return "ปกติ"
        case 25.0..<30.0: return "เกิน"
        default: return "อ้วน"
        }
    }
    
    var body: some View {
        ZStack {
            cardBackground.ignoresSafeArea() // ครีม
            
            VStack(spacing: 0) {
                // MARK: - Top Navigation Bar
                HStack {
//                    Button(action: { dismiss() }) {
//                        Image(systemName: "chevron.left")
//                            .font(.title3)
//                            .foregroundColor(backgroundColor) // น้ำตาล
//                    }
                    Spacer()
                    Text("Dashboard")
                        .font(.headline)
                        .foregroundColor(backgroundColor)
                    Spacer()
                    // Placeholder สำหรับจัด alignment
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
                        
                        // Main Progress Circle
                        mainProgressCard
                        
                        // Stats Grid
                        statsGrid
                        
                        // BMI Card (เพิ่มใหม่)
                        bmiCard
                        
                        // Additional Metrics
                        metricsSection
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("ความคืบหน้าของคุณ")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(backgroundColor) // น้ำตาล
            Spacer()
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 24))
                .foregroundColor(accentColor) // เขียวมะนาว
        }
    }
    
    // MARK: - Main Progress Card (วงกลมสีเขียว)
    private var mainProgressCard: some View {
        VStack(spacing: 16) {
            Text("คลิปที่ดูแล้ว")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(backgroundColor) // น้ำตาล
            
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                // Progress Circle (สีเขียว)
                Circle()
                    .trim(from: 0, to: videoProgress)
                    .stroke(
                        accentColor, // ✅ เขียวมะนาว
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: videoProgress)
                
                // Center Text
                VStack(spacing: 4) {
                    Text("\(Int(videoProgress * 100))%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(backgroundColor) // น้ำตาล
                    Text("เสร็จสมบูรณ์")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            
            Text("13 จาก 20 คลิป")
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
            // Consecutive Days (ม่วง)
            StatCard(
                icon: "flame.fill",
                title: "วันต่อเนื่อง",
                value: "\(consecutiveDays)",
                subtitle: "วัน",
                color: primaryColor, // ✅ ม่วง
                backgroundColor: primaryColor.opacity(0.1)
            )
            
            // Total Days (เขียว)
            StatCard(
                icon: "calendar",
                title: "รวมทั้งหมด",
                value: "\(totalDays)",
                subtitle: "วัน",
                color: accentColor, // ✅ เขียวมะนาว
                backgroundColor: accentColor.opacity(0.1)
            )
        }
    }
    
    // MARK: - BMI Card (เพิ่มใหม่)
    private var bmiCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // BMI Icon
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
                
                // BMI Value
                Text(String(format: "%.1f", bmiValue))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(bmiColor)
            }
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // Height & Weight Info
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
            // Mood Progress (ม่วง)
//            MetricProgressCard(
//                title: "อารมณ์ดีขึ้น",
//                icon: "face.smiling",
//                progress: moodProgress,
//                color: primaryColor, // ✅ ม่วง
//                backgroundColor: primaryColor.opacity(0.15)
//            )
//            
            // Feeling Better (เขียว)
            MetricProgressCard(
                title: "รู้สึกดีขึ้น",
                icon: "heart.fill",
                progress: feelingBetter,
                color: accentColor, // ✅ เขียวมะนาว
                backgroundColor: accentColor.opacity(0.15)
            )
            
            // Weekly Summary
            weeklySummaryCard
        }
    }
    
    // MARK: - Weekly Summary Card
    private var weeklySummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(accentColor) // เขียวมะนาว
                Text("สรุปสัปดาห์นี้")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(backgroundColor) // น้ำตาล
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(0..<7) { day in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(day < 5 ? accentColor : Color.gray.opacity(0.2)) // ✅ เขียว/เทา
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

// MARK: - Stat Card Component
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon Container (สี่เหลี่ยมมน)
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

// MARK: - Metric Progress Card Component
struct MetricProgressCard: View {
    let title: String
    let icon: String
    let progress: Double
    let color: Color
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icon Container
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
            
            // Progress Bar
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
        }
    }
}
