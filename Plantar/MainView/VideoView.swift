//
//  VideoView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//  Updated for Dynamic Risk Levels
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
    let videoUrl : String
}

// MARK: - Exercise Step Model
struct ExerciseStep: Identifiable {
    let id = UUID()
    let number: String
    let title: String
    let description: String
}

struct VideoView: View {
    // --- รับค่า Risk Level จากภายนอก ---
    var riskLevel: String = "low" // ค่าเริ่มต้น "low", "medium", "high"
    
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @State private var showVideoPlayer = false
    @State private var selectedVideo: VideoExercise?
    
    // --- Computed Properties for Dynamic Content ---
    
    // 1. Theme Colors
    var themeColor: Color {
        switch riskLevel {
        case "high": return Color.red.opacity(0.8)
        case "medium": return Color.orange.opacity(0.8)
        default: return Color(red: 172/255, green: 187/255, blue: 98/255) // เขียว (Low)
        }
    }
    
    var backgroundColor: Color {
        Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล (พื้นหลังหลักคงเดิม)
    }
    
    var cardBackground: Color {
        Color(red: 248/255, green: 247/255, blue: 241/255) // ครีม
    }
    
    // 2. Text Content
    var titleText: String {
        switch riskLevel {
        case "high": return "ระดับสูง: อาการรุนแรง"
        case "medium": return "ระดับปานกลาง: อาการเรื้อรัง"
        default: return "ระดับต่ำ: อาการเบื้องต้น"
        }
    }
    
    var descriptionText: String {
        switch riskLevel {
        case "high": return "สำหรับผู้ที่มีอาการปวดรุนแรง ควรเน้นการพักและการยืดเหยียดแบบนุ่มนวลที่สุด หลีกเลี่ยงการลงน้ำหนักที่ส้นเท้าโดยตรง และควรพบแพทย์"
        case "medium": return "สำหรับผู้ที่มีอาการปวดเป็นประจำ เน้นการยืดเหยียดที่เข้มข้นขึ้นเล็กน้อย และการบริหารเพื่อเพิ่มความแข็งแรงของกล้ามเนื้อรอบข้อเท้า"
        default: return "สำหรับผู้ที่เพิ่งเริ่มมีอาการปวดส้นเท้าไม่มากนัก เป้าหมายเพื่อลดความตึงของเอ็นฝ่าเท้าและกล้ามเนื้อน่อง ป้องกันไม่ให้เป็นมากขึ้น"
        }
    }
    
    // 3. Exercise Steps Data
    var exercises: [ExerciseStep] {
        switch riskLevel {
        case "high":
            return [
                ExerciseStep(number: "1", title: "ประคบเย็น", description: "ใช้น้ำแข็งประคบบริเวณส้นเท้า 15-20 นาที เพื่อลดการอักเสบ"),
                ExerciseStep(number: "2", title: "ยืดผ้าขนหนู (ท่านั่ง)", description: "ใช้ผ้าขนหนูคล้องปลายเท้าแล้วดึงเข้าหาตัวเบาๆ ค้างไว้ 30 วินาที"),
                ExerciseStep(number: "3", title: "พักการใช้งาน", description: "หลีกเลี่ยงการยืนหรือเดินนานๆ และสวมรองเท้าที่นุ่มสบายตลอดเวลา")
            ]
        case "medium":
            return [
                ExerciseStep(number: "1", title: "ยืดน่องกับกำแพง", description: "ยืนดันกำแพง ขาหลังเหยียดตึง ส้นเท้าติดพื้น ค้างไว้ 30 วินาที"),
                ExerciseStep(number: "2", title: "คลึงฝ่าเท้าด้วยลูกบอล", description: "ใช้น้ำหนักกดลงบนลูกบอลเทนนิสแล้วกลิ้งไปมาทั่วฝ่าเท้า 2 นาที"),
                ExerciseStep(number: "3", title: "ฝึกขยำผ้า", description: "ใช้นิ้วเท้าจิกผ้าขนหนูที่วางบนพื้นเข้าหาตัว ทำ 10 ครั้ง 3 เซ็ต")
            ]
        default: // Low
            return [
                ExerciseStep(number: "1", title: "ยืดเหยียดเอ็นฝ่าเท้าด้วยมือ", description: "นั่งบนพื้นแล้วใช้มือดึงนิ้วเท้าเข้าหาตัวช้าๆ จนรู้สึกตึงบริเวณฝ่าเท้า ค้างไว้ 15-30 วินาที"),
                ExerciseStep(number: "2", title: "บริหารด้วยการหมุนข้อเท้า", description: "นั่งบนเก้าอี้ หมุนข้อเท้าเป็นวงกลมช้าๆ ทั้งตามเข็มและทวนเข็มนาฬิกา"),
                ExerciseStep(number: "3", title: "นวดฝ่าเท้าเบื้องต้น", description: "ใช้นิ้วหัวแม่มือหรือลูกบอลนวดบริเวณฝ่าเท้าเบาๆ เพื่อผ่อนคลาย")
            ]
        }
    }
    
    // 4. Videos Data
    var videos: [VideoExercise] {
        switch riskLevel {
        case "high":
            return [
                VideoExercise(thumbnail: "video_e1",
                              title: "ยืดเหยียดเอ็นฝ่าเท้าด้วยมือ",
                              duration: "0:38",
                              difficulty: "Easy",
                              videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/Physical-posture/1.mp4"),
                VideoExercise(thumbnail: "video_e2",
                              title: "บริหารด้วยการหมุนข้อเท้า",
                              duration: "0:42",
                              difficulty: "Easy",
                              videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/Physical-posture/2.mp4"),
                VideoExercise(thumbnail: "video_m1",
                              title: "ยืดกล้ามเนื้อน่อง (การยืนพิงกำแพง)",
                              duration: "3:22",
                              difficulty: "Medium",
                              videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/Physical-posture/3.mp4"),
                VideoExercise(thumbnail: "video_m2",
                              title: "บริหารโดยการเขย่งปลายเท้า",
                              duration: "1:56",
                              difficulty: "Medium",
                              videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/Physical-posture/4.mp4"),
                VideoExercise(thumbnail: "video_m3",
                              title: "นวดฝ่าเท้าด้วยนิ้วหัวแม่มือ",
                              duration: "4:33",
                              difficulty: "Medium",
                              videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/Physical-posture/5.mp4"),
            ]
        case "medium":
            return [
                VideoExercise(thumbnail: "video_m1",
                              title: "ยืดกล้ามเนื้อน่อง (การยืนพิงกำแพง)",
                              duration: "3:22",
                              difficulty: "Medium",
                              videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/Physical-posture/3.mp4"),
                VideoExercise(thumbnail: "video_m2",
                              title: "บริหารโดยการเขย่งปลายเท้า",
                              duration: "1:56",
                              difficulty: "Medium",
                              videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/Physical-posture/4.mp4"),
                VideoExercise(thumbnail: "video_m3",
                              title: "นวดฝ่าเท้าด้วยนิ้วหัวแม่มือ",
                              duration: "4:33",
                              difficulty: "Medium",
                              videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/Physical-posture/5.mp4"),
            ]
        default: // Low
            return [
                VideoExercise(thumbnail: "video_e1",
                              title: "ยืดเหยียดเอ็นฝ่าเท้าด้วยมือ",
                              duration: "0:38",
                              difficulty: "Easy",
                              videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/Physical-posture/1.mp4"),
                VideoExercise(thumbnail: "video_e2",
                              title: "บริหารด้วยการหมุนข้อเท้า",
                              duration: "0:42",
                              difficulty: "Easy",
                              videoUrl: "https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/videos/Physical-posture/2.mp4"),
            ]
        }
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Top Bar
                HStack {
                    // ปุ่ม Back (ซ่อนถ้าเป็นหน้าหลักใน TabView แต่ถ้า Push มาจะแสดง)
                    // ถ้าใช้ใน TabView อาจจะไม่ต้องการปุ่ม Back หรือต้องการปุ่ม Menu
                    Spacer()
                    Text("Recommended Videos")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // MARK: - Tips Bar (แถบสีตาม Risk)
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundColor(themeColor) // ใช้สีตาม Risk
                    Text("Tips for \(riskLevel.capitalized) Risk")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // MARK: - Content ScrollView
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Description Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text(titleText)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(themeColor) // ใช้สีตาม Risk
                            
                            Text(descriptionText)
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.7))
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .background(cardBackground)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Exercise List
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(exercises) { exercise in
                                ExerciseDetailCard(
                                    step: exercise,
                                    badgeColor: themeColor
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // MARK: - Video Grid
                        Text("Recommended Videos")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(videos) { video in
                                VideoCard(
                                    video: video,
                                    themeColor: themeColor,
                                    action: {
                                        selectedVideo = video
                                        showVideoPlayer = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            
            // MARK: - Video Player Overlay
            if showVideoPlayer, let video = selectedVideo {
                            VideoPlayerView(
                                isPresented: $showVideoPlayer,
                                videoUrlString: video.videoUrl // ✅ ส่ง URL ที่เก็บไว้ใน Model ไปให้ Player
                            )
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                        }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Reusable Components

struct ExerciseDetailCard: View {
    let step: ExerciseStep
    let badgeColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Number Badge
            Text(step.number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(badgeColor)
                .clipShape(Circle())
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(step.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(step.description)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.7))
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading) // ให้เต็มความกว้าง
        .background(Color(red: 248/255, green: 247/255, blue: 241/255))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct VideoCard: View {
    let video: VideoExercise
    let themeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Thumbnail
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(Color(red: 248/255, green: 247/255, blue: 241/255))
                        .aspectRatio(3/4, contentMode: .fit)
                        .overlay(
                            Image(systemName: "figure.yoga")
                                .font(.system(size: 60))
                                .foregroundColor(themeColor.opacity(0.5))
                        )
                    
                    // Duration
                    VStack {
                        HStack {
                            Spacer()
                            Text(video.duration)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(4)
                                .padding(8)
                        }
                        Spacer()
                    }
                    
                    // Play Button
                    VStack {
                        Spacer()
                        HStack {
                            Circle()
                                .fill(themeColor)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                        .offset(x: 1)
                                )
                                .padding(10)
                            Spacer()
                        }
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(video.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 8))
                        Text("Guide")
                            .font(.caption2)
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 2, height: 2)
                        Text(video.difficulty)
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VideoView(riskLevel: "medium") // ลองเปลี่ยนเป็น "high" หรือ "low" เพื่อดูผลลัพธ์
}
