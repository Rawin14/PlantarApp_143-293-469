//
// EvaluateView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

// MARK: - Question Model
struct Question {
    let id: Int
    let text: String
    let score: Int
}

// MARK: - EvaluateView Colors
extension Color {
    static let Evaluate_Background = Color(
        red: 172/255,
        green: 187/255,
        blue: 98/255
    ) // สีเขียวมะนาวล้วนๆ
    static let Evaluate_Primary = Color(
        red: 172/255,
        green: 187/255,
        blue: 98/255
    ) // สีเขียวมะนาว
    static let Evaluate_Secondary = Color(
        red: 139/255,
        green: 122/255,
        blue: 184/255
    ) // สีม่วง
    static let Evaluate_CardBackground = Color.white // พื้นหลังการ์ดสีขาว
    static let Evaluate_SelectedAnswer = Color(
        red: 188/255,
        green: 204/255,
        blue: 112/255
    ) // สีเขียวอ่อน
    static let Evaluate_ButtonColor = Color(
        red: 94/255,
        green: 84/255,
        blue: 68/255
    ) // สีปุ่ม Next
    static let Evaluate_DotInactive = Color(
        red: 220/255,
        green: 220/255,
        blue: 220/255
    )
}

struct EvaluateView: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @EnvironmentObject var userProfile: UserProfile
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Bool? = nil // true = ใช่, false = ไม่ใช่
    @State private var totalScore = 0
    @State private var navigateToNext = false
    @State private var riskLevel: String = ""
    
    // --- Questions with Scores ---
    let questions: [Question] = [
        Question(
            id: 1,
            text: "คุณรู้สึกเจ็บส้นเท้าหรือฝ่าเท้าทันทีที่ก้าวลงจากเตียงในตอนเช้าใช่หรือไม่?",
            score: 1
        ),
        Question(
            id: 2,
            text: "คุณรู้สึกเจ็บส้นเท้าเมื่อคุณเริ่มออกเดินหลังจากนั่งพักเป็นเวลานานใช่หรือไม่?",
            score: 1
        ),
        Question(
            id: 3,
            text: "คุณรู้สึกเจ็บส้นเท้าหรือฝ่าเท้าหลังจากทำกิจกรรมที่ต้องยืนหรือเดินเป็นเวลานานใช่หรือไม่?",
            score: 1
        ),
        Question(
            id: 4,
            text: "คุณรู้สึกเจ็บที่บริเวณส่วนโค้งของฝ่าเท้าหรือที่ขอบส้นเท้าใช่หรือไม่?",
            score: 1
        ),
        Question(
            id: 5,
            text: "คุณต้องเดินเขย่งปลายเท้าเพื่อหลีกเลี่ยงการลงน้ำหนักที่ส้นเท้าใช่หรือไม่?",
            score: 2
        ),
        Question(
            id: 6,
            text: "อาการปวดของคุณเกิดขึ้นเป็นประจำในทุก ๆ วันใช่หรือไม่?",
            score: 2
        ),
        Question(
            id: 7,
            text: "คุณรู้สึกว่าอาการปวดส่งผลกระทบต่อกิจกรรมประจำวันของคุณ เช่น การเดินช็อปปิ้ง การออกกำลังกาย หรือการทำงานใช่หรือไม่?",
            score: 3
        ),
        Question(
            id: 8,
            text: "คุณต้องใช้ยาแก้ปวดเพื่อบรรเทาอาการเจ็บส้นเท้าใช่หรือไม่?",
            score: 3
        ),
        Question(
            id: 9,
            text: "อาการเจ็บของคุณดีขึ้นเพียงชั่วคราวหลังจากนวดหรือพักเท้า แล้วกลับมาปวดอีกครั้งใช่หรือไม่?",
            score: 3
        )
    ]
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    var progress: Double {
        Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    // คำนวณระดับความเสี่ยง
    //    func calculateRiskLevel() -> String {
    //        if totalScore >= 0 && totalScore <= 5 {
    //            return "Low Risk"
    //        } else if totalScore >= 6 && totalScore <= 12 {
    //            return "Medium Risk"
    //        } else {
    //            return "High Risk"
    //        }
    //    }
    
    var body: some View {
        ZStack {
            // Solid Green Background
            Color.Evaluate_Background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Main Card
                VStack(spacing: 0) {
                    // Header Badge
                    Text("Foot Health Assessment")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.Evaluate_Secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.Evaluate_Secondary.opacity(0.1))
                        )
                        .padding(.top, 30)
                    
                    // Question Title
                    VStack(spacing: 12) {
                        Text(currentQuestion.text)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                        
                        Text("(\(currentQuestion.score) คะแนน)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 40)
                    
                    // Answer Options
                    VStack(spacing: 16) {
                        // ปุ่ม "ใช่"
                        AnswerOptionButton(
                            icon: "checkmark.circle.fill",
                            title: "ใช่",
                            subtitle: "มีอาการตามที่ถาม",
                            isSelected: selectedAnswer == true,
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedAnswer = true
                                }
                            }
                        )
                        
                        // ปุ่ม "ไม่ใช่"
                        AnswerOptionButton(
                            icon: "xmark.circle.fill",
                            title: "ไม่ใช่",
                            subtitle: "ไม่มีอาการตามที่ถาม",
                            isSelected: selectedAnswer == false,
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedAnswer = false
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<questions.count, id: \.self) { index in
                            Circle()
                                .fill(
                                    index == currentQuestionIndex ? Color.Evaluate_Secondary : Color.Evaluate_DotInactive
                                )
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.Evaluate_CardBackground)
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                )
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // MARK: - Score Display
                HStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(Color.Evaluate_Primary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("คะแนนรวม")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(totalScore) / 17")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.Evaluate_Secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.05),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                )
                .padding(.horizontal, 20)
                
                // MARK: - Navigation Buttons
                HStack(spacing: 16) {
                    // Back Button (สีน้ำตาล)
                    Button(action: {
                        if currentQuestionIndex > 0 {
                            withAnimation {
                                currentQuestionIndex -= 1
                                selectedAnswer = nil
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    currentQuestionIndex > 0 ?
                                    Color.Evaluate_ButtonColor :
                                        Color.Evaluate_ButtonColor.opacity(0.3)
                                )
                        )
                        .disabled(currentQuestionIndex == 0)
                    }
                    
                    // Next/Complete Button (สีน้ำตาล)
                    Button(
                        action: {
                            if let answer = selectedAnswer {
                                if answer {
                                    totalScore += currentQuestion.score
                                }
                                
                                withAnimation {
                                    if currentQuestionIndex < questions.count - 1 {
                                        currentQuestionIndex += 1
                                        selectedAnswer = nil
                                    } else {
                                        userProfile.evaluateScore = Double(totalScore)
                                        print("Evaluate Score: \(totalScore)")
                                        Task {
                                            await userProfile.saveToSupabase()
                                        }
                                        navigateToNext = true
                                    }
                                }
                            }
                        }) {
                            HStack {
                                Text(currentQuestionIndex < questions.count - 1 ? "Next" : "Complete")
                                    .font(.system(size: 16, weight: .semibold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(
                                        selectedAnswer != nil ?
                                        Color.Evaluate_ButtonColor :
                                            Color.Evaluate_ButtonColor.opacity(0.5)
                                    )
                            )
                        }
                        .disabled(selectedAnswer == nil)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            
            // Navigation to Result Pages
            NavigationLink(
                destination: ScanView(),
                isActive: $navigateToNext
            ) {
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    //    // MARK: - Destination View Based on Risk Level
    //    @ViewBuilder
    //    func destinationView() -> some View {
    //        switch riskLevel {
    //        case "Low Risk":
    //            LowRisk()
    //        case "Medium Risk":
    //            MediumRisk()
    //        case "High Risk":
    //            HighRisk()
    //        default:
    //            LowRisk()
    //        }
    //    }
}

// MARK: - Answer Option Button Component
struct AnswerOptionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            isSelected ? Color.Evaluate_Secondary
                                .opacity(0.1) : Color.clear
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(
                            isSelected ? Color.Evaluate_Secondary : Color.gray
                                .opacity(0.3)
                        )
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.Evaluate_Secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color.Evaluate_Secondary : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: isSelected ? Color.Evaluate_Secondary
                            .opacity(0.2) : Color.black
                            .opacity(0.05),
                        radius: isSelected ? 10 : 5,
                        x: 0,
                        y: isSelected ? 5 : 2
                    )
            )
        }
    }
}

#Preview {
    NavigationStack {
        EvaluateView()
    }
}
