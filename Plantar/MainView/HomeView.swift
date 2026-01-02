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
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
                
                // Tab 2: Videos
                VideosTabView()
                    .tabItem {
                        Label("Videos", systemImage: "play.rectangle.fill")
                    }
                    .tag(1)
                
                // Tab 3: Diary
                DiaryTodayView()
                    .tabItem {
                        Label("Diary", systemImage: "book.fill")
                    }
                    .tag(2)
                
                // Tab 4: Profile
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            }
            .accentColor(accentColor)
            
            // MARK: - Sidebar Menu
            if showSidebar {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showSidebar = false } }
                    .zIndex(100)
                
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        // User Info Header
                        VStack(alignment: .center, spacing: 12) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            Text(userProfile.nickname.isEmpty ? "User" : userProfile.nickname)
                                .font(.title3).fontWeight(.bold).foregroundColor(.white)
                            Text(authManager.currentUser?.email ?? "No Email")
                                .font(.caption).foregroundColor(Color.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60).padding(.bottom, 30)
                        
                        Divider().background(Color.white.opacity(0.3))
                        
                        VStack(spacing: 0) {
                            SidebarMenuItem(icon: "chart.bar.fill", title: "Dashboard", action: { showSidebar = false })
                            SidebarMenuItem(icon: "gearshape.fill", title: "Settings", action: { showSidebar = false })
                            Divider().background(Color.white.opacity(0.3)).padding(.vertical, 16)
                            SidebarMenuItem(icon: "rectangle.portrait.and.arrow.right", title: "Logout", action: {
                                showSidebar = false
                                Task { await authManager.signOut() }
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
                .zIndex(101)
            }
            
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
            }
        }
    }
    
    // MARK: - Home Content
    var HomeContent: some View {
        VStack(spacing: 0) {
            // 1. Header (ปรับปรุงใหม่ ใส่ Profile Icon)
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
                
                // Notification Icon
                NavigationLink(destination: NotificationView()) {
                    Image(systemName: "bell.fill")
                        .font(.title3)
                        .foregroundColor(.black)
                        .padding(8)
                }
                
                // ✅ NEW: Profile Icon (ขวาบน)
                Button(action: { selectedTab = 3 }) { // กดแล้วไป Tab Profile (Tab 3)
                    Image(systemName: "person.crop.circle.fill") // รูปไอคอนคนกลมๆ
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.gray) // หรือใช้ .accentColor ถ้าอยากได้สีเขียว
                        .padding(.leading, 4)
                }
            }
            .padding()
            .background(Color.white)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    
                    // 2. Daily Challenge
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
                    .onTapGesture {
                        selectedTab = 2
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
                    }
                    // 4. Status Snapshot
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("YOUR CONDITION")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                    .tracking(1)
                                
                                Text(riskText(severity: userProfile.riskSeverity))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(riskColor(severity: userProfile.riskSeverity))
                                
                                Text("Last scan analysis result")
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
                        Text("Quick Actions")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            NavigationLink(destination: DashboardView()) {
                                OverviewCard(icon: "doc.text.magnifyingglass", title: "Scan History", subtitle: "See details", color: primaryColor)
                            }
                            Button(action: { selectedTab = 1 }) {
                                OverviewCard(icon: "play.rectangle.fill", title: "Therapy Videos", subtitle: "Guided Exercise", color: accentColor)
                            }
                            Button(action: { selectedTab = 2 }) {
                                OverviewCard(icon: "book.fill", title: "Pain Diary", subtitle: "Daily Log", color: challengeCardColor)
                            }
                            
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
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
    
    struct SidebarMenuItem: View {
        let icon: String
        let title: String
        let action: () -> Void
        var body: some View {
            Button(action: action) {
                HStack(spacing: 16) {
                    Image(systemName: icon).font(.title3).foregroundColor(.white).frame(width: 30)
                    Text(title).font(.body).foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 24).padding(.vertical, 16)
            }
        }
    }
    
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
        formatter.dateFormat = "EEEE, d MMMM yyyy"
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

#Preview {
    // 1. สร้างข้อมูลจำลอง (Mock Data)
    let mockProfile = UserProfile()
    mockProfile.nickname = "สมชาย ใจดี"
    mockProfile.email = "test@example.com"
    
    // 2. จำลองผลสแกน (เลือก risk ได้ตามใจ: "low", "medium", "high")
    mockProfile.height = 170; mockProfile.weight = 75; // BMI เริ่มอ้วน (2 คะแนน)
    mockProfile.evaluateScore = 9.0
    
    // 3. ส่งข้อมูลจำลองเข้าไปใน Preview
    return NavigationStack {
        HomeView()
            .environmentObject(mockProfile)
            .environmentObject(AuthManager())
    }
}
