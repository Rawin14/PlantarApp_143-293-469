//
//  PFResultView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 19/11/2568 BE.
//

import SwiftUI
import SceneKit // 1. เพิ่ม import SceneKit

struct PFResultView: View {
    
    // เพิ่ม State สำหรับไปหน้า Home
    @State private var navigateToHome = false
    @AppStorage("isProfileSetupCompleted") var isProfileSetupCompleted: Bool = false
    @EnvironmentObject var userProfile: UserProfile
    @State private var scanResult: FootScanResult?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    
    let scanId: String
    // 🔥🔥🔥 เพิ่ม init นี้เข้าไปครับ 🔥🔥🔥
        init(scanId: String, mockResult: FootScanResult? = nil) {
            self.scanId = scanId
            
            // เช็คว่าถ้าเป็นการ Preview (มี mockResult ส่งมา)
            if let result = mockResult {
                // กำหนดค่าเริ่มต้นให้ State โดยตรง
                _scanResult = State(initialValue: result)
                _isLoading = State(initialValue: false)
            }
        }
        // 🔥🔥🔥 จบส่วนที่เพิ่ม 🔥🔥🔥
    
    var body: some View {
        ZStack {
            Color(red: 247/255, green: 246/255, blue: 236/255).ignoresSafeArea()
            
            if isLoading {
                ProgressView("กำลังประมวลผล...")
            } else if let result = scanResult {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Header
                        Text("ผลการวิเคราะห์")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        // --- ส่วนแสดงคะแนนความเสี่ยง (ใช้สูตรใหม่ BMI + Evaluate) ---
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                .frame(width: 180, height: 180)
                            
                            // วงกลมคะแนน (คำนวณ % จากคะแนนเต็มประมาณ 23)
                            Circle()
                                .trim(from: 0, to: userProfile.totalRiskScore / 23.0)
                                .stroke(riskColor(userProfile.riskSeverity), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 180, height: 180)
                                .rotationEffect(.degrees(-90))
                            
                            VStack(spacing: 4) {
                                Text("\(Int(userProfile.totalRiskScore))")
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(riskColor(userProfile.riskSeverity))
                                
                                Text(userProfile.riskSeverity) // แสดง Low/Medium/High Risk
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical)
                        
                        // --- ส่วนแสดงรายละเอียดคะแนนที่มา ---
                        HStack(spacing: 15) {
                            // BMI Score
                            ScoreDetailCard(
                                title: "BMI Score",
                                score: "\(userProfile.bmiScore)",
                                max: "3",
                                color: .blue
                            )
                            
                            // Evaluate Score
                            ScoreDetailCard(
                                title: "Evaluate",
                                score: "\(Int(userProfile.evaluateScore))",
                                max: "17",
                                color: Color(hex: "C4CF52")
                            )
                        }
                        .padding(.horizontal)
                        
                        // --- ส่วนแสดงผลจาก Scan (Arch Type) ---
                        if let archType = result.arch_type {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("ลักษณะรูปเท้า (จากการสแกน)")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                InfoCard(
                                    icon: "figure.walk",
                                    title: "ประเภทโค้งเท้า",
                                    value: archTypeText(archType),
                                    color: Color(hex: "50463C")
                                )
                                .padding(.horizontal)
                            }
                                RecommendationCard(
                                    icon: "exclamationmark.triangle",
                                    title: "คำเตือน: ผลการวิเคราะห์ที่เห็นเป็นเพียงแค่การวินิจฉัยรอยเท้าเบื้องต้นเท่านั้น",
                                    color: .red
                                )
                            .padding(.horizontal)
                        }
                        
                        // ปุ่มกลับหน้าหลัก
                        Button(action: {
                            isProfileSetupCompleted = true
                            
                            navigateToHome = true
                        }) {
                            Text("เข้าสู่หน้าหลัก")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 94/255, green: 84/255, blue: 68/255))
                                .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
        }
        .task {
            await loadScanResult()
        }
    }
    
    func loadScanResult() async {
        do {
            let response: [FootScanResult] = try await UserProfile.supabase
                .from("foot_scans")
                .select("*") // เลือกทั้งหมดมาก่อน
                .eq("id", value: scanId)
                .execute()
                .value
            
            if let result = response.first {
                scanResult = result
            }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // ... (Helper Functions: severityColor, severityText, archTypeText คงเดิม) ...
    func severityColor(_ severity: String?) -> Color {
        switch severity {
        case "low": return .green
        case "medium": return .yellow
        case "high": return .red
        default: return .gray
        }
    }
    
    func severityText(_ severity: String?) -> String {
        switch severity {
        case "low": return "ระดับต่ำ"
        case "medium": return "ระดับกลาง"
        case "high": return "ระดับสูง"
        default: return "กำลังประมวลผล"
        }
    }
    
    func archTypeText(_ type: String) -> String {
        switch type {
        case "flat": return "เท้าแบน"
        case "high": return "โค้งเท้าสูง"
        case "normal": return "โค้งเท้าปกติ"
        default: return type
        }
    }
    // Helper Colors
    func riskColor(_ severity: String) -> Color {
        switch severity {
        case "Low Risk": return .green
        case "Medium Risk": return .orange
        case "High Risk": return .red
        default: return .gray
        }
    }
}

// 5. เพิ่ม Struct สำหรับแสดง 3D Model (SceneKit)
struct Foot3DView: UIViewRepresentable {
    let modelUrl: URL
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = UIColor.clear
        scnView.allowsCameraControl = true // ให้หมุนโมเดลได้
        scnView.autoenablesDefaultLighting = true
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // โหลดโมเดลแบบ Async เพื่อไม่ให้ UI ค้าง
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // หมายเหตุ: การโหลด Scene จาก URL โดยตรงอาจต้องใช้ Library เสริมหรือดาวน์โหลดไฟล์ลงเครื่องก่อน
                // ในที่นี้ใช้โค้ดพื้นฐานสำหรับ SceneKit หากไฟล์เป็น .scn หรือ .usdz ที่รองรับ
                let scene = try SCNScene(url: modelUrl, options: nil)
                
                DispatchQueue.main.async {
                    uiView.scene = scene
                }
            } catch {
                print("Error loading 3D model: \(error)")
                // สามารถใส่ Placeholder scene ได้ที่นี่ถ้าโหลดไม่ผ่าน
            }
        }
    }
}

// การ์ดแสดงคะแนนย่อย
struct ScoreDetailCard: View {
    let title: String
    let score: String
    let max: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(score)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text("/\(max)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
// ... (Supporting Views: InfoCard, RecommendationCard คงเดิม) ...
// (ExerciseCard และ ShoeRecommendationCard ลบออกได้ถ้าไม่ได้ใช้ที่อื่น หรือปล่อยไว้ก็ได้แต่ไม่ได้เรียกใช้)

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(Color.white) // ไอคอนพื้นขาว
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(color.opacity(0.8)) // สีตัวอักษรตาม Theme
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding()
        // 3. ใช้พื้นหลังเป็นสี Theme แบบจางๆ ทั้งการ์ด
        .background(color.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1) // เพิ่มขอบบางๆ
        )
    }
}

struct RecommendationCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(Color.white) // ไอคอนพื้นขาว
                    .clipShape(Circle())
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "50463C"))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Models

struct FootScanResult: Codable {
    let id: String
    let user_id: String
    let foot_side: String
    let images_url: [String]
    let model_3d_url: String?
    let pf_severity: String?
    let pf_score: Double?
    let arch_type: String?
    let status: String
    let error_message: String?
    let pf_indicators: [PFIndicator]?
    let exercise_recommendations: [Exercise]?
    let shoe_recommendations: [ShoeRecommendation]?
}

struct PFIndicator: Codable {
    let id: String
    let arch_collapse_score: Double
    let heel_pain_index: Double
    let pressure_distribution_score: Double
    let foot_alignment_score: Double
    let flexibility_score: Double
    let risk_factors: [String]
    let recommendations: [String]
    let scan_part_score: Double?
    let questionnaire_part_score: Double?
}

struct Exercise: Codable {
    let id: String
    let exercise_name: String
    let description: String
    let video_url: String?
    let duration_minutes: Int
    let difficulty: String
    let recommended_frequency: String
}

struct ShoeRecommendation: Codable {
    let id: String
    let shoe_name: String
    let brand: String
    let match_score: Double
    let pf_support_score: Double
    let size_recommendation: String
    let image_url: String?
    let price: Double?
}

#Preview {
    // 1. สร้าง Mock Data
    let mockIndicator = PFIndicator(
        id: "ind_001",
        arch_collapse_score: 80.0,
        heel_pain_index: 50.0,
        pressure_distribution_score: 45.0,
        foot_alignment_score: 15.0,
        flexibility_score: 60.0,
        risk_factors: ["น้ำหนักตัวเกินเกณฑ์", "เท้าแบน (Flat Arch)"],
        recommendations: ["ควรสวมรองเท้าที่มี Arch Support", "ลดน้ำหนัก"],
        scan_part_score: 0.28,
        questionnaire_part_score: 14.0
    )
    
    let mockResult = FootScanResult(
        id: "preview_id",
        user_id: "user_preview",
        foot_side: "left",
        images_url: [],
        model_3d_url: nil,
        pf_severity: "high",
        pf_score: 85.5,
        arch_type: "normal",
        status: "completed",
        error_message: nil,
        pf_indicators: [mockIndicator],
        exercise_recommendations: [],
        shoe_recommendations: []
    )
    
    // 2. สร้าง UserProfile
    let mockProfile = UserProfile()
    // (กำหนดค่าเพิ่มถ้าจำเป็น)
    
    // 3. แสดงผล (❌ ลบคำว่า return ออก)
    NavigationStack {
        PFResultView(scanId: "test_id", mockResult: mockResult)
            .environmentObject(mockProfile)
    }
}
