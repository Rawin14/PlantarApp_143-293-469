//
// DiaryTodayView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

// MARK: - Feeling Model (ปรับเหลือ 3 อารมณ์)
struct Feeling: Identifiable {
    let id = UUID()
    let imageName: String // ชื่อรูปภาพที่จะใส่ใน Assets
    let title: String
    let level: Int // 1 = ดีขึ้น, 2 = เหมือนเดิม, 3 = ปวดมากขึ้น
}

struct DiaryTodayView: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @State private var selectedTab = 0 // 0 = Today, 1 = History
    @State private var currentFeelingIndex = 1 // เริ่มที่ "เหมือนเดิม"
    @State private var selectedFeeling: Feeling?
    @State private var noteText = ""
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255)
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255)
    
    // --- Feeling Data (3 ระดับ) ---
    // ⚠️ วางรูป Feeling ใน Assets.xcassets:
    // "feeling_better" (ดีขึ้น), "feeling_same" (เหมือนเดิม), "feeling_worse" (ปวดมากขึ้น)
    let feelings: [Feeling] = [
        Feeling(imageName: "feeling_better", title: "ดีขึ้น", level: 1),
        Feeling(imageName: "feeling_same", title: "เหมือนเดิม", level: 2),
        Feeling(imageName: "feeling_worse", title: "ปวดมากขึ้น", level: 3)
    ]
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Top Navigation Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Pain Diary")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "gear")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // MARK: - Tab Selector (Today / History)
                HStack(spacing: 0) {
                    // Today Tab
                    Button(action: {
                        withAnimation { selectedTab = 0 }
                    }) {
                        Text("Today")
                            .font(.body)
                            .fontWeight(selectedTab == 0 ? .semibold : .regular)
                            .foregroundColor(selectedTab == 0 ? backgroundColor : .white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == 0 ? cardBackground : Color.clear)
                            .cornerRadius(12)
                    }
                    
                    // History Tab
                    Button(action: {
                        withAnimation { selectedTab = 1 }
                    }) {
                        Text("History")
                            .font(.body)
                            .fontWeight(selectedTab == 1 ? .semibold : .regular)
                            .foregroundColor(selectedTab == 1 ? backgroundColor : .white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == 1 ? cardBackground : Color.clear)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // MARK: - Content Area
                if selectedTab == 0 {
                    todayView
                } else {
                    DiaryHistoryView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Today View
    var todayView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Date Display
                Text(Date(), style: .date)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                // Feeling Carousel
                VStack(spacing: 16) {
                    Text("วันนี้คุณรู้สึกอย่างไร?")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    // Feeling Carousel (ไม่มี Page Indicator ด้านบน)
                    TabView(selection: $currentFeelingIndex) {
                        ForEach(feelings.indices, id: \.self) { index in
                            VStack(spacing: 12) {
                                // ⚠️ รูป Feeling จากฝ่ายกราฟิก
                                if let _ = UIImage(named: feelings[index].imageName) {
                                    Image(feelings[index].imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 180, height: 180)
                                } else {
                                    // Placeholder
                                    Circle()
                                        .fill(getFeelingColor(feelings[index].level))
                                        .frame(width: 180, height: 180)
                                        .overlay(
                                            VStack(spacing: 8) {
                                                Image(systemName: getFeelingIcon(feelings[index].level))
                                                    .font(.system(size: 50))
                                                    .foregroundColor(.white)
                                                Text("Avatar \(index + 1)")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            }
                                        )
                                }
                                
                                Text(feelings[index].title)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // ❌ ปิด indicator ด้านบน
                    .frame(height: 250)
                    
                    // ✅ Page Indicator ด้านล่างเท่านั้น
                    HStack(spacing: 8) {
                        ForEach(feelings.indices, id: \.self) { index in
                            Circle()
                                .fill(currentFeelingIndex == index ? accentColor : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 5)
                }
                .padding(.horizontal, 20)
                
                // Save Button
                Button(action: {
                    selectedFeeling = feelings[currentFeelingIndex]
                    // TODO: บันทึกข้อมูล
                    print("Selected: \(feelings[currentFeelingIndex].title)")
                }) {
                    Text("Save Today's Record")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                // Note Section (Optional)
                VStack(alignment: .leading, spacing: 12) {
                    Text("บันทึกเพิ่มเติม (ถ้ามี)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextEditor(text: $noteText)
                        .frame(height: 100)
                        .padding(12)
                        .background(cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    // Helper Functions
    func getFeelingColor(_ level: Int) -> Color {
        switch level {
        case 1: return Color.green.opacity(0.6)
        case 2: return Color.yellow.opacity(0.6)
        case 3: return Color.red.opacity(0.6)
        default: return Color.gray
        }
    }
    
    func getFeelingIcon(_ level: Int) -> String {
        switch level {
        case 1: return "face.smiling"
        case 2: return "face.dashed"
        case 3: return "face.dashed.fill"
        default: return "face.smiling"
        }
    }
}

#Preview {
    NavigationStack {
        DiaryTodayView()
    }
}
