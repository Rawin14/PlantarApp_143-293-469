//
//  HomeView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//  Redesigned: App Overview with Header Profile Icon
//

import SwiftUI
import AVKit

struct HomeView: View {
    // --- State Variables ---
    @State private var selectedTab = 0
    
    // States for Home Content
    @State private var selectedDate = Date()
    @State private var showVideoPlayer = false
    
    // ✅ เพิ่ม State สำหรับจัดการ Pop-up อาการ
    @State private var selectedDetailPopup: DiaryEntry? = nil
    
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var authManager: AuthManager
    // ✅ เรียกใช้ข้อมูล Diary จากศูนย์กลาง
    @EnvironmentObject var diaryViewModel: DiaryViewModel
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255) // ครีมอ่อน
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // ม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียว
    let sidebarColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียว sidebar
    let challengeCardColor = Color(red: 94/255, green: 84/255, blue: 68/255) // สีน้ำตาล
    
    // ตั้งค่า TabBar
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        let brownColor = UIColor(red: 94/255, green: 84/255, blue: 68/255, alpha: 1.0)
        appearance.backgroundColor = brownColor
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        let activeColor = UIColor(red: 172/255, green: 187/255, blue: 98/255, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.iconColor = activeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: activeColor]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            // MARK: - Main TabView
            TabView(selection: $selectedTab) {
                // Tab 1: Home
                ZStack {
                    backgroundColor.ignoresSafeArea()
                    HomeContent
                }
                .tabItem {
                    Label("หน้าหลัก", systemImage: "house.fill")
                }
                .tag(0)
                
                // Tab 2: Videos
                VideosTabView()
                    .tabItem {
                        Label("วิดิโอ", systemImage: "play.rectangle.fill")
                    }
                    .tag(1)
                
                // Tab 3: Diary
                DiaryTodayView()
                    .tabItem {
                        Label("บันทึกอาการ", systemImage: "book.fill")
                    }
                    .tag(2)
                
                // Tab 4: Profile
                ProfileView()
                    .tabItem {
                        Label("โปรไฟล์", systemImage: "person.fill")
                    }
                    .tag(3)
            }
            .accentColor(accentColor)
            
            // MARK: - Video Player Overlay
            if showVideoPlayer {
                VideoPlayerView(isPresented: $showVideoPlayer)
                    .transition(.move(edge: .bottom))
                    .zIndex(200)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await userProfile.loadFromSupabase()
                await userProfile.fetchLatestScan()
                // ✅ โหลดข้อมูล Diary ประจำเดือนเพื่อเอามาโชว์บนปฏิทิน
                if diaryViewModel.monthEntries.isEmpty {
                    await diaryViewModel.loadEntries(for: Date())
                }
            }
        }
    }
    
    // MARK: - Home Content
    var HomeContent: some View {
        VStack(spacing: 0) {
            // 1. Header (ปรับปรุงใหม่ ใส่ Profile Icon)
            HStack {
                Text("Plantar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                // Notification Icon
                NavigationLink(destination: NotificationView()) {
                    Image(systemName: "bell.fill")
                        .font(.title3)
                        .foregroundColor(.black)
                        .padding(8)
                }
            }
            .padding()
            .background(Color.white)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // 2. Daily Challenge
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("บันทึกติดตามอาการประจำวัน")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("คุณรู้สึกอย่างไรวันนี้?")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        Spacer()
                        Image("PlantarMan")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(20)
                    .background(challengeCardColor)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        selectedTab = 2 // กดแล้วเด้งไปหน้าบันทึกอาการ
                    }
                    
                    // 3. Date & Calendar Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text(currentDateString)
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(getDatesForWeek(), id: \.self) { date in
                                    // ✅ ดึงข้อมูลว่าวันนั้นมีบันทึกไหม
                                    let entryForDate = diaryViewModel.monthEntries.first {
                                        Calendar.current.isDate($0.date, inSameDayAs: date)
                                    }
                                    
                                    DateButton(
                                        date: date,
                                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                        entry: entryForDate,
                                        action: {
                                            // 1. เลื่อนกรอบสีเขียวไปที่วันที่กด
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedDate = date
                                            }
                                            
                                            // 2. ✅ เช็คว่าถ้ามีข้อมูล ให้เปิด Pop-up ขึ้นมาเลย!
                                            if let entry = entryForDate {
                                                selectedDetailPopup = entry
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // 4. Status Snapshot
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ระดับความเสี่ยงของคุณ")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .tracking(1)
                            
                            Text(riskText(severity: userProfile.riskSeverity))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(riskColor(severity: userProfile.riskSeverity))
                            
                            Text("ผลการประเมินความเสี่ยงล่าสุด")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.1), lineWidth: 8)
                                .frame(width: 70, height: 70)
                            Circle()
                                .trim(from: 0, to: 0.75)
                                .stroke(
                                    riskColor(severity: userProfile.riskSeverity),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 70, height: 70)
                            Image(systemName: "waveform.path.ecg")
                                .font(.title2)
                                .foregroundColor(riskColor(severity: userProfile.riskSeverity))
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    
                    
                    // 5. App Features (Grid)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ฟังก์ชันใช้งานด่วน")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            NavigationLink(destination: DashboardView()) {
                                OverviewCard(icon: "doc.text.magnifyingglass", title: "แนวโน้วอาการ", subtitle: "ดูเพิ่มเติม", color: primaryColor)
                            }
                            Button(action: { selectedTab = 1 }) {
                                OverviewCard(icon: "play.rectangle.fill", title: "วีดิโอ", subtitle: "การกายภาพบำบัด", color: accentColor)
                            }
                            if userProfile.riskSeverity == "high" {
                                NavigationLink(destination: ClinicsNearMeView()) {
                                    OverviewCard(
                                        icon: "cross.case.fill",
                                        title: "คลินิก",
                                        subtitle: "ใกล้ฉัน",
                                        color: .red
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        // ✅ หน้าต่าง Pop-up แสดรายละเอียดอาการ
        .sheet(item: $selectedDetailPopup) { entry in
            VStack(spacing: 20) {
                // รูปอิโมจิ
                let comparison = entry.feelingComparison ?? .same
                if let _ = UIImage(named: getComparisonImageName(comparison)) {
                    Image(getComparisonImageName(comparison))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
                
                Text(comparison.displayText)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("บันทึกเมื่อ: \(formatPopupDate(entry.date))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("บันทึกเพิ่มเติม:")
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(entry.note ?? "ไม่มีบันทึกเพิ่มเติม")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding(24)
            .presentationDetents([.medium, .fraction(0.55)]) // เด้งครึ่งจอ
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Helper Function for Popup Image
    func getComparisonImageName(_ comparison: FeelingComparison) -> String {
        switch comparison {
        case .better: return "Smile"
        case .same: return "Normal"
        case .worse: return "Sad"
        }
    }
    
    // MARK: - Videos Tab View
    struct VideosTabView: View {
        @EnvironmentObject var userProfile: UserProfile
        var body: some View {
            NavigationView {
                ZStack {
                    VideoView(riskLevel: userProfile.riskSeverity)
                }
                .navigationBarHidden(true)
            }
        }
    }
    
    // MARK: - Helper Components
    
    struct OverviewCard: View {
        let icon: String
        let title: String
        let subtitle: String
        let color: Color
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    color.opacity(0.15)
                    Image(systemName: icon).font(.title).foregroundColor(color)
                }
                .frame(width: 50, height: 50).cornerRadius(12)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).fontWeight(.bold).foregroundColor(.black).lineLimit(1)
                    Text(subtitle).font(.caption).foregroundColor(.gray).lineLimit(1)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // ✅ อัปเดต DateButton ให้รองรับการแสดงผลอารมณ์
    struct DateButton: View {
        let date: Date
        let isSelected: Bool
        let entry: DiaryEntry? // ข้อมูลการบันทึกของวันนั้น
        let action: () -> Void
        
        var dayName: String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "th_TH")
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        }
        
        var dayNumber: String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "th_TH")
            formatter.dateFormat = "d"
            return formatter.string(from: date)
        }
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    Text(dayName)
                        .font(.caption2)
                        .foregroundColor(isSelected ? .white : .secondary)
                    
                    Text(dayNumber)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isSelected ? .white : .black)
                    
                    // ✅ แสดงไอคอนอารมณ์ใต้ตัวเลข
                    if let entry = entry, let comparison = entry.feelingComparison {
                        Image(comparisonImageName(comparison))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .clipShape(Circle())
                    } else {
                        // ปล่อยว่างเพื่อรักษาระยะห่าง
                        Circle().fill(Color.clear).frame(width: 18, height: 18)
                    }
                }
                .frame(width: 55, height: 85) // เพิ่มความสูงให้พอกับรูปอิโมจิ
                .background(isSelected ? Color(red: 172/255, green: 187/255, blue: 98/255) : Color.white)
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
        
        private func comparisonImageName(_ comparison: FeelingComparison) -> String {
            switch comparison {
            case .better: return "Smile"
            case .same: return "Normal"
            case .worse: return "Sad"
            }
        }
    }
    
    struct VideoPlayerView: View {
        @Binding var isPresented: Bool
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 0) {
                    Spacer()
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(16/9, contentMode: .fit)
                            .overlay(Image(systemName: "figure.yoga").font(.system(size: 80)).foregroundColor(.white))
                        VStack {
                            HStack {
                                Button(action: { withAnimation { isPresented = false } }) {
                                    Image(systemName: "xmark.circle.fill").font(.largeTitle).foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding()
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    var currentDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.calendar = Calendar(identifier: .buddhist)
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
    
    func riskColor(severity: String?) -> Color {
        switch severity {
        case "high": return .red
        case "medium": return .orange
        case "low": return .green
        default: return .gray
        }
    }
    
    func riskText(severity: String?) -> String {
        switch severity {
        case "high": return "ความเสี่ยงสูง"
        case "medium": return "ความเสี่ยงปานกลาง"
        case "low": return "ความเสี่ยงต่ำ"
        default: return "No Data"
        }
    }
    
    func getDatesForWeek() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        var dates: [Date] = []
        for i in -3...3 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }
        return dates
    }
    // เพิ่มฟังก์ชันนี้สำหรับแปลงวันที่ใน Pop-up เป็น พ.ศ. ภาษาไทย
    func formatPopupDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.calendar = Calendar(identifier: .buddhist)
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

#Preview {
    let mockProfile = UserProfile()
    mockProfile.nickname = "สมชาย ใจดี"
    mockProfile.email = "test@example.com"
    mockProfile.height = 170; mockProfile.weight = 75;
    mockProfile.evaluateScore = 9.0
    
    return NavigationStack {
        HomeView()
            .environmentObject(mockProfile)
            .environmentObject(AuthManager())
            .environmentObject(DiaryViewModel()) // ✅ เพิ่มให้ Preview ทำงานได้
    }
}
