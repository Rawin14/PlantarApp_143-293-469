////
////  DiaryHistoryView.swift
////  Plantar
////
////  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
////
//
//import SwiftUI
//
//struct DiaryHistoryView: View {
//    // --- State Variables ---
//    @State private var selectedMonth = Date()
//    @State private var entries: [DiaryEntry] = []
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//
//    // Service
//    private let diaryService = DiaryService()
//
//    // --- Custom Colors ---
//    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255)
//    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
//    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255)
//
//    private var calendar: Calendar {
//        var cal = Calendar(identifier: .gregorian)
//        cal.locale = Locale(identifier: "th_TH")
//        cal.firstWeekday = 2 // เริ่มวันจันทร์ (1=Sun, 2=Mon)
//        return cal
//    }
//
//    var body: some View {
//        ZStack {
//            backgroundColor.ignoresSafeArea()
//
//            if isLoading {
//                ProgressView("กำลังโหลด...")
//                    .foregroundColor(.white)
//            } else {
//                contentView
//            }
//        }
//        .task { await loadEntries() }
//        .onChange(of: selectedMonth) {
//            Task { await loadEntries() }
//        }
//    }
//
//    var contentView: some View {
//        ScrollView(showsIndicators: false) {
//            VStack(spacing: 20) {
//
//                // MARK: - Month Selector
//                HStack {
//                    Button(action: { changeMonth(-1) }) {
//                        Image(systemName: "chevron.left").font(.title3).foregroundColor(.white)
//                    }
//                    Spacer()
//                    // แสดงเดือนและปี
//                    Text(monthYearString(from: selectedMonth))
//                        .font(.title3).fontWeight(.semibold).foregroundColor(.white)
//                    Spacer()
//                    Button(action: { changeMonth(1) }) {
//                        Image(systemName: "chevron.right").font(.title3).foregroundColor(.white)
//                    }
//                }
//                .padding(.horizontal, 40)
//                .padding(.vertical, 12)
//                .background(Color.white.opacity(0.1))
//                .cornerRadius(12)
//                .padding(.horizontal, 20)
//                .padding(.top, 10)
//
//                // MARK: - Calendar Grid
//                VStack(alignment: .leading, spacing: 12) {
//                    // หัวตาราง (จันทร์ - อาทิตย์)
//                    HStack {
//                        ForEach(["จ.", "อ.", "พ.", "พฤ.", "ศ.", "ส.", "อา."], id: \.self) { day in
//                            Text(day)
//                                .font(.caption2)
//                                .fontWeight(.bold)
//                                .foregroundColor(.gray)
//                                .frame(maxWidth: .infinity)
//                        }
//                    }
//
//                    // ตารางวันที่
//                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
//                        let days = getDaysInMonth()
//
//                        ForEach(days.indices, id: \.self) { index in
//                            if let date = days[index] {
//                                DayCell(date: date, entry: getEntry(for: date))
//                            } else {
//                                Color.clear.frame(height: 60)
//                            }
//                        }
//                    }
//                }
//                .padding(20)
//                .background(cardBackground)
//                .cornerRadius(15)
//                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
//                .padding(.horizontal, 20)
//
//                // ส่วนสรุป (Statistics)
//                if !entries.isEmpty {
//                    statisticsSection
//                }
//            }
//            .padding(.bottom, 40)
//        }
//    }
//
//    // MARK: - Statistics Section
//    var statisticsSection: some View {
//        VStack(spacing: 16) {
//            HStack {
//                Text("สรุปเดือนนี้")
//                    .font(.title3).fontWeight(.bold).foregroundColor(.black)
//                Spacer()
//                Text("\(entries.count) วัน")
//                    .font(.caption).foregroundColor(.gray)
//                    .padding(.horizontal, 12).padding(.vertical, 6)
//                    .background(Color.gray.opacity(0.1)).cornerRadius(12)
//            }
//
//            if let mostFeeling = getMostFrequentFeeling() {
//                HStack(spacing: 12) {
//                    if let img = UIImage(named: getFeelingImageName(mostFeeling)) {
//                        Image(uiImage: img)
//                            .resizable().scaledToFit().frame(width: 60, height: 60)
//                            .clipShape(Circle())
//                    } else {
//                        Image(systemName: "face.smiling")
//                            .resizable().scaledToFit().frame(width: 60, height: 60)
//                            .foregroundColor(getFeelingColor(mostFeeling))
//                            .clipShape(Circle())
//                    }
//
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("รู้สึกบ่อยที่สุด:")
//                            .font(.caption).foregroundColor(.gray)
//                        Text(getFeelingTitle(mostFeeling))
//                            .font(.title3).fontWeight(.bold).foregroundColor(.black)
//                    }
//                    Spacer()
//                }
//            }
//
//            Divider()
//
//            VStack(spacing: 12) {
//                FeelingPercentageRow(title: "ดีขึ้น", color: .green, percentage: getFeelingPercentage(1))
//                FeelingPercentageRow(title: "เหมือนเดิม", color: .yellow, percentage: getFeelingPercentage(2))
//                FeelingPercentageRow(title: "ปวดมากขึ้น", color: .red, percentage: getFeelingPercentage(3))
//            }
//        }
//        .padding(20)
//        .background(Color.white)
//        .cornerRadius(16)
//        .padding(.horizontal, 20)
//    }
//
//    // MARK: - Logic Functions
//
//    private func loadEntries() async {
//        isLoading = true
//        do {
//            entries = try await diaryService.fetchEntriesForMonth(date: selectedMonth)
//        } catch {
//            print("Error loading entries: \(error)")
//        }
//        isLoading = false
//    }
//
//    private func changeMonth(_ value: Int) {
//        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
//            selectedMonth = newDate
//        }
//    }
//
//    private func getDaysInMonth() -> [Date?] {
//            guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
//                  let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))
//            else { return [] }
//
//            let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
//
//            let offset = (firstWeekday - 2 + 7) % 7
//
//            var days: [Date?] = Array(repeating: nil, count: offset)
//
//            for day in 1...range.count {
//                if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
//                    days.append(date)
//                }
//            }
//            return days
//        }
//
//    private func getEntry(for date: Date) -> DiaryEntry? {
//        return entries.first { entry in
//            calendar.isDate(entry.date, inSameDayAs: date)
//        }
//    }
//
//    private func monthYearString(from date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM yyyy"
//        formatter.calendar = calendar
//        formatter.locale = Locale(identifier: "th_TH")
//        return formatter.string(from: date)
//    }
//
//    // Helpers
//    private func getFeelingPercentage(_ level: Int) -> Int {
//        guard !entries.isEmpty else { return 0 }
//        let count = entries.filter { $0.feelingLevel == level }.count
//        return Int((Double(count) / Double(entries.count)) * 100)
//    }
//
//    private func getMostFrequentFeeling() -> Int? {
//        guard !entries.isEmpty else { return nil }
//        let counts = Dictionary(grouping: entries, by: { $0.feelingLevel }).mapValues { $0.count }
//        return counts.max(by: { $0.value < $1.value })?.key
//    }
//
//    private func getFeelingTitle(_ level: Int) -> String {
//        switch level { case 1: return "ดีขึ้น"; case 2: return "เหมือนเดิม"; case 3: return "ปวดมากขึ้น"; default: return "" }
//    }
//
//    private func getFeelingImageName(_ level: Int) -> String {
//        switch level { case 1: return "Smile"; case 2: return "Normal"; case 3: return "Sad"; default: return "" }
//    }
//
//    private func getFeelingColor(_ level: Int) -> Color {
//        switch level { case 1: return .green; case 2: return .yellow; case 3: return .red; default: return .gray }
//    }
//
//    private func getFeelingIcon(_ level: Int) -> String {
//        switch level { case 1: return "Smile"; case 2: return "Normal"; default: return "exclamationmark.circle" }
//    }
//}
//
//// MARK: - Subviews
//struct FeelingPercentageRow: View {
//    let title: String
//    let color: Color
//    let percentage: Int
//
//    var body: some View {
//        HStack {
//            Circle().fill(color).frame(width: 12, height: 12)
//            Text(title).font(.subheadline).foregroundColor(.black)
//            Spacer()
//            Text("\(percentage)%").font(.subheadline).bold().foregroundColor(.black)
//
//            GeometryReader { g in
//                ZStack(alignment: .leading) {
//                    Capsule().fill(Color.gray.opacity(0.2))
//                    Capsule().fill(color).frame(width: g.size.width * CGFloat(percentage) / 100)
//                }
//            }
//            .frame(width: 80, height: 8)
//        }
//    }
//}
//
//struct DayCell: View {
//    let date: Date
//    let entry: DiaryEntry?
//
//    var body: some View {
//        VStack(spacing: 4) {
//            if let entry = entry {
//                ZStack {
//                    Circle().fill(getFeelingColor(entry.feelingLevel).opacity(0.2))
//                    if UIImage(named: getFeelingImageName(entry.feelingLevel)) != nil {
//                        Image(getFeelingImageName(entry.feelingLevel))
//                            .resizable().scaledToFit().padding(4)
//                    } else {
//                        Image(systemName: getFeelingIcon(entry.feelingLevel))
//                            .foregroundColor(getFeelingColor(entry.feelingLevel))
//                    }
//                }
//                .frame(width: 35, height: 35)
//            } else {
//                Circle().fill(Color.gray.opacity(0.1)).frame(width: 35, height: 35)
//            }
//
//            Text("\(Calendar.current.component(.day, from: date))")
//                .font(.caption2)
//                .foregroundColor(entry != nil ? .black : .gray)
//        }
//        .frame(height: 60)
//    }
//
//    func getFeelingImageName(_ level: Int) -> String {
//        switch level { case 1: return "feeling_better"; case 2: return "feeling_same"; case 3: return "feeling_worse"; default: return "" }
//    }
//    func getFeelingColor(_ level: Int) -> Color {
//        switch level { case 1: return .green; case 2: return .yellow; case 3: return .red; default: return .gray }
//    }
//    func getFeelingIcon(_ level: Int) -> String {
//        switch level { case 1: return "face.smiling"; case 2: return "face.dashed"; default: return "exclamationmark.circle" }
//    }
//}
//
//#Preview {
//    DiaryHistoryView()
//}
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
            
            if isLoading {
                ProgressView("กำลังโหลด...")
                    .foregroundColor(.white)
            } else {
                contentView
            }
        }
        .task { await loadEntries() }
        .onChange(of: selectedMonth) {
            Task { await loadEntries() }
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
                    
                    // ตารางวันที่
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        let days = getDaysInMonth()
                        
                        ForEach(days.indices, id: \.self) { index in
                            if let date = days[index] {
                                DayCell(date: date, entry: getEntry(for: date))
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
                if !entries.isEmpty {
                    statisticsSection
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Statistics Section
    var statisticsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("สรุปเดือนนี้")
                    .font(.title3).fontWeight(.bold).foregroundColor(.black)
                Spacer()
                Text("\(entries.count) วัน")
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
    
    private func loadEntries() async {
        isLoading = true
        do {
            entries = try await diaryService.fetchEntriesForMonth(date: selectedMonth)
        } catch {
            print("Error loading entries: \(error)")
        }
        isLoading = false
    }
    
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
        return entries.first { entry in
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
    
    // ✅ ใช้ feelingComparison แทน feelingLevel
    private func getComparisonPercentage(_ comparison: FeelingComparison) -> Int {
        guard !entries.isEmpty else { return 0 }
        
        let count = entries.filter { entry in
            if let comp = entry.feelingComparison {
                return comp == comparison
            }
            // Fallback: แปลงจาก feelingLevel
            let level = entry.feelingLevel
            switch comparison {
            case .better: return level >= 4
            case .same: return level == 3
            case .worse: return level <= 2
            }
        }.count
        
        return Int((Double(count) / Double(entries.count)) * 100)
    }
    
    private func getMostFrequentComparison() -> FeelingComparison? {
        guard !entries.isEmpty else { return nil }
        
        var counts: [FeelingComparison: Int] = [:]
        
        for entry in entries {
            let comparison: FeelingComparison
            if let comp = entry.feelingComparison {
                comparison = comp
            } else {
                // Fallback
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
    
    // ชื่อไฟล์รูปใน Assets (ของคุณ)
    private func comparisonImageName(_ comparison: FeelingComparison) -> String {
        switch comparison {
        case .better: return "Smile"
        case .same: return "Normal"
        case .worse: return "Sad"
        }
    }
    
    // สี
    private func comparisonColor(_ comparison: FeelingComparison) -> Color {
        switch comparison {
        case .better: return .green
        case .same: return .yellow
        case .worse: return .red
        }
    }
    
    // ✅ เพิ่มฟังก์ชันนี้สำหรับ SF Symbols (Fallback)
    private func comparisonSystemIcon(_ comparison: FeelingComparison) -> String {
        switch comparison {
        case .better: return "face.smiling"
        case .same: return "face.straight.mouth" // หรือ "meh"
        case .worse: return "face.frowning" // หรือ "cloud.rain"
        }
    }
}
#Preview {
    DiaryHistoryView()
}

