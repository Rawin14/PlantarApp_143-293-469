//
// VideoViewHighRisk.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

// MARK: - Video Model
struct VideoExerciseHigh: Identifiable {
    let id = UUID()
    let thumbnail: String
    let title: String
    let duration: String
    let difficulty: String
}

struct VideoViewHighRisk: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @State private var showVideoPlayer = false
    @State private var selectedVideo: VideoExerciseHigh?
    @State private var navigateToClinics = false // เพิ่ม State สำหรับ Navigation
    
    // --- Custom Colors (ใช้ธีมเดียวกัน) ---
    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // ม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียวมะนาว
    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255) // ครีม
    let buttonColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    
    // --- High Risk Videos ---
    let videos: [VideoExerciseHigh] = [
        VideoExerciseHigh(thumbnail: "video1", title: "ท่ายืดเหยียดแบบเข้มข้น", duration: "5:00", difficulty: "Hard"),
        VideoExerciseHigh(thumbnail: "video2", title: "การนวดเท้าเชิงลึก", duration: "4:30", difficulty: "Hard"),
        VideoExerciseHigh(thumbnail: "video3", title: "ท่าบริหารครอบคลุมทุกกล้ามเนื้อ", duration: "6:00", difficulty: "Hard"),
        VideoExerciseHigh(thumbnail: "video4", title: "เทคนิคการพักเท้าที่ถูกวิธี", duration: "3:30", difficulty: "Hard")
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
                            Text("ระดับสูง: อาการรุนแรง")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(accentColor)
                            
                            Text("สำหรับผู้ที่มีอาการปวดมากจนเป็นอุปสรรคต่อการใช้ชีวิตประจำวัน หรืออาการไม่ดีขึ้นหลังจากทำกายภาพบำบัดเบื้องต้น ควรทำกายภาพบำบัดอย่างต่อเนื่องและพิจารณาการรักษาจากผู้เชี่ยวชาญเพิ่มเติม")
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
                                title: "เพิ่มความถี่ของท่าบริหาร",
                                description: "ทำท่ากายภาพบำบัดในระดับกลางทั้งหมด วันละ 2-3 ครั้ง และทำแต่ละท่าให้ค้างไว้นานขึ้น (เช่น 45-60 วินาที)"
                            )
                            
                            ExerciseDetailBrown(
                                number: "2",
                                title: "การปรับพฤติกรรม",
                                description: "หลีกเลี่ยงการยืนหรือเดินเป็นเวลานานๆ, งดการใส่รองเท้าส้นสูงหรือรองเท้าที่ไม่มีพื้นรองรับที่ดี, และหาโอกาสพักเท้าบ่อยๆ"
                            )
                            
                            ExerciseDetailBrown(
                                number: "3",
                                title: "การรักษาเบื้องต้น",
                                description: "หากอาการไม่ดีขึ้นหลังจากทำกายภาพบำบัดด้วยตนเองเป็นเวลาหลายสัปดาห์ ควรปรึกษาแพทย์หรือนักกายภาพบำบัด เพื่อรับการวินิจฉัยและวางแผนการรักษาที่เหมาะสม เช่น การรักษาด้วยคลื่นอัลตราซาวด์ หรือการบำบัดด้วยคลื่นกระแทก (Shockwave Therapy)"
                            )
                            
                            ExerciseDetailBrown(
                                number: "4",
                                title: "เพิ่มวิธีการนวด",
                                description: "ใช้เทคนิคการนวดเชิงลึกเพื่อผ่อนคลายกล้ามเนื้อและเอ็นที่ตึง ควรทำอย่างสม่ำเสมอเพื่อผลลัพธ์ที่ดีที่สุด"
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Warning Card - เพิ่ม Button เพื่อให้กดได้
                        Button(action: {
                            navigateToClinics = true
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("คำเตือนสำคัญ")
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Text("หากอาการไม่ดีขึ้นภายใน 2-3 สัปดาห์ หรืออาการรุนแรงขึ้น กรุณาปรึกษาแพทย์ผู้เชี่ยวชาญโดยเร็วที่สุด")
                                        .font(.caption)
                                        .foregroundColor(.black.opacity(0.7))
                                        .lineSpacing(3)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(16)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                        
                        // MARK: - Video Grid
                        Text("Recommended Videos")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(videos) { video in
                                VideoCardHigh(
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
                
                // NavigationLink ไปหน้า ClinicsNearMeView
                NavigationLink(
                    destination: ClinicsNearMeView(),
                    isActive: $navigateToClinics
                ) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .hidden()
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

// MARK: - Video Card Component (High Theme)
struct VideoCardHigh: View {
    let video: VideoExerciseHigh
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Thumbnail
                ZStack(alignment: .bottomLeading) {
                    // รูปภาพเต็มพื้นที่
                    Rectangle()
                        .fill(Color(red: 248/255, green: 247/255, blue: 241/255))
                        .aspectRatio(3/4, contentMode: .fit)
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
                            .foregroundColor(.red)
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
        VideoViewHighRisk()
    }
}
