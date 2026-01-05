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
    @State private var entries: [DiaryEntry] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Service
    private let diaryService = DiaryService()
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียว
    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255) // ครีม
    
    // Formatter ที่ตรงกันกับ Database
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        return cal
    }
    
    var body: some View {
        ZStack {
            // พื้นหลังของทั้งหน้า (สีน้ำตาลเข้มตาม Theme หรือจะใช้ cardBackground ก็ได้)
            backgroundColor.ignoresSafeArea()
            
            if isLoading {
                ProgressView("กำลังโหลด...")
                    .foregroundColor(.white)
            } else {
                contentView
            }
        }
        .task { await loadEntries() }
        .onChange(of: selectedMonth) { _ in Task { await loadEntries() } }
        .onAppear { Task { await loadEntries() } }
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
                    Text(monthYearFormatter.string(from: selectedMonth))
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
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                }
                
                // Empty State
                if entries.isEmpty && !isLoading {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50)).foregroundColor(.white.opacity(0.5))
                        Text("ยังไม่มีข้อมูลในเดือนนี้")
                            .font(.headline).foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.vertical, 50)
                } else if !entries.isEmpty {
                    
                    // MARK: - Statistics Card (สรุปเดือนนี้)
                    // ✅ เพิ่มพื้นหลังสีขาวตรงนี้
                    VStack(spacing: 16) {
                        // Header: สรุปเดือนนี้ + จำนวนวัน
                        HStack {
                            Text("สรุปเดือนนี้")
                                .font(.title3).fontWeight(.bold).foregroundColor(.black)
                            Spacer()
                            Text("\(filteredEntries().count) วัน")
                                .font(.caption).foregroundColor(.gray)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.gray.opacity(0.1)).cornerRadius(12)
                        }
                        
                        // Most Frequent Feeling (ความรู้สึกที่พบบ่อยสุด)
                        if let mostFeeling = getMostFrequentFeeling() {
                            HStack(spacing: 12) {
                                // Image/Icon
                                if UIImage(named: getFeelingImageName(mostFeeling)) != nil {
                                    Image(getFeelingImageName(mostFeeling))
                                        .resizable().scaledToFit().frame(width: 80, height: 80)
                                } else {
                                    Circle().fill(getFeelingColor(mostFeeling))
                                        .frame(width: 80, height: 80)
                                        .overlay(Image(systemName: getFeelingIcon(mostFeeling)).font(.largeTitle).foregroundColor(.white))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ความรู้สึกที่พบบ่อยสุด:")
                                        .font(.caption).foregroundColor(.gray)
                                    Text(getFeelingTitle(mostFeeling))
                                        .font(.title2).fontWeight(.bold).foregroundColor(.black)
                                }
                                Spacer()
                            }
                        }
                        
                        Divider()
                        
                        // Percentages Rows
                        VStack(spacing: 12) {
                            FeelingPercentageRow(title: "ดีขึ้น", color: .green, percentage: getFeelingPercentage(1))
                            FeelingPercentageRow(title: "เหมือนเดิม", color: .yellow, percentage: getFeelingPercentage(2))
                            FeelingPercentageRow(title: "ปวดมากขึ้น", color: .red, percentage: getFeelingPercentage(3))
                        }
                    }
                    .padding(20)
                    .background(Color.white) // ✅ พื้นหลังสีขาว
                    .cornerRadius(16) // ✅ มุมโค้ง
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4) // ✅ เงาเพื่อให้ดูมิติ
                    .padding(.horizontal, 20) // ✅ เว้นขอบซ้ายขวา
                    
                    
                    // MARK: - Calendar Grid
                    VStack(alignment: .leading, spacing: 12) {
                        // Days Header
                        HStack {
                            ForEach(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], id: \.self) { day in
                                Text(day).font(.caption2).foregroundColor(.gray).frame(maxWidth: .infinity)
                            }
                        }
                        
                        // Days Grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                            ForEach(getDaysInMonth(), id: \.self) { date in
                                if let date = date {
                                    DayCell(date: date, entry: getEntry(for: date))
                                } else {
                                    Color.clear.frame(height: 70)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(cardBackground) // ส่วนปฏิทินใช้สีครีม (หรือจะเปลี่ยนเป็น white ก็ได้ถ้าชอบ)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - Functions
    
    private func loadEntries() async {
        isLoading = true
        errorMessage = nil
        do {
            entries = try await diaryService.fetchEntriesForMonth(date: selectedMonth)
        } catch {
            errorMessage = "โหลดข้อมูลไม่สำเร็จ"
            print("Error: \(error)")
        }
        isLoading = false
    }
    
    private func changeMonth(_ value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func filteredEntries() -> [DiaryEntry] {
        return entries
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))
        else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        // Offset ให้เริ่มวันจันทร์ (Mon=0, Tue=1...)
        // Weekday: Sun=1, Mon=2, ...
        let offset = (firstWeekday + 5) % 7
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }
    
    private func getEntry(for date: Date) -> DiaryEntry? {
        return entries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "th_TH")
        return formatter
    }
    
    // Feeling Helpers
    private func getFeelingPercentage(_ level: Int) -> Int {
        guard !entries.isEmpty else { return 0 }
        let count = entries.filter { $0.feelingLevel == level }.count
        return Int((Double(count) / Double(entries.count)) * 100)
    }
    
    private func getMostFrequentFeeling() -> Int? {
        guard !entries.isEmpty else { return nil }
        let counts = Dictionary(grouping: entries, by: { $0.feelingLevel }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
    private func getFeelingTitle(_ level: Int) -> String {
        switch level { case 1: return "ดีขึ้น"; case 2: return "เหมือนเดิม"; case 3: return "ปวดมากขึ้น"; default: return "" }
    }
    
    private func getFeelingImageName(_ level: Int) -> String {
        switch level { case 1: return "feeling_better"; case 2: return "feeling_same"; case 3: return "feeling_worse"; default: return "" }
    }
    
    private func getFeelingColor(_ level: Int) -> Color {
        switch level { case 1: return .green; case 2: return .yellow; case 3: return .red; default: return .gray }
    }
    
    private func getFeelingIcon(_ level: Int) -> String {
        switch level { case 1: return "face.smiling"; case 2: return "face.dashed"; default: return "exclamationmark.circle" }
    }
}

// MARK: - Subviews
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
                ZStack {
                    Circle().fill(getFeelingColor(entry.feelingLevel).opacity(0.2))
                    if UIImage(named: getFeelingImageName(entry.feelingLevel)) != nil {
                        Image(getFeelingImageName(entry.feelingLevel))
                            .resizable().scaledToFit().padding(4)
                    } else {
                        Image(systemName: getFeelingIcon(entry.feelingLevel))
                            .foregroundColor(getFeelingColor(entry.feelingLevel))
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
    
    func getFeelingImageName(_ level: Int) -> String {
        switch level { case 1: return "feeling_better"; case 2: return "feeling_same"; case 3: return "feeling_worse"; default: return "" }
    }
    func getFeelingColor(_ level: Int) -> Color {
        switch level { case 1: return .green; case 2: return .yellow; case 3: return .red; default: return .gray }
    }
    func getFeelingIcon(_ level: Int) -> String {
        switch level { case 1: return "face.smiling"; case 2: return "face.dashed"; default: return "exclamationmark.circle" }
    }
}

#Preview {
    DiaryHistoryView()
}
