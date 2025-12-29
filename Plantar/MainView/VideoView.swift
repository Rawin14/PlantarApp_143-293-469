//
// VideoViewLowRisk.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

// MARK: - Video Model
struct VideoExercise: Identifiable {
    let id = UUID()
    let thumbnail: String
    let title: String
    let duration: String
    let difficulty: String
}

struct VideoView: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @State private var showVideoPlayer = false
    @State private var selectedVideo: VideoExercise?
    
    // --- Custom Colors (ใช้ธีมเดียวกัน) ---
    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // ม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียวมะนาว
    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255) // ครีม
    let buttonColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    
    // --- Low Risk Videos ---
    let videos: [VideoExercise] = [
        VideoExercise(thumbnail: "video1", title: "ยืดเหยียดเอ็นฝ่าเท้าด้วยมือ", duration: "2:30", difficulty: "Easy"),
        VideoExercise(thumbnail: "video2", title: "บริหารด้วยการหมุนข้อเท้า", duration: "3:00", difficulty: "Easy"),
        VideoExercise(thumbnail: "video3", title: "นวดฝ่าเท้าเบื้องต้น", duration: "2:00", difficulty: "Easy"),
        VideoExercise(thumbnail: "video4", title: "ยืดเหยียดนิ้วเท้า", duration: "1:45", difficulty: "Easy")
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
                            Text("ระดับต่ำ: อาการเบื้องต้น")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(accentColor)
                            
                            Text("เป็นคำแนะนำสำหรับผู้ที่เพิ่งเริ่มมีอาการปวดส้นเท้าไม่มากนักและอาการไม่คงที่ มีเป้าหมายเพื่อลดความตึงของเอ็นฝ่าเท้าและกล้ามเนื้อน่อง")
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
                                title: "ยืดเหยียดเอ็นฝ่าเท้าด้วยมือ",
                                description: "นั่งบนพื้นแล้วใช้มือดึงนิ้วเท้าเข้าหาตัวช้าๆ จนรู้สึกตึงบริเวณฝ่าเท้า ค้างไว้ 15-30 วินาที ทำซ้ำ 3-5 ครั้งต่อข้าง"
                            )
                            
                            ExerciseDetailBrown(
                                number: "2",
                                title: "บริหารด้วยการหมุนข้อเท้า",
                                description: "นั่งบนเก้าอี้ ยกเท้าขึ้นเหนือพื้นเล็กน้อย แล้วหมุนข้อเท้าเป็นวงกลมช้าๆ ทั้งตามเข็มและทวนเข็มนาฬิกา ด้านละ 10-15 ครั้ง"
                            )
                            
                            ExerciseDetailBrown(
                                number: "3",
                                title: "เพิ่มวิธีการนวด",
                                description: "ใช้นิ้วหัวแม่มือหรือลูกบอลเทนนิสนวดบริเวณฝ่าเท้าเบาๆ เพื่อผ่อนคลายกล้ามเนื้อและเอ็น"
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
                                VideoCardBrown(
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

// MARK: - Exercise Detail Component (Brown Theme)
struct ExerciseDetailBrown: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Number Badge
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color(red: 172/255, green: 187/255, blue: 98/255))
                .clipShape(Circle())
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.7))
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .background(Color(red: 248/255, green: 247/255, blue: 241/255))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Video Card Component (Brown Theme)
struct VideoCardBrown: View {
    let video: VideoExercise
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
        VideoView()
    }
}
