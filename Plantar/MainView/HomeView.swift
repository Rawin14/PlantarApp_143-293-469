//
//  HomeView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

struct HomeView: View {
    // --- State Variables ---
    @State private var showSidebar = false
    @State private var selectedTab = 0
    
    // States for Home Content
    @State private var selectedDate = Date()
    @State private var showVideoPlayer = false
    
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var authManager: AuthManager
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255) // ครีมอ่อน
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // ม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียว
    let sidebarColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียว sidebar
    let tabBarColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    let challengeCardColor = Color(red: 94/255, green: 84/255, blue: 68/255) // สีน้ำตาล
    
    var body: some View {
        ZStack {
            // Background
            if selectedTab == 0 {
                backgroundColor.ignoresSafeArea()
            } else {
                Color.white.ignoresSafeArea() // พื้นหลังสำหรับหน้าอื่นๆ
            }

            VStack(spacing: 0) {
                // MARK: - Content Area (สลับหน้าตรงนี้)
                ZStack {
                    switch selectedTab {
                    case 0:
                        HomeContent // หน้า Dashboard (แยกออกมาเป็นตัวแปรด้านล่าง)
                    case 1:
                        VideosTabView() // หน้า Videos (สร้างใหม่ให้ด้านล่าง)
                    case 2:
                        DiaryTodayView() // หน้า Diary (มีไฟล์อยู่แล้ว)
                    case 3:
                        ProfileView() // หน้า Profile (มีไฟล์อยู่แล้ว)
                    default:
                        HomeContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // MARK: - Bottom Tab Bar
                HStack(spacing: 0) {
                    TabBarButton(
                        icon: "house.fill",
                        title: "Home",
                        isSelected: selectedTab == 0,
                        action: { selectedTab = 0 }
                    )
                    
                    TabBarButton(
                        icon: "play.rectangle.fill",
                        title: "Videos",
                        isSelected: selectedTab == 1,
                        action: { selectedTab = 1 }
                    )
                    
                    TabBarButton(
                        icon: "book.fill",
                        title: "Diary",
                        isSelected: selectedTab == 2,
                        action: { selectedTab = 2 }
                    )
                    
                    TabBarButton(
                        icon: "person.fill",
                        title: "Profile",
                        isSelected: selectedTab == 3,
                        action: { selectedTab = 3 }
                    )
                }
                .padding(.vertical, 12)
                .background(tabBarColor)
            }
            .ignoresSafeArea(.keyboard) // ป้องกัน Tab Bar ดันขึ้นเมื่อคีย์บอร์ดมา
            
            // MARK: - Sidebar Menu (Overlay)
            if showSidebar {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showSidebar = false } }
                
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        // User Info Header
                        VStack(alignment: .center, spacing: 12) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                            Text(userProfile.nickname.isEmpty ? "User" : userProfile.nickname)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(authManager.currentUser?.email ?? "No Email")
                                .font(.caption)
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                        .padding(.bottom, 30)
                        
                        Divider().background(Color.white.opacity(0.3))
                        
                        // Menu Items
                        VStack(spacing: 0) {
                            SidebarMenuItem(icon: "chart.bar.fill", title: "Dashboard", action: { showSidebar = false })
                            SidebarMenuItem(icon: "gearshape.fill", title: "Settings", action: { showSidebar = false })
                            
                            Divider().background(Color.white.opacity(0.3)).padding(.vertical, 16)
                            
                            SidebarMenuItem(icon: "rectangle.portrait.and.arrow.right", title: "Logout", action: {
                                showSidebar = false
                                Task {
                                    await authManager.signOut()
                                }
                            })
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    .frame(width: 280)
                    .background(sidebarColor)
                    .transition(.move(edge: .leading))
                    
                    Spacer()
                }
                .zIndex(100)
            }
            
            // MARK: - Full Screen Video Player (Overlay for Home Tab)
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
            }
        }
    }
    
    // MARK: - Home Content (หน้า Dashboard เดิม)
    var HomeContent: some View {
        VStack(spacing: 0) {
            // Header (เฉพาะหน้า Home)
            HStack {
                Button(action: { withAnimation { showSidebar.toggle() } }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.black)
                        .padding(8)
                }
                Spacer()
                Text("Plantar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Spacer()
                NavigationLink(destination: NotificationView()) {
                    Image(systemName: "bell.fill")
                        .font(.title3)
                        .foregroundColor(.black)
                        .padding(8)
                }
            }
            .padding()
            .background(Color.white)
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Challenge Card
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Daily\nchallenge")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("How are you feeling today?")
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
                    .padding(.top, 20)
                    .onTapGesture {
                        selectedTab = 2 // กดแล้วไปหน้า Diary
                    }
                    
                    // Week Calendar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(getDatesForWeek(), id: \.self) { date in
                                DateButton(
                                    date: date,
                                    isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                    action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedDate = date
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Risk & Progress Cards
                    HStack(spacing: 16) {
                        // High Risk Card
                        NavigationLink(destination: DashboardView()) {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(riskColor(severity: userProfile.latestScan?.pf_severity))
                                        .frame(width: 70, height: 70)
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 35))
                                        .foregroundColor(.white)
                                }
                                Text(riskText(severity: userProfile.latestScan?.pf_severity))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(challengeCardColor)
                            .cornerRadius(20)
                        }
                        
                        // Progress Card
                        VStack(spacing: 16) {
                            ZStack {
                                Circle().stroke(Color.white.opacity(0.3), lineWidth: 8).frame(width: 70, height: 70)
                                Circle()
                                    .trim(from: 0, to: 0.87)
                                    .stroke(accentColor, lineWidth: 8)
                                    .frame(width: 70, height: 70)
                                    .rotationEffect(.degrees(-90))
                                Text("87%").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                            }
                            Text("Progress").font(.headline).fontWeight(.bold).foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(challengeCardColor)
                        .cornerRadius(20)
                    }
                    .padding(.horizontal, 20)
                    
                    // Video Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stretching Videos")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<3) { index in
                                    VideoCardCompact(
                                        thumbnail: "video_thumbnail_\(index)",
                                        duration: "00:35",
                                        title: "Yoga Exercise",
                                        action: { showVideoPlayer = true }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .background(backgroundColor)
        }
    }
    
    // MARK: - Videos Tab View (สร้างเพิ่มให้สำหรับ Tab 1)
    struct VideosTabView: View {
            @EnvironmentObject var userProfile: UserProfile
            
            var body: some View {
                NavigationView {
                    ZStack {
                        // ส่งค่า riskLevel จากผลสแกนล่าสุด
                        // ถ้าไม่มีค่า ให้ default เป็น "low"
                        VideoView(riskLevel: userProfile.latestScan?.pf_severity ?? "low")
                    }
                    .navigationBarHidden(true)
                }
            }
        }
    
    struct VideoCategoryCard: View {
        let title: String
        let subtitle: String
        let color: Color
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "play.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .padding(25)
            .background(color.opacity(0.8))
            .cornerRadius(20)
            .shadow(radius: 5)
        }
    }
    
    // MARK: - Helper Functions
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
        case "high": return "High Risk"
        case "medium": return "Medium Risk"
        case "low": return "Low Risk"
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
}

// MARK: - Component Definitions (ย้ายมาไว้ข้างนอกให้เป็นระเบียบ)

struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayOfWeek(from: date))
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : .secondary)
                Text("\(dayOfMonth(from: date))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isSelected ? .white : .black)
            }
            .frame(width: 50, height: 70)
            .background(isSelected ? Color(red: 172/255, green: 187/255, blue: 98/255) : Color.white)
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    func dayOfMonth(from date: Date) -> Int {
        Calendar.current.component(.day, from: date)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? Color(red: 172/255, green: 187/255, blue: 98/255) : .white)
            .frame(maxWidth: .infinity)
        }
    }
}

struct SidebarMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 30)
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

struct VideoCardCompact: View {
    let thumbnail: String
    let duration: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 280)
                    .overlay(
                        Image(systemName: "figure.yoga")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.6))
                    )
                
                Circle()
                    .fill(Color(red: 172/255, green: 187/255, blue: 98/255))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    )
                    .position(x: 100, y: 140)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(duration)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(12)
            }
        }
    }
}

struct VideoPlayerView: View {
    @Binding var isPresented: Bool
    @State private var isPlaying = false
    
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
                                Image(systemName: "xmark.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
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

#Preview {
    NavigationStack{
        HomeView()
            .environmentObject(UserProfile())
            .environmentObject(AuthManager())
    }
}
