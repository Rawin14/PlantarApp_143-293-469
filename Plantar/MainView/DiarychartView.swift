////
////  DiarychartView.swift
////  Plantar
////
////  Created by ncp on 19/11/2568 BE.
////
//
//import SwiftUI
//import Charts
//
//struct DiarychartView: View {
//    // ⚠️ รับข้อมูลที่กรองแล้วและเดือนที่เลือกจาก DiaryHistoryView
//    let entries: [DiaryEntry]
//    let selectedMonth: Date
//    
//    // Custom Colors
//    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
//    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255)
//    
//    // Helper function to map level to title for Y-axis
//    private func levelToTitle(_ level: Int) -> String {
//        switch level {
//        case 1: return "1: ดีขึ้นปวดน้อยลง"
//        case 2: return "2: เหมือนเดิม"
//        case 3: return "3: ปวดมากขึ้น (ปวดมาก)"
//        default: return ""
//        }
//    }
//    
//    private var monthYearFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM yyyy"
//        return formatter
//    }
//
//    var body: some View {
//    
//        ZStack {
//            // ตั้งค่าพื้นหลังตาม Theme เดิม
//            Color(red: 94/255, green: 84/255, blue: 68/255).edgesIgnoringSafeArea(.all)
//            
//            VStack(spacing: 20) {
//                Text("แนวโน้มอาการปวด: \(selectedMonth, formatter: monthYearFormatter)")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .padding(.top, 10)
//                
//                // MARK: - กราฟเส้นแสดงแนวโน้ม
//                VStack(alignment: .leading, spacing: 10) {
//                    
//                    // 1. Chart View
//                    Chart {
//                        ForEach(entries.sorted(by: { $0.date < $1.date })) { entry in
//                            LineMark(
//                                x: .value("วันที่", entry.date, unit: .day), // แกน X คือวันที่
//                                y: .value("ระดับความรู้สึก", entry.feelingLevel) // แกน Y คือระดับความรู้สึก
//                            )
//                            .foregroundStyle(accentColor)
//                            
//                            PointMark(
//                                x: .value("วันที่", entry.date, unit: .day),
//                                y: .value("ระดับความรู้สึก", entry.feelingLevel)
//                            )
//                            // สีของจุดขึ้นอยู่กับระดับความรู้สึก
//                            .foregroundStyle(entry.feelingLevel == 3 ? .red : entry.feelingLevel == 1 ? .green : .yellow)
//                            .symbolSize(100)
//                            
//                            if let averageLevel = entries.averageFeelingLevel {
//                                RuleMark(y: .value("ค่าเฉลี่ย", averageLevel))
//                                    .foregroundStyle(.gray.opacity(0.5))
//                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
//                                    .annotation(position: .top, alignment: .leading) {
//                                        Text("เฉลี่ย: \(averageLevel, specifier: "%.1f")")
//                                            .font(.caption2)
//                                            .foregroundColor(.gray)
//                                    }
//                            }
//                        }
//                    }
//                    .chartYAxis {
//                        AxisMarks(values: [1, 2, 3]) { value in
//                            AxisGridLine()
//                            AxisValueLabel {
//                                if let intValue = value.as(Int.self) {
//                                    Text(levelToTitle(intValue))
//                                }
//                            }
//                        }
//                    }
//                    .chartXAxis {
//                        AxisMarks(values: .stride(by: .day)) { value in
//                            AxisGridLine()
//                            AxisValueLabel(format: .dateTime.day())
//                        }
//                    }
//                    .frame(height: 250)
//                    .padding()
//                }
//                .padding(.vertical, 10)
//                .background(backgroundColor)
//                .cornerRadius(15)
//                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
//                .padding(.horizontal, 20)
//                
//                Spacer()
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            
//        }
//    }
//}
//
//// MARK: - Array Extension for Average Calculation
//extension Array where Element == DiaryEntry {
//    var averageFeelingLevel: Double? {
//        guard !isEmpty else { return nil }
//        let total = self.reduce(0) { $0 + $1.feelingLevel }
//        return Double(total) / Double(self.count)
//    }
//}
//
//// MARK: - Preview (แก้ไขแล้ว)
//#Preview {
//    let now = Date()
//    let calendar = Calendar.current
//    let selectedMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
//
//    let sampleEntries = [
//        DiaryEntry(date: now.addingTimeInterval(-86400 * 0), feelingLevel: 2, note: nil),
//        DiaryEntry(date: now.addingTimeInterval(-86400 * 1), feelingLevel: 3, note: "ปวดหลังเดิน"),
//        DiaryEntry(date: now.addingTimeInterval(-86400 * 2), feelingLevel: 1, note: nil),
//        DiaryEntry(date: now.addingTimeInterval(-86400 * 3), feelingLevel: 3, note: nil),
//        DiaryEntry(date: now.addingTimeInterval(-86400 * 4), feelingLevel: 2, note: nil),
//        DiaryEntry(date: now.addingTimeInterval(-86400 * 5), feelingLevel: 1, note: nil),
//        DiaryEntry(date: now.addingTimeInterval(-86400 * 6), feelingLevel: 2, note: nil),
//        DiaryEntry(date: now.addingTimeInterval(-86400 * 7), feelingLevel: 3, note: nil),
//    ]
//    
//    NavigationView {
//        DiarychartView(entries: sampleEntries, selectedMonth: selectedMonth)
//    }
//}
import SwiftUI
import Charts
struct DiarychartView: View {
    // รับข้อมูลที่กรองแล้วและเดือนที่เลือกจาก DiaryHistoryView
    let entries: [DiaryEntry]
    let selectedMonth: Date
    
    // Custom Colors
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255)
    
    // ✅ แปลง FeelingComparison เป็นคะแนน (สูง = ดี)
    private func comparisonToScore(_ comparison: FeelingComparison?) -> Int {
        guard let comparison = comparison else { return 2 } // default = เหมือนเดิม
        switch comparison {
        case .better: return 3  // ดีขึ้น = บนสุด
        case .same: return 2    // เหมือนเดิม = กลาง
        case .worse: return 1   // แย่ลง = ล่างสุด
        }
    }
    
    // ✅ Fallback: ถ้าไม่มี feelingComparison ให้แปลงจาก feelingLevel
    private func getChartScore(for entry: DiaryEntry) -> Int {
        if let comparison = entry.feelingComparison {
            return comparisonToScore(comparison)
        }
        // Fallback สำหรับข้อมูลเก่า
        let level = entry.feelingLevel
        if level >= 4 { return 3 }      // ดีมาก/ดี → ดีขึ้น
        else if level == 3 { return 2 } // ปานกลาง → เหมือนเดิม
        else { return 1 }               // แย่/แย่มาก → แย่ลง
    }
    
    // ✅ แปลงคะแนนเป็นข้อความสำหรับแกน Y
    private func scoreToTitle(_ score: Int) -> String {
        switch score {
        case 3: return "ดีขึ้น"
        case 2: return "เหมือนเดิม"
        case 1: return "แย่ลง"
        default: return ""
        }
    }
    
    // ✅ สีตามคะแนน
    private func scoreToColor(_ score: Int) -> Color {
        switch score {
        case 3: return .green
        case 2: return .yellow
        case 1: return .red
        default: return .gray
        }
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        formatter.locale = Locale(identifier: "th_TH")
        return formatter
    }
    var body: some View {
        ZStack {
            Color(red: 94/255, green: 84/255, blue: 68/255).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("แนวโน้มอาการ: \(selectedMonth, formatter: monthYearFormatter)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                // MARK: - กราฟเส้นแสดงแนวโน้ม
                VStack(alignment: .leading, spacing: 10) {
                    
                    Chart {
                        ForEach(entries.sorted(by: { $0.date < $1.date })) { entry in
                            let score = getChartScore(for: entry)
                            
                            LineMark(
                                x: .value("วันที่", entry.date, unit: .day),
                                y: .value("ระดับ", score)
                            )
                            .foregroundStyle(accentColor)
                            .interpolationMethod(.catmullRom) // ทำให้เส้นโค้งนุ่มนวล
                            
                            PointMark(
                                x: .value("วันที่", entry.date, unit: .day),
                                y: .value("ระดับ", score)
                            )
                            .foregroundStyle(scoreToColor(score))
                            .symbolSize(100)
                            
                            // ✅ เส้นค่าเฉลี่ย
                            if let averageScore = entries.averageChartScore {
                                RuleMark(y: .value("ค่าเฉลี่ย", averageScore))
                                    .foregroundStyle(.gray.opacity(0.5))
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                                    .annotation(position: .top, alignment: .leading) {
                                        Text("เฉลี่ย: \(averageScore, specifier: "%.1f")")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: [1, 2, 3]) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let intValue = value.as(Int.self) {
                                    Text(scoreToTitle(intValue))
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .chartYScale(domain: 0.5...3.5) // ขยาย range ให้เห็นชัดขึ้น
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.day())
                        }
                    }
                    .frame(height: 250)
                    .padding()
                }
                .padding(.vertical, 10)
                .background(backgroundColor)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                
                // ✅ Legend / คำอธิบาย
                VStack(spacing: 12) {
                    HStack(spacing: 20) {
                        LegendItem(color: .green, text: "ดีขึ้น (บนสุด)")
                        LegendItem(color: .yellow, text: "เหมือนเดิม (กลาง)")
                        LegendItem(color: .red, text: "แย่ลง (ล่างสุด)")
                    }
                }
                .padding()
                .background(backgroundColor)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
// MARK: - Legend Item
struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}
// MARK: - Array Extension for Average Calculation
extension Array where Element == DiaryEntry {
    var averageChartScore: Double? {
        guard !isEmpty else { return nil }
        
        let total = self.reduce(0) { sum, entry in
            // ใช้ feelingComparison ถ้ามี ไม่งั้นแปลงจาก feelingLevel
            let score: Int
            if let comparison = entry.feelingComparison {
                switch comparison {
                case .better: score = 3
                case .same: score = 2
                case .worse: score = 1
                }
            } else {
                let level = entry.feelingLevel
                if level >= 4 { score = 3 }
                else if level == 3 { score = 2 }
                else { score = 1 }
            }
            return sum + score
        }
        
        return Double(total) / Double(self.count)
    }
}
// MARK: - Preview
#Preview {
    let now = Date()
    let calendar = Calendar.current
    let selectedMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
    let sampleEntries = [
        DiaryEntry(date: now.addingTimeInterval(-86400 * 0), feelingLevel: 5, feelingComparison: .better, note: nil),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 1), feelingLevel: 1, feelingComparison: .worse, note: "ปวดหลังเดิน"),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 2), feelingLevel: 5, feelingComparison: .better, note: nil),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 3), feelingLevel: 3, feelingComparison: .same, note: nil),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 4), feelingLevel: 3, feelingComparison: .same, note: nil),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 5), feelingLevel: 5, feelingComparison: .better, note: nil),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 6), feelingLevel: 1, feelingComparison: .worse, note: nil),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 7), feelingLevel: 3, feelingComparison: .same, note: nil),
    ]
    
    NavigationView {
        DiarychartView(entries: sampleEntries, selectedMonth: selectedMonth)
    }
}

