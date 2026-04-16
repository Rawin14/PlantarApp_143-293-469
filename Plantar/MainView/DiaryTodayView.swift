//
// DiaryTodayView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

struct DiaryTodayView: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // ✅ 1. เรียกใช้ข้อมูลจากศูนย์กลาง (ViewModel)
    @EnvironmentObject var diaryViewModel: DiaryViewModel
    
    // --- State Variables ---
    @State private var selectedTab = 0
    @State private var currentFeelingIndex = 1
    @State private var selectedFeeling: Feeling?
    @State private var noteText = ""
    
    // --- Alert States ---
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // ✅ 2. เช็คว่ามีข้อมูลของวันนี้ใน ViewModel ไหม (แทนตัวแปร @State เดิม)
    var hasExistingEntry: Bool {
        diaryViewModel.todayEntry != nil
    }
    
    var thaiDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.calendar = Calendar(identifier: .buddhist) // ให้แสดงเป็น พ.ศ.
        formatter.dateStyle = .long // รูปแบบยาว เช่น 17 เมษายน 2569
        return formatter.string(from: Date())
    }
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255)
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255)
    
    // --- Feeling Data ---
    let feelings: [Feeling] = [
        Feeling(imageName: "Smile", title: "ดีขึ้น", level: 5, comparison: .better),
        Feeling(imageName: "Normal", title: "เหมือนเดิม", level: 3, comparison: .same),
        Feeling(imageName: "Sad", title: "แย่ลง", level: 1, comparison: .worse)
    ]
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Top Navigation Bar
                HStack {
                    Spacer()
                    Text("บันทึกอาการ")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // MARK: - Tab Selector
                HStack(spacing: 0) {
                    Button(action: { withAnimation { selectedTab = 0 } }) {
                        Text("วันนี้")
                            .font(.body)
                            .fontWeight(selectedTab == 0 ? .semibold : .regular)
                            .foregroundColor(selectedTab == 0 ? backgroundColor : .white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == 0 ? cardBackground : Color.clear)
                            .cornerRadius(12)
                    }
                    
                    Button(action: { withAnimation { selectedTab = 1 } }) {
                        Text("ประวัติ")
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
        .task {
            // ✅ 3. เมื่อเปิดหน้านี้ ให้โหลดข้อมูลเดือนปัจจุบัน (ถ้ายังไม่มี)
            if diaryViewModel.monthEntries.isEmpty {
                await diaryViewModel.loadEntries(for: Date())
            }
        }
        // ✅ 4. ดักจับว่าถ้าข้อมูลวันนี้มีการเปลี่ยนแปลง (เช่น โหลดเสร็จแล้วพบว่าเคยบันทึกไว้) ให้เอาข้อมูลมาแสดงบนหน้าจอ
        .onChange(of: diaryViewModel.todayEntry?.id) { _ in
            if let entry = diaryViewModel.todayEntry {
                self.noteText = entry.note ?? ""
                if let comparison = entry.feelingComparison,
                   let index = feelings.firstIndex(where: { $0.comparison == comparison }) {
                    self.currentFeelingIndex = index
                }
            }
        }
        .alert("บันทึกสำเร็จ", isPresented: $showSuccessAlert) {
            Button("ตกลง") { }
        } message: {
            Text("บันทึกข้อมูลวันนี้เรียบร้อยแล้ว")
        }
        .alert("เกิดข้อผิดพลาด", isPresented: $showErrorAlert) {
            Button("ตกลง", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Today View
    var todayView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Date Display
                Text(thaiDateString)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                // แสดงสถานะว่ามีข้อมูลวันนี้แล้วหรือยัง
                if hasExistingEntry {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("คุณบันทึกข้อมูลวันนี้แล้ว")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                }
                
                // Feeling Carousel
                VStack(spacing: 16) {
                    Text("วันนี้คุณรู้สึกอย่างไร?")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 16) {
                        // ⬅️ ลูกศรซ้าย
                        Button(action: {
                            withAnimation {
                                if currentFeelingIndex > 0 {
                                    currentFeelingIndex -= 1
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(currentFeelingIndex > 0 ? .white.opacity(0.8) : .clear)
                                .padding(.leading, 16)
                        }
                        
                        TabView(selection: $currentFeelingIndex) {
                            ForEach(feelings.indices, id: \.self) { index in
                                VStack(spacing: 12) {
                                    if let _ = UIImage(named: feelings[index].imageName) {
                                        Image(feelings[index].imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 180, height: 180)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(getFeelingColor(feelings[index].comparison))
                                            .frame(width: 180, height: 180)
                                            .overlay(
                                                VStack(spacing: 8) {
                                                    Image(systemName: getFeelingIcon(feelings[index].comparison))
                                                        .font(.system(size: 50))
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
                        .frame(height: 250)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                        // ➡️ ลูกศรขวา
                        Button(action: {
                            withAnimation {
                                if currentFeelingIndex < feelings.count - 1 {
                                    currentFeelingIndex += 1
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(currentFeelingIndex < feelings.count - 1 ? .white.opacity(0.8) : .clear)
                                .padding(.trailing, 16)
                        }
                    }
                    
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
                
                // ✅ 5. Save Button ใช้สถานะโหลดจาก ViewModel
                Button(action: {
                    Task {
                        await saveDiaryEntry()
                    }
                }) {
                    HStack {
                        if diaryViewModel.isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(hasExistingEntry ? "อัพเดทข้อมูลวันนี้" : "บันทึกข้อมูลวันนี้")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(diaryViewModel.isSaving ? Color.gray : accentColor)
                    .cornerRadius(12)
                }
                .disabled(diaryViewModel.isSaving)
                .padding(.horizontal, 20)
                
                // Note Section
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
    
    // MARK: - ✅ 6. Save Diary Entry ผ่าน ViewModel
    private func saveDiaryEntry() async {
        let selectedFeeling = feelings[currentFeelingIndex]
        let feelingLevel = selectedFeeling.level
        let feelingComparison = selectedFeeling.comparison
        let note = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try await diaryViewModel.saveTodayEntry(
                level: feelingLevel,
                comparison: feelingComparison,
                note: note.isEmpty ? nil : note
            )
            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
    
    // Helper Functions
    func getFeelingColor(_ comparison: FeelingComparison) -> Color {
        switch comparison {
        case .better: return Color.green.opacity(0.6)
        case .same: return Color.yellow.opacity(0.6)
        case .worse: return Color.red.opacity(0.6)
        }
    }
    
    func getFeelingIcon(_ comparison: FeelingComparison) -> String {
        switch comparison {
        case .better: return "face.smiling"
        case .same: return "face.dashed"
        case .worse: return "face.dashed.fill"
        }
    }
}

// MARK: - Feeling Model
struct Feeling: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let level: Int
    let comparison: FeelingComparison
}

#Preview {
    NavigationStack {
        DiaryTodayView()
            .environmentObject(DiaryViewModel()) // ✅ เพิ่ม EnvironmentObject ให้หน้า Preview ไม่แครช
    }
}
