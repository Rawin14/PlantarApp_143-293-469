//
//  DiaryHistoryView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

struct DiaryHistoryView: View {
    // --- State Variables ---
    @State private var selectedMonth = Date()
    @State private var selectedDateForDetail: Date? = nil
    @State private var selectedEntryForDetail: DiaryEntry? = nil
    @State private var showDiaryDetailSheet: Bool = false
    
    // ✅ ดึงข้อมูลและสถานะทั้งหมดมาจาก ViewModel
    @EnvironmentObject var diaryViewModel: DiaryViewModel
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255)
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255)
    
    // ✅ Calendar Setup
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "th_TH")
        cal.firstWeekday = 2 // เริ่มวันจันทร์
        return cal
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            // ✅ ใช้ isLoading จาก ViewModel
            if diaryViewModel.isLoading {
                ProgressView("กำลังโหลด...")
                    .foregroundColor(.white)
            } else {
                contentView
            }
        }
        .task { await diaryViewModel.loadEntries(for: selectedMonth) } // ✅ ใช้ ViewModel โหลด
        .onChange(of: selectedMonth) {
            Task { await diaryViewModel.loadEntries(for: selectedMonth) }
        }
    }
    
    var contentView: some View {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: - Month Selector
                    HStack {
                        Button(action: { changeMonth(-1) }) {
                            Image(systemName: "chevron.left").font(.title3).foregroundColor(.white)
                        }
                        Spacer()
                        Text(monthYearString(from: selectedMonth))
                            .font(.title3).fontWeight(.semibold).foregroundColor(.white)
                        Spacer()
                        Button(action: { changeMonth(1) }) {
                            Image(systemName: "chevron.right").font(.title3).foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // MARK: - Calendar Grid
                    VStack(alignment: .leading, spacing: 12) {
                        // หัวตาราง
                        HStack {
                            ForEach(["จ.", "อ.", "พ.", "พฤ.", "ศ.", "ส.", "อา."], id: \.self) { day in
                                Text(day)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        // ✅ ตารางวันที่ (แก้กลับมาเป็น LazyVGrid และทำให้กดได้)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                            let days = getDaysInMonth()
                            
                            ForEach(days.indices, id: \.self) { index in
                                if let date = days[index] {
                                    let entry = getEntry(for: date)
                                    
                                    DayCell(date: date, entry: entry)
                                        .onTapGesture {
                                            // เมื่อกดที่วันที่ ให้ดึงข้อมูลและเปิด Sheet
                                            selectedDateForDetail = date
                                            selectedEntryForDetail = entry
                                            showDiaryDetailSheet = true
                                        }
                                } else {
                                    Color.clear.frame(height: 60)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(cardBackground)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .padding(.horizontal, 20)
                    
                    // Statistics
                    if !diaryViewModel.monthEntries.isEmpty {
                        statisticsSection
                    }
                }
                .padding(.bottom, 40)
            }
            // ✅ Sheet สำหรับเด้งขึ้นมาแสดงข้อมูล
            .sheet(isPresented: $showDiaryDetailSheet) {
                if let date = selectedDateForDetail {
                    DiaryDetailSheet(date: date, entry: selectedEntryForDetail)
                        .presentationDetents([.medium, .fraction(1)])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    
    // MARK: - Statistics Section
    var statisticsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("สรุปเดือนนี้")
                    .font(.title3).fontWeight(.bold).foregroundColor(.black)
                Spacer()
                Text("\(diaryViewModel.monthEntries.count) วัน")
                    .font(.caption).foregroundColor(.gray)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1)).cornerRadius(12)
            }
            
            if let mostFeeling = getMostFrequentComparison() {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(comparisonColor(mostFeeling).opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(comparisonIcon(mostFeeling))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 82, height: 82)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("รู้สึกบ่อยที่สุด:")
                            .font(.caption).foregroundColor(.gray)
                        Text(comparisonTitle(mostFeeling))
                            .font(.title3).fontWeight(.bold).foregroundColor(.black)
                    }
                    Spacer()
                }
            }
            
            Divider()
            
            VStack(spacing: 12) {
                FeelingPercentageRow(title: "ดีขึ้น", color: .green, percentage: getComparisonPercentage(.better))
                FeelingPercentageRow(title: "เหมือนเดิม", color: .yellow, percentage: getComparisonPercentage(.same))
                FeelingPercentageRow(title: "แย่ลง", color: .red, percentage: getComparisonPercentage(.worse))
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Logic Functions
    
    private func changeMonth(_ value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))
        else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = (firstWeekday - 2 + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    private func getEntry(for date: Date) -> DiaryEntry? {
        return diaryViewModel.monthEntries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "th_TH")
        return formatter.string(from: date)
    }
    
    private func getComparisonPercentage(_ comparison: FeelingComparison) -> Int {
        guard !diaryViewModel.monthEntries.isEmpty else { return 0 }
        
        let count = diaryViewModel.monthEntries.filter { entry in
            if let comp = entry.feelingComparison {
                return comp == comparison
            }
            let level = entry.feelingLevel
            switch comparison {
            case .better: return level >= 4
            case .same: return level == 3
            case .worse: return level <= 2
            }
        }.count
        
        return Int((Double(count) / Double(diaryViewModel.monthEntries.count)) * 100)
    }
    
    private func getMostFrequentComparison() -> FeelingComparison? {
        guard !diaryViewModel.monthEntries.isEmpty else { return nil }
        
        var counts: [FeelingComparison: Int] = [:]
        
        for entry in diaryViewModel.monthEntries {
            let comparison: FeelingComparison
            if let comp = entry.feelingComparison {
                comparison = comp
            } else {
                let level = entry.feelingLevel
                if level >= 4 { comparison = .better }
                else if level == 3 { comparison = .same }
                else { comparison = .worse }
            }
            counts[comparison, default: 0] += 1
        }
        
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
    private func comparisonTitle(_ comparison: FeelingComparison) -> String {
        switch comparison {
        case .better: return "ดีขึ้น"
        case .same: return "เหมือนเดิม"
        case .worse: return "แย่ลง"
        }
    }
    
    private func comparisonColor(_ comparison: FeelingComparison) -> Color {
        switch comparison {
        case .better: return .green
        case .same: return .yellow
        case .worse: return .red
        }
    }
    
    private func comparisonIcon(_ comparison: FeelingComparison) -> String {
        switch comparison {
        case .better: return "Smile"
        case .same: return "Normal"
        case .worse: return "Sad"
        }
    }
}

// MARK: - Subviews
struct DiaryDetailSheet: View {
    let date: Date
    let entry: DiaryEntry?
    @Environment(\.dismiss) var dismiss
    
    // แปลงวันที่ให้แสดงผลสวยงาม เช่น "23 ตุลาคม 2568"
    var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let entry = entry {
                // ดึงค่าการเปรียบเทียบอารมณ์
                let comparison = entry.feelingComparison ?? fallbackComparison(entry.feelingLevel)
                
                // 1. รูปอิโมจิ
                if let _ = UIImage(named: comparisonImageName(comparison)) {
                    Image(comparisonImageName(comparison))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding(.top, 10)
                }
                
                // 2. ข้อความแสดงความรู้สึก (เช่น รู้สึกดีขึ้น, แย่ลง)
                Text(comparisonTitle(comparison))
                    .font(.title)
                    .fontWeight(.bold)
                
                // 3. วันที่บันทึก
                Text("บันทึกเมื่อ: \(dateString)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                
                // 4. กล่องบันทึกเพิ่มเติม (Note)
                VStack(alignment: .leading, spacing: 10) {
                    Text("บันทึกเพิ่มเติม:")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    // เช็คว่ามีข้อความไหม ถ้าเป็น nil หรือปล่อยว่างเปล่า ให้แสดง "ไม่มีบันทึกเพิ่มเติม"
                    let noteText = (entry.note != nil && !entry.note!.isEmpty) ? entry.note! : "ไม่มีบันทึกเพิ่มเติม"
                    
                    Text(noteText)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
            } else {
                // ❌ กรณีไม่มีข้อมูลของวันนั้น (กันเหนียวไว้)
                Spacer()
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.gray.opacity(0.5))
                Text("ไม่มีบันทึกอาการในวันนี้")
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(24)
        // ✅ เด้งครึ่งจอและมีขีดให้เลื่อนปิดได้ (ใส่ตรงนี้ได้เลย)
        .presentationDetents([.medium, .fraction(0.55)])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Helper Functions
    private func fallbackComparison(_ level: Int) -> FeelingComparison {
        if level >= 4 { return .better }
        else if level == 3 { return .same }
        else { return .worse }
    }
    
    private func comparisonImageName(_ comparison: FeelingComparison) -> String {
        switch comparison {
        case .better: return "Smile"
        case .same: return "Normal"
        case .worse: return "Sad"
        }
    }
    
    private func comparisonTitle(_ comparison: FeelingComparison) -> String {
        switch comparison {
        case .better: return "รู้สึกดีขึ้น"
        case .same: return "รู้สึกเหมือนเดิม"
        case .worse: return "รู้สึกแย่ลง"
        }
    }
}

struct FeelingPercentageRow: View {
    let title: String
    let color: Color
    let percentage: Int
    
    var body: some View {
        HStack {
            Circle().fill(color).frame(width: 12, height: 12)
            Text(title).font(.subheadline).foregroundColor(.black)
            Spacer()
            Text("\(percentage)%").font(.subheadline).bold().foregroundColor(.black)
            
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2))
                    Capsule().fill(color).frame(width: g.size.width * CGFloat(percentage) / 100)
                }
            }
            .frame(width: 80, height: 8)
        }
    }
}

struct DayCell: View {
    let date: Date
    let entry: DiaryEntry?
    
    var body: some View {
        VStack(spacing: 4) {
            if let entry = entry {
                let comparison = entry.feelingComparison ?? fallbackComparison(entry.feelingLevel)
                let color = comparisonColor(comparison)
                let imageName = comparisonImageName(comparison)
                
                ZStack {
                    Circle().fill(color.opacity(0.2))
                    if let _ = UIImage(named: imageName) {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: comparisonSystemIcon(comparison))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .clipShape(Circle())
                    }
                }
                .frame(width: 35, height: 35)
            } else {
                Circle().fill(Color.gray.opacity(0.1)).frame(width: 35, height: 35)
            }
            
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption2)
                .foregroundColor(entry != nil ? .black : .gray)
        }
        .frame(height: 60)
    }
    
    private func fallbackComparison(_ level: Int) -> FeelingComparison {
        if level >= 4 { return .better }
        else if level == 3 { return .same }
        else { return .worse }
    }
    
    private func comparisonImageName(_ comparison: FeelingComparison) -> String {
        switch comparison {
        case .better: return "Smile"
        case .same: return "Normal"
        case .worse: return "Sad"
        }
    }
    
    private func comparisonColor(_ comparison: FeelingComparison) -> Color {
        switch comparison {
        case .better: return .green
        case .same: return .yellow
        case .worse: return .red
        }
    }
    
    private func comparisonSystemIcon(_ comparison: FeelingComparison) -> String {
        switch comparison {
        case .better: return "face.smiling"
        case .same: return "face.straight.mouth"
        case .worse: return "face.frowning"
        }
    }
}

#Preview {
    DiaryHistoryView()
        .environmentObject(DiaryViewModel()) // ✅ เพิ่มบรรทัดนี้เพื่อให้ Preview ไม่พัง
}
