//
//  DiarychartView.swift
//  Plantar
//
//  Created by ncp on 19/11/2568 BE.
//

import SwiftUI
import Charts

struct DiarychartView: View {
    // ⚠️ รับข้อมูลที่กรองแล้วและเดือนที่เลือกจาก DiaryHistoryView
    let entries: [DiaryEntry]
    let selectedMonth: Date
    
    // Custom Colors
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255)
    
    // Helper function to map level to title for Y-axis
    private func levelToTitle(_ level: Int) -> String {
        switch level {
        case 1: return "1: ดีขึ้นปวดน้อยลง"
        case 2: return "2: เหมือนเดิม"
        case 3: return "3: ปวดมากขึ้น (ปวดมาก)"
        default: return ""
        }
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }

    var body: some View {
    
        ZStack {
            // ตั้งค่าพื้นหลังตาม Theme เดิม
            Color(red: 94/255, green: 84/255, blue: 68/255).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("แนวโน้มอาการปวด: \(selectedMonth, formatter: monthYearFormatter)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                // MARK: - กราฟเส้นแสดงแนวโน้ม
                VStack(alignment: .leading, spacing: 10) {
                    
                    // 1. Chart View
                    Chart {
                        ForEach(entries.sorted(by: { $0.date < $1.date })) { entry in
                            LineMark(
                                x: .value("วันที่", entry.date, unit: .day), // แกน X คือวันที่
                                y: .value("ระดับความรู้สึก", entry.feelingLevel) // แกน Y คือระดับความรู้สึก
                            )
                            .foregroundStyle(accentColor)
                            
                            PointMark(
                                x: .value("วันที่", entry.date, unit: .day),
                                y: .value("ระดับความรู้สึก", entry.feelingLevel)
                            )
                            // สีของจุดขึ้นอยู่กับระดับความรู้สึก
                            .foregroundStyle(entry.feelingLevel == 3 ? .red : entry.feelingLevel == 1 ? .green : .yellow)
                            .symbolSize(100)
                            
                            if let averageLevel = entries.averageFeelingLevel {
                                RuleMark(y: .value("ค่าเฉลี่ย", averageLevel))
                                    .foregroundStyle(.gray.opacity(0.5))
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                                    .annotation(position: .top, alignment: .leading) {
                                        Text("เฉลี่ย: \(averageLevel, specifier: "%.1f")")
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
                                    Text(levelToTitle(intValue))
                                }
                            }
                        }
                    }
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
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}

// MARK: - Array Extension for Average Calculation
extension Array where Element == DiaryEntry {
    var averageFeelingLevel: Double? {
        guard !isEmpty else { return nil }
        let total = self.reduce(0) { $0 + $1.feelingLevel }
        return Double(total) / Double(self.count)
    }
}

// MARK: - Preview (แก้ไขแล้ว)
#Preview {
    let now = Date()
    let calendar = Calendar.current
    let selectedMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!

    let sampleEntries = [
        DiaryEntry(date: now.addingTimeInterval(-86400 * 0), feelingLevel: 2, note: nil),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 1), feelingLevel: 3, note: "ปวดหลังเดิน"),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 2), feelingLevel: 1, note: nil),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 3), feelingLevel: 3, note: nil),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 4), feelingLevel: 2, note: nil),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 5), feelingLevel: 1, note: nil),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 6), feelingLevel: 2, note: nil),
        DiaryEntry(date: now.addingTimeInterval(-86400 * 7), feelingLevel: 3, note: nil),
    ]
    
    NavigationView {
        DiarychartView(entries: sampleEntries, selectedMonth: selectedMonth)
    }
}
