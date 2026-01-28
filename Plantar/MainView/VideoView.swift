//
//  VideoView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//  Redesigned: Streaming Layout with HomeView Tone
//

import SwiftUI
import AVKit

struct VideoView: View {
    // --- รับค่า Risk Level (Optional ถ้าจะใช้ Override) ---
    var riskLevel: String?
    
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile // ✅ ใช้ข้อมูลจริงจาก UserProfile
    
    // --- State Variables ---
    @State private var showVideoPlayer = false
    @State private var selectedVideo: VideoExercise?
    
    // --- Theme Colors ---
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255) // ครีมอ่อน
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // ม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียว
    let brownColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    
    // สีตามความเสี่ยง (Risk)
    var themeColor: Color {
        switch userProfile.riskSeverity {
        case "high": return Color.red.opacity(0.8)
        case "medium": return Color.orange.opacity(0.8)
        default: return accentColor
        }
    }
    
    // ✅ ดึงข้อมูลวิดีโอและท่าบริหารจาก UserProfile โดยตรง
    var exercises: [ExerciseStep] {
        return userProfile.getRecommendedExercises()
    }
    
    var videos: [VideoExercise] {
        return userProfile.getRecommendedVideos()
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundColor.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: 1. Hero Section (วิดีโอแรก)
                    if let heroVideo = videos.first {
                        HeroVideoCard(video: heroVideo, themeColor: brownColor) {
                            playVideo(heroVideo) // เล่นและบันทึก
                        }
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                    }
                    
                    // MARK: 2. Status Banner
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Current Status: \(riskText(severity: userProfile.riskSeverity)) Risk")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Recommended daily routine for you")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(themeColor)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(color: themeColor.opacity(0.3), radius: 5, x: 0, y: 3)
                    
                    // MARK: 3. Daily Routine (Steps)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Routine Steps")
                            .font(.title3).bold()
                            .foregroundColor(brownColor)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(exercises) { step in
                                    StepCardStream(step: step, color: primaryColor)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                        }
                    }
                    
                    // MARK: 4. Other Clips (Video Carousel)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Other Clips")
                            .font(.title3).bold()
                            .foregroundColor(brownColor)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // ใช้ dropFirst เพื่อไม่ให้ซ้ำกับ Hero Video
                                ForEach(videos.dropFirst()) { video in
                                    SmallVideoCardStream(
                                        video: video,
                                        themeColor: themeColor,
                                        isWatched: userProfile.watchedVideoIDs.contains(video.id) // ✅ เช็คว่าดูยัง
                                    ) {
                                        playVideo(video)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                    
                    Spacer(minLength: 120)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // MARK: - Video Player Overlay
            if showVideoPlayer, let video = selectedVideo {
                OnlineVideoPlayer(
                    isPresented: $showVideoPlayer,
                    videoUrlString: video.videoUrl
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(showVideoPlayer ? .hidden : .visible, for: .tabBar)
    }
    
    // ✅ ฟังก์ชันเล่นและบันทึกผลการดู
    func playVideo(_ video: VideoExercise) {
        selectedVideo = video
        showVideoPlayer = true
        userProfile.markVideoAsWatched(id: video.id) // บันทึกว่าดูแล้ว
    }
}

// MARK: - Components (ปรับปรุงให้รองรับ isWatched)

struct HeroVideoCard: View {
    let video: VideoExercise
    let themeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // 1. Background Image
                if UIImage(named: video.thumbnail) != nil {
                    GeometryReader { geometry in
                        Image(video.thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height) //
                            .clipped()
                    }
                    .frame(height: 400) // ✅ กำหนดความสูงที่ Container แทน
                } else {
                    Rectangle()
                        .fill(Color(white: 0.9))
                        .frame(height: 400)
                        .overlay(Image(systemName: "figure.yoga").font(.system(size: 80)).foregroundColor(.gray))
                }
                
                // 2. Gradient Overlay (ปรับให้เข้มขึ้นและสูงขึ้นเพื่อให้ตัวหนังสือลอยเด่น)
                LinearGradient(
                    colors: [.clear, .black.opacity(0.4), .black.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // 3. Content Info
                VStack(alignment: .leading, spacing: 8) { // ลด spacing นิดหน่อยให้กระชับ
                    // Badge
                    Text("FEATURED")
                        .font(.caption).bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeColor)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    // Title
                    Text(video.title)
                        .font(.system(size: 28, weight: .bold)) // อาจลดเหลือ 24-26 ถ้าชื่อยาวมาก
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .shadow(radius: 5)
                        .padding(.bottom, 2)
                    
                    // Stats
                    HStack(spacing: 16) {
                        Label(video.duration, systemImage: "clock")
                        Label(video.difficulty, systemImage: "chart.bar")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    
                    // Play Button
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play Now")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.top, 8)
                }
                .padding(24)
                .padding(.bottom, 10) // ขยับ padding ล่างขึ้นนิดนึง
            }
            .cornerRadius(15) // ✅ เพิ่มความมนให้การ์ดดูทันสมัย (Optional)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StepCardStream: View {
    let step: ExerciseStep
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(step.number)
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(color)
                Spacer()
                Image(systemName: "figure.walk")
                    .font(.title2)
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            Text(step.title).font(.headline).foregroundColor(.black).lineLimit(1)
            Text(step.description).font(.caption).foregroundColor(.gray).lineLimit(3).fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(width: 160, height: 180)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SmallVideoCardStream: View {
    let video: VideoExercise
    let themeColor: Color
    var isWatched: Bool = false // ✅ รับสถานะการดู
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Thumbnail
                ZStack(alignment: .bottomTrailing) {
                    if UIImage(named: video.thumbnail) != nil {
                        Image(video.thumbnail)
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(width: 200, height: 112)
                            .cornerRadius(8)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color(white: 0.9))
                            .frame(width: 200, height: 112)
                            .cornerRadius(8)
                            .overlay(Image(systemName: "play.circle").font(.largeTitle).foregroundColor(.gray))
                    }
                    
                    // ✅ แสดงเครื่องหมายถูกมุมขวาบน ถ้าดูแล้ว
                    if isWatched {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .background(Circle().fill(Color.white))
                            .padding(6)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    }
                    
                    // Duration Badge
                    Text(video.duration)
                        .font(.caption2).bold()
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                        .padding(6)
                }
                
                // Title
                Text(video.title)
                    .font(.subheadline).bold()
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .frame(width: 200, alignment: .leading)
                
                // Difficulty
                Text(video.difficulty)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Online Video Player
struct OnlineVideoPlayer: View {
    @Binding var isPresented: Bool
    let videoUrlString: String
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            
            if let encodedString = videoUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: encodedString) {
                
                VideoPlayer(player: player)
                    .onAppear {
                        if player == nil {
                            player = AVPlayer(url: url)
                        }
                        player?.play()
                    }
                    .ignoresSafeArea()
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle).foregroundColor(.yellow)
                    Text("Invalid URL").foregroundColor(.white)
                }
            }
            
            Button(action: {
                player?.pause()
                player = nil
                withAnimation { isPresented = false }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 60)
                    .padding(.trailing, 20)
            }
        }
    }
}

func riskText(severity: String?) -> String {
    switch severity {
    case "high": return "High"
    case "medium": return "Medium"
    case "low": return "Low"
    default: return "No Data"
    }
}

#Preview {
    // Mock Data สำหรับ Preview
    let mockProfile = UserProfile()
    mockProfile.height = 170; mockProfile.weight = 75;
    mockProfile.evaluateScore = 9.0
    
    return NavigationStack {
        VideoView()
            .environmentObject(mockProfile)
            .environmentObject(AuthManager())
    }
}
