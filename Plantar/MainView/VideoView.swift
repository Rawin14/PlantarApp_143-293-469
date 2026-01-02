//
//  VideoView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//  Redesigned: Streaming Layout with HomeView Tone
//

import SwiftUI
import AVKit

// MARK: - Video Model
struct VideoExercise: Identifiable {
    let id = UUID()
    let thumbnail: String
    let title: String
    let duration: String
    let difficulty: String
    let videoUrl: String
}

// MARK: - Exercise Step Model
struct ExerciseStep: Identifiable {
    let id = UUID()
    let number: String
    let title: String
    let description: String
}

struct VideoView: View {
    // --- รับค่า Risk Level ---
    var riskLevel: String?
    
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    
    // --- State Variables ---
    @State private var showVideoPlayer = false
    @State private var selectedVideo: VideoExercise?
    
    // --- Theme Colors (เหมือน HomeView) ---
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255) // ครีมอ่อน
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // ม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียว
    let brownColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล (หัวข้อ)
    
    // สีตามความเสี่ยง (Risk)
    var themeColor: Color {
        switch userProfile.riskSeverity {
        case "high": return Color.red.opacity(0.8)
        case "medium": return Color.orange.opacity(0.8)
        default: return accentColor // เขียวเดียวกับ HomeView
        }
    }
    
    // --- Data (คงเดิม) ---
    var exercises: [ExerciseStep] {
        switch userProfile.riskSeverity {
        case "high":
            return [
                ExerciseStep(number: "1", title: "ประคบเย็น", description: "ใช้น้ำแข็งประคบบริเวณส้นเท้า 15-20 นาที"),
                ExerciseStep(number: "2", title: "ยืดผ้าขนหนู", description: "ใช้ผ้าขนหนูคล้องปลายเท้าแล้วดึงเข้าหาตัว"),
                ExerciseStep(number: "3", title: "พักการใช้งาน", description: "หลีกเลี่ยงการยืนนานๆ และใส่รองเท้านุ่มๆ")
            ]
        case "medium":
            return [
                ExerciseStep(number: "1", title: "ยืดน่องกับกำแพง", description: "ยืนดันกำแพง ขาหลังเหยียดตึง ส้นเท้าติดพื้น"),
                ExerciseStep(number: "2", title: "คลึงลูกบอล", description: "ใช้ฝ่าเท้ากลิ้งลูกบอลเทนนิสไปมา"),
                ExerciseStep(number: "3", title: "ฝึกขยำผ้า", description: "ใช้นิ้วเท้าจิกผ้าขนหนูเข้าหาตัว")
            ]
        default: // Low
            return [
                ExerciseStep(number: "1", title: "ยืดฝ่าเท้า", description: "ใช้มือดึงนิ้วเท้าเข้าหาตัวช้าๆ"),
                ExerciseStep(number: "2", title: "หมุนข้อเท้า", description: "หมุนข้อเท้าเป็นวงกลมทั้งสองข้าง"),
                ExerciseStep(number: "3", title: "นวดผ่อนคลาย", description: "นวดบริเวณฝ่าเท้าเบาๆ")
            ]
        }
    }
    
    var videos: [VideoExercise] {
        
        switch userProfile.riskSeverity {
            
        case "high":
            
            return [
                
                VideoExercise(thumbnail: "video_e1", title: "ยืดเหยียดเอ็นฝ่าเท้า", duration: "1:56", difficulty: "Easy", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/1.mp4"),
                
                VideoExercise(thumbnail: "video_e2", title: "บริหารข้อเท้า", duration: "0:42", difficulty: "Easy", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/2.mp4"),
                
                VideoExercise(thumbnail: "video_m1", title: "ยืดกล้ามเนื้อน่อง", duration: "3:22", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/3.mp4"),
                
                VideoExercise(thumbnail: "video_m2", title: "เขย่งปลายเท้า", duration: "0:38", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/4.mp4"),
                
                VideoExercise(thumbnail: "video_m3", title: "นวดกดจุดฝ่าเท้า", duration: "4:33", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/5.mp4"),
                
            ]
            
        case "medium":
            
            return [
                
                VideoExercise(thumbnail: "video_m1", title: "ยืดกล้ามเนื้อน่อง", duration: "3:22", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/3.mp4"),
                
                VideoExercise(thumbnail: "video_m2", title: "เขย่งปลายเท้า", duration: "1:56", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/4.mp4"),
                
                VideoExercise(thumbnail: "video_m3", title: "นวดกดจุดฝ่าเท้า", duration: "4:33", difficulty: "Medium", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/5.mp4"),
                
            ]
            
        default: // Low
            
            return [
                
                VideoExercise(thumbnail: "video_e1", title: "ยืดเหยียดเอ็นฝ่าเท้า", duration: "1:56", difficulty: "Easy", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/1.mp4"),
                
                VideoExercise(thumbnail: "video_e2", title: "บริหารข้อเท้า", duration: "0:42", difficulty: "Easy", videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/2.mp4"),
                
            ]
            
        }
        
    }
    
    var body: some View {
        ZStack {
            // Background สีครีมอ่อน (Plantar Theme)
            backgroundColor.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: 1. Hero Section (วิดีโอแนะนำขนาดใหญ่)
                    if let heroVideo = videos.first {
                        HeroVideoCard(video: heroVideo, themeColor: brownColor) {
                            selectedVideo = heroVideo
                            showVideoPlayer = true
                        }
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    
                    // MARK: 2. Status Banner
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundColor(.white) // ไอคอนขาว
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
                    .background(themeColor) // พื้นหลังสีน้ำตาล (เหมือนการ์ดใน HomeView)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(color: themeColor.opacity(0.3), radius: 5, x: 0, y: 3)
                    
                    // MARK: 3. Daily Routine (Steps)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Routine Steps")
                            .font(.title3).bold()
                            .foregroundColor(brownColor) // หัวข้อสีน้ำตาล
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(exercises) { step in
                                    StepCardStream(step: step, color: primaryColor)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 10) // เผื่อเงา
                        }
                    }
                    
                    // MARK: 4. Other Clips (Video Carousel)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Other Clips")
                            .font(.title3).bold()
                            .foregroundColor(brownColor) // หัวข้อสีน้ำตาล
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // ใช้ dropFirst เพื่อไม่ให้ซ้ำกับ Hero Video
                                ForEach(videos.dropFirst()) { video in
                                    SmallVideoCardStream(video: video, themeColor: themeColor) {
                                        selectedVideo = video
                                        showVideoPlayer = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                    
                    Spacer(minLength: 120) // เผื่อพื้นที่ด้านล่าง
                }
            }
            .ignoresSafeArea(edges: .top) // ให้รูป Hero ชนขอบบนสุด
            
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
        // เอา preferredColorScheme(.dark) ออก เพื่อให้ใช้สีตามระบบ (หรือสีที่เรากำหนดเอง)
    }
}

// MARK: - Components (ปรับสีให้เข้ากับธีม)

struct HeroVideoCard: View {
    let video: VideoExercise
    let themeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // Background Image
                if UIImage(named: video.thumbnail) != nil {
                    Image(video.thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 420)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(white: 0.9))
                        .frame(height: 420)
                        .overlay(Image(systemName: "figure.yoga").font(.system(size: 80)).foregroundColor(.gray))
                }
                
                // Gradient Overlay (เพื่อให้ตัวหนังสืออ่านง่าย)
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Content Info
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("FEATURED")
                            .font(.caption).bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(themeColor)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                        Spacer()
                    }
                    
                    Text(video.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .shadow(radius: 5)
                    
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
                .padding(.bottom, 20)
            }
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
                    .foregroundColor(color) // เลขสีตาม Risk
                Spacer()
                Image(systemName: "figure.walk")
                    .font(.title2)
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            
            Text(step.title)
                .font(.headline)
                .foregroundColor(.black) // ตัวหนังสือสีดำ (บนพื้นขาว)
                .lineLimit(1)
            
            Text(step.description)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(width: 160, height: 180)
        .background(Color.white) // พื้นหลังขาว
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2) // เงาบางๆ
    }
}

struct SmallVideoCardStream: View {
    let video: VideoExercise
    let themeColor: Color
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
                            .fill(Color(white: 0.9)) // พื้นเทาอ่อน
                            .frame(width: 200, height: 112)
                            .cornerRadius(8)
                            .overlay(Image(systemName: "play.circle").font(.largeTitle).foregroundColor(.gray))
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
                    .foregroundColor(.black) // ตัวหนังสือสีดำ
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

// MARK: - Online Video Player (อันเดิม)
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
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                    Text("Invalid URL")
                        .foregroundColor(.white)
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
    // 1. สร้างข้อมูลจำลอง (Mock Data)
    let mockProfile = UserProfile()
    mockProfile.nickname = "สมชาย ใจดี"
    mockProfile.email = "test@example.com"
    
    // 2. จำลองผลสแกน (เลือก risk ได้ตามใจ: "low", "medium", "high")
    mockProfile.height = 170; mockProfile.weight = 75; // BMI เริ่มอ้วน (2 คะแนน)
    mockProfile.evaluateScore = 9.0
    
    // 3. ส่งข้อมูลจำลองเข้าไปใน Preview
    return NavigationStack {
        VideoView()
            .environmentObject(mockProfile)
            .environmentObject(AuthManager())
    }
}
