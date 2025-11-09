//
// VideoViewMediumRisk.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

// MARK: - Video Model
struct VideoExerciseMedium: Identifiable {
    let id = UUID()
    let thumbnail: String
    let title: String
    let duration: String
    let difficulty: String
}

struct VideoViewMediumRisk: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @State private var showVideoPlayer = false
    @State private var selectedVideo: VideoExerciseMedium?
    
    // --- Custom Colors (ใช้ธีมเดียวกัน) ---
    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // ม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียวมะนาว
    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255) // ครีม
    let buttonColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    
    // --- Medium Risk Videos ---
    let videos: [VideoExerciseMedium] = [
        VideoExerciseMedium(thumbnail: "video1", title: "ยืดกล้ามเนื้อน่องพิงกำแพง", duration: "3:30", difficulty: "Medium"),
        VideoExerciseMedium(thumbnail: "video2", title: "เขย่งปลายเท้าเพื่อเสริมสร้างความแข็งแรง", duration: "2:45", difficulty: "Medium"),
        VideoExerciseMedium(thumbnail: "video3", title: "นวดฝ่าเท้าด้วยนิ้วหัวแม่มือ", duration: "3:00", difficulty: "Medium"),
        VideoExerciseMedium(thumbnail: "video4", title: "ท่ายืดเหยียดเอ็นฝ่าเท้าแบบครอบคลุม", duration: "4:00", difficulty: "Medium")
    ]
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Browse")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // MARK: - Tips Bar (แถบยาว)
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundColor(accentColor)
                    Text("Tips")
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
                
                // MARK: - Description Section
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Description Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ระดับกลาง: อาการปานกลาง")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(accentColor)
                            
                            Text("สำหรับผู้ที่มีอาการปวดมากขึ้นและเริ่มส่งผลกระทบต่อชีวิตประจำวัน ควรเพิ่มความถี่และความหลากหลายของท่ากายภาพบำบัดเพื่อลดอาการอักเสบและเพิ่มความยืดหยุ่น")
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
                        
                        // Exercise Details
                        VStack(alignment: .leading, spacing: 16) {
                            ExerciseDetailBrown(
                                number: "1",
                                title: "ยืดกล้ามเนื้อน่อง (การยืนพิงกำแพง)",
                                description: "ยืนห่างจากกำแพงประมาณ 1 ช่วงแขน ใช้มือยันกำแพงไว้ ก้าวเท้าข้างหนึ่งไปข้างหน้าและงอเข่า ส่วนเท้าข้างที่ปวดให้เหยียดตรง ส้นเท้าติดพื้น ค้างไว้ 30 วินาที ทำ 3-5 ครั้งต่อข้าง"
                            )
                            
                            ExerciseDetailBrown(
                                number: "2",
                                title: "บริหารโดยการเขย่งปลายเท้า",
                                description: "ยืนตรงโดยใช้มือเกาะขอบโต๊ะหรือกำแพงเพื่อทรงตัว ค่อยๆ ยกส้นเท้าขึ้นช้าๆ แล้วลดส้นเท้าลงช้าๆ ทำซ้ำ 10-15 ครั้ง"
                            )
                            
                            ExerciseDetailBrown(
                                number: "3",
                                title: "นวดฝ่าเท้าด้วยนิ้วหัวแม่มือ",
                                description: "ใช้นิ้วหัวแม่มือกดและนวดคลึงเบาๆ บริเวณฝ่าเท้าจากส้นเท้าไปจนถึงโคนนิ้วเท้า ทำประมาณ 2-3 นาทีต่อข้าง"
                            )
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
                                VideoCardMedium(
                                    video: video,
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
            
            // MARK: - Video Player
            if showVideoPlayer {
                VideoPlayerView(isPresented: $showVideoPlayer)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Video Card Component (Medium Theme)
struct VideoCardMedium: View {
    let video: VideoExerciseMedium
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Thumbnail
                ZStack(alignment: .bottomLeading) {
                    // รูปภาพเต็มพื้นที่
                    Rectangle()
                        .fill(Color(red: 248/255, green: 247/255, blue: 241/255))
                        .aspectRatio(3/4, contentMode: .fit) // กำหนดอัตราส่วน
                        .overlay(
                            Image(systemName: "figure.yoga")
                                .font(.system(size: 60))
                                .foregroundColor(Color(red: 172/255, green: 187/255, blue: 98/255).opacity(0.5))
                        )
                    
                    // Duration Badge (มุมบนขวา)
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
                    
                    // Play Button (มุมล่างซ้าย)
                    VStack {
                        Spacer()
                        HStack {
                            Circle()
                                .fill(Color(red: 172/255, green: 187/255, blue: 98/255))
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
                
                // Info Section
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
    NavigationStack {
        VideoViewMediumRisk()
    }
}
