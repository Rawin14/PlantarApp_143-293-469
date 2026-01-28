//
//  DashboardViewModel.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 9/1/2569 BE.
//
//
//import Foundation
//
//@MainActor
//final class DashboardViewModel: ObservableObject {
//
//    @Published var videoProgress: Double = 0.0
//    @Published var watchedVideos: Int = 0
//    @Published var totalVideos: Int = 0
//    
//    // MARK: - Mood
//    @Published var averageMood: Double = 0
//    @Published var feelingBetterPercentage: Double = 0
//
//    // MARK: - Weekly Summary (0...1)
//    @Published var weeklyMood: [Double] = Array(repeating: 0, count: 7)
//
//    func load(diaryEntries: [DiaryEntry]) {
//        guard !diaryEntries.isEmpty else {
//            averageMood = 0
//            feelingBetterPercentage = 0
//            weeklyMood = Array(repeating: 0, count: 7)
//            return
//        }
//
//        let moods = diaryEntries.map { Double($0.feelingLevel) }
//        averageMood = moods.reduce(0, +) / Double(moods.count)
//        feelingBetterPercentage = averageMood / 3
//
//        let sorted = diaryEntries.sorted { $0.date > $1.date }
//        weeklyMood = sorted.prefix(7).map {
//            Double($0.feelingLevel) / 3
//        }
//
//        while weeklyMood.count < 7 {
//            weeklyMood.append(0)
//        }
//    }
//
//
//    // MARK: - Mood Logic
//    private func calculateMood(_ diary: [DiaryEntry]) {
//        let moods = diary.map { Double($0.feelingLevel) }
//
//        averageMood = moods.reduce(0, +) / Double(moods.count)
//        feelingBetterPercentage = averageMood / 3   // เพราะมี 3 ระดับ
//    }
//
//    // MARK: - Weekly Summary
//    private func calculateWeekly(_ diary: [DiaryEntry]) {
//
//        let sorted = diary.sorted { $0.date > $1.date }
//
//        weeklyMood = sorted.prefix(7).map {
//            Double($0.feelingLevel) / 3
//        }
//
//        while weeklyMood.count < 7 {
//            weeklyMood.append(0)
//        }
//    }
//
//    private func reset() {
//        averageMood = 0
//        feelingBetterPercentage = 0
//        weeklyMood = Array(repeating: 0, count: 7)
//    }
//}




import Foundation

//@MainActor
//final class DashboardViewModel: ObservableObject {
//    
//    @Published var videoProgress: Double = 0
//    @Published var watchedVideos: Int = 0
//    @Published var totalVideos: Int = 0
//
//    // MARK: - Mood
//    @Published var averageMoodPercent: Double = 0        // 0–1
//    @Published var feelingBetterPercentage: Double = 0   // 0–1
//
//    // MARK: - Weekly Summary (Mon–Sun, 0–1)
//    @Published var weeklyMood: [Double] = Array(repeating: 0, count: 7)
//
//    // MARK: - Load Video Progress (จาก UserProfile)
//    func loadVideoProgress(
//        watchedIDs: Set<UUID>,
//        totalVideos: Int
//    ) {
//        self.totalVideos = totalVideos
//        self.watchedVideos = watchedIDs.count
//
//        guard totalVideos > 0 else {
//            videoProgress = 0
//            return
//        }
//
//        videoProgress = Double(watchedVideos) / Double(totalVideos)
//    }
//
//    // MARK: - Load Diary Stats (จาก DiaryHistory)
//    func loadDiaryStats(entries: [DiaryEntry]) {
//        guard !entries.isEmpty else {
//            resetDiaryStats()
//            return
//        }
//
//        calculateAverageMood(entries)
//        calculateFeelingBetter(entries)
//        calculateWeeklyMood(entries)
//    }
//
//    // MARK: - Average Mood (%)
//    private func calculateAverageMood(_ entries: [DiaryEntry]) {
//        let sum = entries.reduce(0) { $0 + $1.feelingLevel }
//        let average = Double(sum) / Double(entries.count)   // 1–3
//        averageMoodPercent = average / 3                    // 0–1
//    }
//
//    // MARK: - Feeling Better (%)
//    private func calculateFeelingBetter(_ entries: [DiaryEntry]) {
//        let betterCount = entries.filter { $0.feelingLevel == 1 }.count
//        feelingBetterPercentage = Double(betterCount) / Double(entries.count)
//    }
//
//    // MARK: - Weekly Summary (ตามวันจริง จ–อา)
//    private func calculateWeeklyMood(_ entries: [DiaryEntry]) {
//        var result = Array(repeating: 0.0, count: 7)
//        var count = Array(repeating: 0, count: 7)
//
//        let calendar = Calendar(identifier: .gregorian)
//
//        for entry in entries {
//            let weekday = calendar.component(.weekday, from: entry.date)
//            let index = (weekday + 5) % 7   // จ=0 ... อา=6
//
//            result[index] += Double(entry.feelingLevel)
//            count[index] += 1
//        }
//
//        weeklyMood = (0..<7).map { i in
//            guard count[i] > 0 else { return 0 }
//            return (result[i] / Double(count[i])) / 3
//        }
//    }
//
//    // MARK: - Reset
//    private func resetDiaryStats() {
//        averageMoodPercent = 0
//        feelingBetterPercentage = 0
//        weeklyMood = Array(repeating: 0, count: 7)
//    }
//}

//@MainActor
//final class DashboardViewModel: ObservableObject {
//
//    // MARK: - Video Progress
//    @Published var videoProgress: Double = 0
//    @Published var watchedVideos: Int = 0
//    @Published var totalVideos: Int = 0
//
//    // MARK: - Mood
//    @Published var averageMood: Double = 0
//    @Published var feelingBetterPercentage: Double = 0
//
//    // MARK: - Weekly Summary (0...1)
//    @Published var weeklyMood: [Double] = Array(repeating: 0, count: 7)
//
//    // MARK: - Load All Dashboard Data
//    func load(
//        diaryEntries: [DiaryEntry],
//        videos: [VideoExercise],
//        watchedVideoIDs: Set<String>
//    ) {
//        calculateVideoProgress(videos: videos, watchedIDs: watchedVideoIDs)
//        calculateMood(diaryEntries)
//        calculateWeekly(diaryEntries)
//    }
//
//    // MARK: - Video Logic (ของจริง)
//    private func calculateVideoProgress(
//        videos: [VideoExercise],
//        watchedIDs: Set<String>
//    ) {
//        totalVideos = videos.count
//        watchedVideos = videos.filter {watchedIDs.contains($0.id) }.count
//
//        if totalVideos == 0 {
//            videoProgress = 0
//        } else {
//            videoProgress = Double(watchedVideos) / Double(totalVideos)
//        }
//    }
//
//    // MARK: - Mood Logic
//    private func calculateMood(_ diary: [DiaryEntry]) {
//        guard !diary.isEmpty else {
//            averageMood = 0
//            feelingBetterPercentage = 0
//            return
//        }
//
//        let moods = diary.map { Double($0.feelingLevel) }
//        averageMood = moods.reduce(0, +) / Double(moods.count)
//
//        // feelingLevel: 1 = ดีขึ้น, 2 = เหมือนเดิม, 3 = แย่ลง
//        let betterCount = diary.filter { $0.feelingLevel == 1 }.count
//        feelingBetterPercentage = Double(betterCount) / Double(diary.count)
//    }
//
//    // MARK: - Weekly Summary
//    private func calculateWeekly(_ diary: [DiaryEntry]) {
//        let calendar = Calendar.current
//        let today = Date()
//
//        let last7Days = (0..<7).compactMap {
//            calendar.date(byAdding: .day, value: -$0, to: today)
//        }
//
//        weeklyMood = last7Days.map { date in
//            if let entry = diary.first(where: {
//                calendar.isDate($0.date, inSameDayAs: date)
//            }) {
//                return Double(entry.feelingLevel) / 3
//            } else {
//                return 0
//            }
//        }
//    }
//}
