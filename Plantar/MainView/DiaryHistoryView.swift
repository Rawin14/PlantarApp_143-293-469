//
// DiaryHistoryView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

//import SwiftUI
//
//// MARK: - Diary Entry Model
//struct DiaryEntry: Identifiable {
//    let id = UUID()
//    let date: Date
//    let feelingLevel: Int // 1 = ดีขึ้น, 2 = เหมือนเดิม, 3 = ปวดมากขึ้น
//    let note: String?
//}
//
//struct DiaryHistoryView: View {
//    // --- State Variables ---
//    @State private var selectedMonth = Date()
//    @State private var showMonthPicker = false
//
//    // --- Custom Colors ---
//    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255)
//    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
//    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255)
//
//    // --- Sample Data ---
//    @State private var entries: [DiaryEntry] = [
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 0), feelingLevel: 2, note: nil),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 1), feelingLevel: 3, note: "ปวดหลังเดิน"),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 2), feelingLevel: 1, note: nil),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 3), feelingLevel: 3, note: nil),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 4), feelingLevel: 2, note: nil),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 5), feelingLevel: 1, note: nil),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 6), feelingLevel: 2, note: nil),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 7), feelingLevel: 3, note: nil),
//    ]
//
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            VStack(spacing: 20) {
//                // MARK: - Month Selector
//                HStack {
//                    Button(action: { changeMonth(-1) }) {
//                        Image(systemName: "chevron.left")
//                            .font(.title3)
//                            .foregroundColor(.white)
//                    }
//
//                    Spacer()
//
//                    Text(selectedMonth, formatter: monthYearFormatter)
//                        .font(.title3)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//
//                    Spacer()
//
//                    Button(action: { changeMonth(1) }) {
//                        Image(systemName: "chevron.right")
//                            .font(.title3)
//                            .foregroundColor(.white)
//                    }
//                }
//                .padding(.horizontal, 40)
//                .padding(.vertical, 12)
//                .background(Color.white.opacity(0.1))
//                .cornerRadius(12)
//                .padding(.horizontal, 20)
//                .padding(.top, 10)
//
//                // MARK: - Summary Statistics Card
//                VStack(spacing: 16) {
//                    Text("สรุปเดือนนี้")
//                        .font(.title3)
//                        .fontWeight(.bold)
//                        .foregroundColor(.black)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    // Feeling ที่มากที่สุด
//                    HStack(spacing: 12) {
//                        // รูปความรู้สึกที่มากที่สุด
//                        if let mostFeeling = getMostFrequentFeeling() {
//                            if UIImage(named: getFeelingImageName(mostFeeling)) != nil {
//                                Image(getFeelingImageName(mostFeeling))
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 80, height: 80)
//                            } else {
//                                Circle()
//                                    .fill(getFeelingColor(mostFeeling))
//                                    .frame(width: 80, height: 80)
//                                    .overlay(
//                                        Image(systemName: getFeelingIcon(mostFeeling))
//                                            .font(.system(size: 30))
//                                            .foregroundColor(.white)
//                                    )
//                            }
//                        }
//
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("ความรู้สึกที่พบบ่อยสุด:")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//
//                            if let mostFeeling = getMostFrequentFeeling() {
//                                Text(getFeelingTitle(mostFeeling))
//                                    .font(.title2)
//                                    .fontWeight(.bold)
//                                    .foregroundColor(.black)
//                            }
//                        }
//
//                        Spacer()
//                    }
//
//                    Divider()
//
//                    // สรุป % แต่ละแบบ
//                    VStack(spacing: 12) {
//                        FeelingPercentageRow(
//                            title: "ดีขึ้น",
//                            color: .green,
//                            percentage: getFeelingPercentage(1)
//                        )
//
//                        FeelingPercentageRow(
//                            title: "เหมือนเดิม",
//                            color: .yellow,
//                            percentage: getFeelingPercentage(2)
//                        )
//
//                        FeelingPercentageRow(
//                            title: "ปวดมากขึ้น",
//                            color: .red,
//                            percentage: getFeelingPercentage(3)
//                        )
//                    }
//                }
//                .padding(20)
//                .background(cardBackground)
//                .cornerRadius(15)
//                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
//                .padding(.horizontal, 20)
//
//                // MARK: - Calendar Grid
//                VStack(alignment: .leading, spacing: 12) {
//                    // Weekday Headers
//                    HStack {
//                        ForEach(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], id: \.self) { day in
//                            Text(day)
//                                .font(.caption2)
//                                .foregroundColor(.gray)
//                                .frame(maxWidth: .infinity)
//                        }
//                    }
//
//                    // Calendar Days
//                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 12) {
//                        ForEach(getDaysInMonth(), id: \.self) { date in
//                            if let date = date {
//                                DayCell(
//                                    date: date,
//                                    entry: getEntry(for: date)
//                                )
//                            } else {
//                                Color.clear
//                                    .frame(height: 70)
//                            }
//                        }
//                    }
//                }
//                .padding(20)
//                .background(cardBackground)
//                .cornerRadius(15)
//                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
//                .padding(.horizontal, 20)
//                .padding(.bottom, 40)
//            }
//        }
//    }
//
//    // MARK: - Helper Functions
//    private func changeMonth(_ value: Int) {
//        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
//            selectedMonth = newDate
//        }
//    }
//
//    private func getDaysInMonth() -> [Date?] {
//        let calendar = Calendar.current
//        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
//        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
//        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
//
//        var days: [Date?] = []
//        let offset = (firstWeekday == 1 ? 6 : firstWeekday - 2)
//
//        for _ in 0..<offset {
//            days.append(nil)
//        }
//
//        for day in range {
//            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
//                days.append(date)
//            }
//        }
//
//        return days
//    }
//
//    private func getEntry(for date: Date) -> DiaryEntry? {
//        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
//    }
//
//    private func getFeelingPercentage(_ level: Int) -> Int {
//        guard !entries.isEmpty else { return 0 }
//        let count = entries.filter { $0.feelingLevel == level }.count
//        return Int((Double(count) / Double(entries.count)) * 100)
//    }
//
//    private func getMostFrequentFeeling() -> Int? {
//        guard !entries.isEmpty else { return nil }
//
//        let counts = [
//            1: entries.filter { $0.feelingLevel == 1 }.count,
//            2: entries.filter { $0.feelingLevel == 2 }.count,
//            3: entries.filter { $0.feelingLevel == 3 }.count
//        ]
//
//        return counts.max(by: { $0.value < $1.value })?.key
//    }
//
//    private func getFeelingTitle(_ level: Int) -> String {
//        switch level {
//        case 1: return "ดีขึ้น"
//        case 2: return "เหมือนเดิม"
//        case 3: return "ปวดมากขึ้น"
//        default: return ""
//        }
//    }
//
//    private func getFeelingImageName(_ level: Int) -> String {
//        switch level {
//        case 1: return "feeling_better"
//        case 2: return "feeling_same"
//        case 3: return "feeling_worse"
//        default: return ""
//        }
//    }
//
//    private func getFeelingColor(_ level: Int) -> Color {
//        switch level {
//        case 1: return Color.green.opacity(0.6)
//        case 2: return Color.yellow.opacity(0.6)
//        case 3: return Color.red.opacity(0.6)
//        default: return Color.gray
//        }
//    }
//
//    private func getFeelingIcon(_ level: Int) -> String {
//        switch level {
//        case 1: return "face.smiling"
//        case 2: return "face.dashed"
//        case 3: return "face.dashed.fill"
//        default: return "face.smiling"
//        }
//    }
//
//    private var monthYearFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM yyyy"
//        return formatter
//    }
//}
//
//// MARK: - Feeling Percentage Row
//struct FeelingPercentageRow: View {
//    let title: String
//    let color: Color
//    let percentage: Int
//
//    var body: some View {
//        HStack {
//            Circle()
//                .fill(color.opacity(0.6))
//                .frame(width: 16, height: 16)
//
//            Text(title)
//                .font(.body)
//                .foregroundColor(.black)
//
//            Spacer()
//
//            Text("\(percentage)%")
//                .font(.body)
//                .fontWeight(.semibold)
//                .foregroundColor(.black)
//
//            // Progress Bar
//            GeometryReader { geometry in
//                ZStack(alignment: .leading) {
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.2))
//                        .frame(height: 6)
//                        .cornerRadius(3)
//
//                    Rectangle()
//                        .fill(color)
//                        .frame(width: geometry.size.width * CGFloat(percentage) / 100, height: 6)
//                        .cornerRadius(3)
//                }
//            }
//            .frame(width: 60, height: 6)
//        }
//    }
//}
//
//// MARK: - Day Cell
//struct DayCell: View {
//    let date: Date
//    let entry: DiaryEntry?
//
//    var body: some View {
//        VStack(spacing: 4) {
//            // Emoji/Icon
//            if let entry = entry {
//                if UIImage(named: getFeelingImageName(entry.feelingLevel)) != nil {
//                    Image(getFeelingImageName(entry.feelingLevel))
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 35, height: 35)
//                } else {
//                    Circle()
//                        .fill(getFeelingColor(entry.feelingLevel))
//                        .frame(width: 35, height: 35)
//                        .overlay(
//                            Image(systemName: getFeelingIcon(entry.feelingLevel))
//                                .font(.caption)
//                                .foregroundColor(.white)
//                        )
//                }
//            } else {
//                Circle()
//                    .fill(Color.gray.opacity(0.2))
//                    .frame(width: 35, height: 35)
//            }
//
//            // วันที่
//            Text("\(Calendar.current.component(.day, from: date))")
//                .font(.caption2)
//                .fontWeight(.semibold)
//                .foregroundColor(entry != nil ? .black : .gray.opacity(0.5))
//        }
//        .frame(height: 70)
//    }
//
//    // Helper Functions (ต้องอยู่ใน DayCell)
//    private func getFeelingImageName(_ level: Int) -> String {
//        switch level {
//        case 1: return "feeling_better"
//        case 2: return "feeling_same"
//        case 3: return "feeling_worse"
//        default: return ""
//        }
//    }
//
//    private func getFeelingColor(_ level: Int) -> Color {
//        switch level {
//        case 1: return Color.green.opacity(0.6)
//        case 2: return Color.yellow.opacity(0.6)
//        case 3: return Color.red.opacity(0.6)
//        default: return Color.gray
//        }
//    }
//
//    private func getFeelingIcon(_ level: Int) -> String {
//        switch level {
//        case 1: return "face.smiling"
//        case 2: return "face.dashed"
//        case 3: return "face.dashed.fill"
//        default: return "face.smiling"
//        }
//    }
//}
//
//#Preview {
//    DiaryHistoryView()
//        .background(Color(red: 94/255, green: 84/255, blue: 68/255))
//}


//import SwiftUI
//
//// MARK: - Diary Entry Model
//struct DiaryEntry: Identifiable {
//    let id = UUID()
//    let date: Date
//    let feelingLevel: Int // 1 = ดีขึ้น, 2 = เหมือนเดิม, 3 = ปวดมากขึ้น
//    let note: String?
//}
//
//struct DiaryHistoryView: View {
//    // --- State Variables ---
//    @State private var selectedMonth = Date()
//    @State private var showMonthPicker = false
//
//    // --- Custom Colors ---
//    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255)
//    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
//    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255)
//
//    // --- Sample Data ---
//    @State private var entries: [DiaryEntry] = [
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 0), feelingLevel: 2, note: nil),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 1), feelingLevel: 3, note: "ปวดหลังเดิน"),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 2), feelingLevel: 1, note: nil),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 3), feelingLevel: 3, note: nil),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 4), feelingLevel: 2, note: nil),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 5), feelingLevel: 1, note: nil),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 6), feelingLevel: 2, note: nil),
//        DiaryEntry(date: Date().addingTimeInterval(-86400 * 7), feelingLevel: 3, note: nil),
//    ]
//
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            VStack(spacing: 20) {
//                // MARK: - Month Selector
//                HStack {
//                    Button(action: { changeMonth(-1) }) {
//                        Image(systemName: "chevron.left")
//                            .font(.title3)
//                            .foregroundColor(.white)
//                    }
//
//                    Spacer()
//
//                    Text(selectedMonth, formatter: monthYearFormatter)
//                        .font(.title3)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//
//                    Spacer()
//
//                    Button(action: { changeMonth(1) }) {
//                        Image(systemName: "chevron.right")
//                            .font(.title3)
//                            .foregroundColor(.white)
//                    }
//                }
//                .padding(.horizontal, 40)
//                .padding(.vertical, 12)
//                .background(Color.white.opacity(0.1))
//                .cornerRadius(12)
//                .padding(.horizontal, 20)
//                .padding(.top, 10)
//
//                // MARK: - Summary Statistics Card
//                ZStack(alignment: .topTrailing) {
//                    VStack(spacing: 16) {
//                        Text("สรุปเดือนนี้")
//                            .font(.title3)
//                            .fontWeight(.bold)
//                            .foregroundColor(.black)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//
//                        // Feeling ที่มากที่สุด
//                        HStack(spacing: 12) {
//                            // รูปความรู้สึกที่มากที่สุด
//                            if let mostFeeling = getMostFrequentFeeling() {
//                                if UIImage(named: getFeelingImageName(mostFeeling)) != nil {
//                                    Image(getFeelingImageName(mostFeeling))
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 80, height: 80)
//                                } else {
//                                    Circle()
//                                        .fill(getFeelingColor(mostFeeling))
//                                        .frame(width: 80, height: 80)
//                                        .overlay(
//                                            Image(systemName: getFeelingIcon(mostFeeling))
//                                                .font(.system(size: 30))
//                                                .foregroundColor(.white)
//                                        )
//                                }
//                            }
//
//                            VStack(alignment: .leading, spacing: 8) {
//                                Text("ความรู้สึกที่พบบ่อยสุด:")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//
//                                if let mostFeeling = getMostFrequentFeeling() {
//                                    Text(getFeelingTitle(mostFeeling))
//                                        .font(.title2)
//                                        .fontWeight(.bold)
//                                        .foregroundColor(.black)
//                                }
//                            }
//
//                            Spacer()
//                        }
//
//                        Divider()
//
//                        // สรุป % แต่ละแบบ
//                        VStack(spacing: 12) {
//                            FeelingPercentageRow(
//                                title: "ดีขึ้น",
//                                color: .green,
//                                percentage: getFeelingPercentage(1)
//                            )
//
//                            FeelingPercentageRow(
//                                title: "เหมือนเดิม",
//                                color: .yellow,
//                                percentage: getFeelingPercentage(2)
//                            )
//
//                            FeelingPercentageRow(
//                                title: "ปวดมากขึ้น",
//                                color: .red,
//                                percentage: getFeelingPercentage(3)
//                            )
//                        }
//                    }
//                    .padding(20)
//
//                    // ————— ปุ่มดูกราฟด้านขวาบน —————
//                    // 💡 แก้ไข: ส่งค่า entries และ selectedMonth ไปยัง DiarychartView (ตัว 'c' เล็ก)
//                    NavigationLink(destination:
//                        DiarychartView(
//                            entries: filteredEntries(), // ⬅️ ต้องใช้ฟังก์ชันกรอง
//                            selectedMonth: selectedMonth // ⬅️ ต้องส่งเดือนที่เลือก
//                        )
//                    ) {
//                        Image(systemName: "chart.line.uptrend.xyaxis")
//                            .font(.system(size: 22, weight: .semibold))
//                            .foregroundColor(.black.opacity(0.7))
//                            .padding(10)
//                            .background(Color.white.opacity(0.8))
//                            .clipShape(Circle())
//                            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
//                    }
//                    .padding(.trailing, 16)
//                    .padding(.top, 12)
//                }
//                .background(cardBackground)
//                .cornerRadius(15)
//                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
//                .padding(.horizontal, 20)
//
//                // MARK: - Calendar Grid
//                VStack(alignment: .leading, spacing: 12) {
//                    // Weekday Headers
//                    HStack {
//                        ForEach(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], id: \.self) { day in
//                            Text(day)
//                                .font(.caption2)
//                                .foregroundColor(.gray)
//                                .frame(maxWidth: .infinity)
//                        }
//                    }
//
//                    // Calendar Days
//                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 12) {
//                        ForEach(getDaysInMonth(), id: \.self) { date in
//                            if let date = date {
//                                DayCell(
//                                    date: date,
//                                    entry: getEntry(for: date)
//                                )
//                            } else {
//                                Color.clear
//                                    .frame(height: 70)
//                            }
//                        }
//                    }
//                }
//                .padding(20)
//                .background(cardBackground)
//                .cornerRadius(15)
//                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
//                .padding(.horizontal, 20)
//                .padding(.bottom, 40)
//            }
//        }
//    }
//
//    // MARK: - Helper Functions
//    private func changeMonth(_ value: Int) {
//        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
//            selectedMonth = newDate
//        }
//    }
//
//    // 💡 เพิ่ม: ฟังก์ชันสำหรับกรอง entries ตามเดือนที่เลือก
//    private func filteredEntries() -> [DiaryEntry] {
//        let calendar = Calendar.current
//        return entries.filter { entry in
//            calendar.isDate(entry.date, equalTo: selectedMonth, toGranularity: .month)
//        }
//    }
//
//    private func getDaysInMonth() -> [Date?] {
//        let calendar = Calendar.current
//        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
//        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
//        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
//
//        var days: [Date?] = []
//        let offset = (firstWeekday == 1 ? 6 : firstWeekday - 2)
//
//        for _ in 0..<offset {
//            days.append(nil)
//        }
//
//        for day in range {
//            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
//                days.append(date)
//            }
//        }
//
//        return days
//    }
//
//    private func getEntry(for date: Date) -> DiaryEntry? {
//        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
//    }
//
//    private func getFeelingPercentage(_ level: Int) -> Int {
//        let currentMonthEntries = filteredEntries()
//        guard !currentMonthEntries.isEmpty else { return 0 }
//        let count = currentMonthEntries.filter { $0.feelingLevel == level }.count
//        return Int((Double(count) / Double(currentMonthEntries.count)) * 100)
//    }
//
//    private func getMostFrequentFeeling() -> Int? {
//        let currentMonthEntries = filteredEntries()
//        guard !currentMonthEntries.isEmpty else { return nil }
//
//        let counts = [
//            1: currentMonthEntries.filter { $0.feelingLevel == 1 }.count,
//            2: currentMonthEntries.filter { $0.feelingLevel == 2 }.count,
//            3: currentMonthEntries.filter { $0.feelingLevel == 3 }.count
//        ]
//
//        return counts.max(by: { $0.value < $1.value })?.key
//    }
//
//    private func getFeelingTitle(_ level: Int) -> String {
//        switch level {
//        case 1: return "ดีขึ้น"
//        case 2: return "เหมือนเดิม"
//        case 3: return "ปวดมากขึ้น"
//        default: return ""
//        }
//    }
//
//    private func getFeelingImageName(_ level: Int) -> String {
//        switch level {
//        case 1: return "feeling_better"
//        case 2: return "feeling_same"
//        case 3: return "feeling_worse"
//        default: return ""
//        }
//    }
//
//    private func getFeelingColor(_ level: Int) -> Color {
//        switch level {
//        case 1: return Color.green.opacity(0.6)
//        case 2: return Color.yellow.opacity(0.6)
//        case 3: return Color.red.opacity(0.6)
//        default: return Color.gray
//        }
//    }
//
//    private func getFeelingIcon(_ level: Int) -> String {
//        switch level {
//        case 1: return "face.smiling"
//        case 2: return "face.dashed"
//        case 3: return "face.dashed.fill"
//        default: return "face.smiling"
//        }
//    }
//
//    private var monthYearFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM yyyy"
//        return formatter
//    }
//}
//
//// MARK: - Feeling Percentage Row
//struct FeelingPercentageRow: View {
//    let title: String
//    let color: Color
//    let percentage: Int
//
//    var body: some View {
//        HStack {
//            Circle()
//                .fill(color.opacity(0.6))
//                .frame(width: 16, height: 16)
//
//            Text(title)
//                .font(.body)
//                .foregroundColor(.black)
//
//            Spacer()
//
//            Text("\(percentage)%")
//                .font(.body)
//                .fontWeight(.semibold)
//                .foregroundColor(.black)
//
//            // Progress Bar
//            GeometryReader { geometry in
//                ZStack(alignment: .leading) {
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.2))
//                        .frame(height: 6)
//                        .cornerRadius(3)
//
//                    Rectangle()
//                        .fill(color)
//                        .frame(width: geometry.size.width * CGFloat(percentage) / 100, height: 6)
//                        .cornerRadius(3)
//                }
//            }
//            .frame(width: 60, height: 6)
//        }
//    }
//}
//
//// MARK: - Day Cell
//struct DayCell: View {
//    let date: Date
//    let entry: DiaryEntry?
//
//    var body: some View {
//        VStack(spacing: 4) {
//            // Emoji/Icon
//            if let entry = entry {
//                if UIImage(named: getFeelingImageName(entry.feelingLevel)) != nil {
//                    Image(getFeelingImageName(entry.feelingLevel))
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 35, height: 35)
//                } else {
//                    Circle()
//                        .fill(getFeelingColor(entry.feelingLevel))
//                        .frame(width: 35, height: 35)
//                        .overlay(
//                            Image(systemName: getFeelingIcon(entry.feelingLevel))
//                                .font(.caption)
//                                .foregroundColor(.white)
//                        )
//                }
//            } else {
//                Circle()
//                    .fill(Color.gray.opacity(0.2))
//                    .frame(width: 35, height: 35)
//            }
//
//            // วันที่
//            Text("\(Calendar.current.component(.day, from: date))")
//                .font(.caption2)
//                .fontWeight(.semibold)
//                .foregroundColor(entry != nil ? .black : .gray.opacity(0.5))
//        }
//        .frame(height: 70)
//    }
//
//    // Helper Functions (ต้องอยู่ใน DayCell)
//    private func getFeelingImageName(_ level: Int) -> String {
//        switch level {
//        case 1: return "feeling_better"
//        case 2: return "feeling_same"
//        case 3: return "feeling_worse"
//        default: return ""
//        }
//    }
//
//    private func getFeelingColor(_ level: Int) -> Color {
//        switch level {
//        case 1: return Color.green.opacity(0.6)
//        case 2: return Color.yellow.opacity(0.6)
//        case 3: return Color.red.opacity(0.6)
//        default: return Color.gray
//        }
//    }
//
//    private func getFeelingIcon(_ level: Int) -> String {
//        switch level {
//        case 1: return "face.smiling"
//        case 2: return "face.dashed"
//        case 3: return "face.dashed.fill"
//        default: return "face.smiling"
//        }
//    }
//}
//
//#Preview {
//    // 💡 แก้ไข: ห่อด้วย NavigationView เพื่อให้ NavigationLink ทำงาน
//    NavigationView {
//        DiaryHistoryView()
//            .background(Color(red: 94/255, green: 84/255, blue: 68/255))
//    }
//}

import SwiftUI

struct DiaryHistoryView: View {
    // --- State Variables ---
    @State private var selectedMonth = Date()
    @State private var showMonthPicker = false
    
    // ✅ เพิ่ม State สำหรับข้อมูลจาก Database
    @State private var entries: [DiaryEntry] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // ✅ เพิ่ม Service
    private let diaryService = DiaryService()
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255)
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255)
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("กำลังโหลด...")
                    .foregroundColor(.white)
            } else {
                contentView
            }
        }
        // ✅ โหลดข้อมูลเมื่อ View ปรากฏ
        .task {
            await loadEntries()
        }
        // ✅ โหลดข้อมูลใหม่เมื่อเปลี่ยนเดือน
        .onChange(of: selectedMonth) { _ in
            Task {
                await loadEntries()
            }
        }
        // ✅ Refresh เมื่อกลับมาจากหน้าอื่น
        .onAppear {
            Task {
                await loadEntries()
            }
        }
    }
    
    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // MARK: - Month Selector
                HStack {
                    Button(action: { changeMonth(-1) }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text(selectedMonth, formatter: monthYearFormatter)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { changeMonth(1) }) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // ✅ แสดง Error ถ้ามี
                if let errorMessage = errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                
                // ✅ แสดงข้อความถ้าไม่มีข้อมูล
                if entries.isEmpty && !isLoading {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.5))
                        Text("ยังไม่มีข้อมูลในเดือนนี้")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                        Text("เริ่มบันทึกความรู้สึกของคุณวันนี้")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 40)
                } else if !entries.isEmpty {
                    // MARK: - Summary Statistics Card
                    ZStack(alignment: .topTrailing) {
                        VStack(spacing: 16) {
                            HStack {
                                Text("สรุปเดือนนี้")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("\(filteredEntries().count) วัน")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            
                            // Feeling ที่มากที่สุด
                            HStack(spacing: 12) {
                                if let mostFeeling = getMostFrequentFeeling() {
                                    if UIImage(named: getFeelingImageName(mostFeeling)) != nil {
                                        Image(getFeelingImageName(mostFeeling))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 80)
                                    } else {
                                        Circle()
                                            .fill(getFeelingColor(mostFeeling))
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                Image(systemName: getFeelingIcon(mostFeeling))
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("ความรู้สึกที่พบบ่อยสุด:")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    if let mostFeeling = getMostFrequentFeeling() {
                                        Text(getFeelingTitle(mostFeeling))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            Divider()
                            
                            // สรุป % แต่ละแบบ
                            VStack(spacing: 12) {
                                FeelingPercentageRow(
                                    title: "ดีขึ้น",
                                    color: .green,
                                    percentage: getFeelingPercentage(1)
                                )
                                
                                FeelingPercentageRow(
                                    title: "เหมือนเดิม",
                                    color: .yellow,
                                    percentage: getFeelingPercentage(2)
                                )
                                
                                FeelingPercentageRow(
                                    title: "ปวดมากขึ้น",
                                    color: .red,
                                    percentage: getFeelingPercentage(3)
                                )
                            }
                        }
                        .padding(20)
                        
                        // ปุ่มดูกราฟ
                        NavigationLink(destination:
                            DiarychartView(
                                entries: filteredEntries(),
                                selectedMonth: selectedMonth
                            )
                        ) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.black.opacity(0.7))
                                .padding(10)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                        .disabled(filteredEntries().isEmpty)
                        .opacity(filteredEntries().isEmpty ? 0.5 : 1.0)
                        .padding(.trailing, 16)
                        .padding(.top, 12)
                    }
                    .background(cardBackground)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    
                    // MARK: - Calendar Grid
                    VStack(alignment: .leading, spacing: 12) {
                        // Weekday Headers
                        HStack {
                            ForEach(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], id: \.self) { day in
                                Text(day)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        // Calendar Days
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 12) {
                            ForEach(getDaysInMonth(), id: \.self) { date in
                                if let date = date {
                                    DayCell(
                                        date: date,
                                        entry: getEntry(for: date)
                                    )
                                } else {
                                    Color.clear
                                        .frame(height: 70)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(cardBackground)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        // ✅ เพิ่ม Pull to Refresh
        .refreshable {
            await loadEntries()
        }
    }
    
    // MARK: - ✅ Load Entries from Database
    private func loadEntries() async {
        isLoading = true
        errorMessage = nil
        
        do {
            entries = try await diaryService.fetchEntriesForMonth(date: selectedMonth)
            print("✅ โหลดข้อมูลสำเร็จ: \(entries.count) รายการ")
        } catch {
            errorMessage = "ไม่สามารถโหลดข้อมูลได้: \(error.localizedDescription)"
            print("❌ Error loading entries: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Functions
    private func changeMonth(_ value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func filteredEntries() -> [DiaryEntry] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.date, equalTo: selectedMonth, toGranularity: .month)
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date?] = []
        let offset = (firstWeekday == 1 ? 6 : firstWeekday - 2)
        
        for _ in 0..<offset {
            days.append(nil)
        }
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func getEntry(for date: Date) -> DiaryEntry? {
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func getFeelingPercentage(_ level: Int) -> Int {
        let currentMonthEntries = filteredEntries()
        guard !currentMonthEntries.isEmpty else { return 0 }
        let count = currentMonthEntries.filter { $0.feelingLevel == level }.count
        return Int((Double(count) / Double(currentMonthEntries.count)) * 100)
    }
    
    private func getMostFrequentFeeling() -> Int? {
        let currentMonthEntries = filteredEntries()
        guard !currentMonthEntries.isEmpty else { return nil }
        
        let counts = [
            1: currentMonthEntries.filter { $0.feelingLevel == 1 }.count,
            2: currentMonthEntries.filter { $0.feelingLevel == 2 }.count,
            3: currentMonthEntries.filter { $0.feelingLevel == 3 }.count
        ]
        
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
    private func getFeelingTitle(_ level: Int) -> String {
        switch level {
        case 1: return "ดีขึ้น"
        case 2: return "เหมือนเดิม"
        case 3: return "ปวดมากขึ้น"
        default: return ""
        }
    }
    
    private func getFeelingImageName(_ level: Int) -> String {
        switch level {
        case 1: return "feeling_better"
        case 2: return "feeling_same"
        case 3: return "feeling_worse"
        default: return ""
        }
    }
    
    private func getFeelingColor(_ level: Int) -> Color {
        switch level {
        case 1: return Color.green.opacity(0.6)
        case 2: return Color.yellow.opacity(0.6)
        case 3: return Color.red.opacity(0.6)
        default: return Color.gray
        }
    }
    
    private func getFeelingIcon(_ level: Int) -> String {
        switch level {
        case 1: return "face.smiling"
        case 2: return "face.dashed"
        case 3: return "face.dashed.fill"
        default: return "face.smiling"
        }
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }
}

// MARK: - Feeling Percentage Row
struct FeelingPercentageRow: View {
    let title: String
    let color: Color
    let percentage: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(color.opacity(0.6))
                .frame(width: 16, height: 16)
            
            Text(title)
                .font(.body)
                .foregroundColor(.black)
            
            Spacer()
            
            Text("\(percentage)%")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(percentage) / 100, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(width: 60, height: 6)
        }
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let entry: DiaryEntry?
    
    var body: some View {
        VStack(spacing: 4) {
            // Emoji/Icon
            if let entry = entry {
                if UIImage(named: getFeelingImageName(entry.feelingLevel)) != nil {
                    Image(getFeelingImageName(entry.feelingLevel))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                } else {
                    Circle()
                        .fill(getFeelingColor(entry.feelingLevel))
                        .frame(width: 35, height: 35)
                        .overlay(
                            Image(systemName: getFeelingIcon(entry.feelingLevel))
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 35, height: 35)
            }
            
            // วันที่
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(entry != nil ? .black : .gray.opacity(0.5))
        }
        .frame(height: 70)
    }
    
    // Helper Functions
    private func getFeelingImageName(_ level: Int) -> String {
        switch level {
        case 1: return "feeling_better"
        case 2: return "feeling_same"
        case 3: return "feeling_worse"
        default: return ""
        }
    }
    
    private func getFeelingColor(_ level: Int) -> Color {
        switch level {
        case 1: return Color.green.opacity(0.6)
        case 2: return Color.yellow.opacity(0.6)
        case 3: return Color.red.opacity(0.6)
        default: return Color.gray
        }
    }
    
    private func getFeelingIcon(_ level: Int) -> String {
        switch level {
        case 1: return "face.smiling"
        case 2: return "face.dashed"
        case 3: return "face.dashed.fill"
        default: return "face.smiling"
        }
    }
}

#Preview {
    NavigationView {
        DiaryHistoryView()
            .background(Color(red: 94/255, green: 84/255, blue: 68/255))
    }
}
