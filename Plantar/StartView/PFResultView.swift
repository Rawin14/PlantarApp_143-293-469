//
//  PFResultView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 19/11/2568 BE.
//

import SwiftUI
import SceneKit // 1. เพิ่ม import SceneKit

struct PFResultView: View {
    let scanId: String
    
    @State private var scanResult: FootScanResult?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    // เพิ่ม State สำหรับไปหน้า Home
    @State private var navigateToHome = false
    
    var body: some View {
        ZStack {
            Color(red: 247/255, green: 246/255, blue: 236/255)
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading results...")
            } else if let error = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text(error)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else if let result = scanResult {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Header
                        Text("ผลการประเมิน")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        Text("อาการรองช้ำ (Plantar Fasciitis)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // 2. แสดงโมเดล 3D (ถ้ามี URL)
//                        if let modelUrlString = result.model_3d_url, let url = URL(string: modelUrlString) {
//                            VStack {
//                                Text("3D Foot Model")
//                                    .font(.headline)
//                                    .foregroundColor(.secondary)
//                                
//                                Foot3DView(modelUrl: url)
//                                    .frame(height: 300) // กำหนดความสูงของ view 3D
//                                    .background(Color.white)
//                                    .cornerRadius(15)
//                                    .shadow(radius: 5)
//                            }
//                            .padding(.horizontal)
//                        } else {
//                            // กรณีไม่มีโมเดล หรือกำลังโหลด
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(Color.gray.opacity(0.1))
//                                .frame(height: 200)
//                                .overlay(
//                                    VStack {
//                                        Image(systemName: "cube.transparent")
//                                            .font(.system(size: 50))
//                                            .foregroundColor(.gray)
//                                        Text("No 3D Model Available")
//                                            .font(.caption)
//                                            .foregroundColor(.gray)
//                                    }
//                                )
//                                .padding(.horizontal)
//                        }
//                        
                        // Severity Score
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                .frame(width: 180, height: 180) // ปรับขนาดลงเล็กน้อยเพื่อให้สมดุล
                            
                            Circle()
                                .trim(from: 0, to: (result.pf_score ?? 0) / 100)
                                .stroke(severityColor(result.pf_severity), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 180, height: 180)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1), value: result.pf_score)
                            
                            VStack(spacing: 8) {
                                Text("\(Int(result.pf_score ?? 0))")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(severityColor(result.pf_severity))
                                
                                Text(severityText(result.pf_severity))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical)
                        
                        // Arch Type
                        if let archType = result.arch_type {
                            InfoCard(
                                icon: "figure.walk",
                                title: "ประเภทโค้งเท้า",
                                value: archTypeText(archType),
                                color: .blue
                            )
                        }
                        
                        // Recommendations Section (เก็บไว้เฉพาะความเสี่ยงและคำแนะนำทั่วไป)
                        if let indicators = result.pf_indicators?.first {
                            
                            // Risk Factors
                            if !indicators.risk_factors.isEmpty {
                                RecommendationCard(
                                    icon: "exclamationmark.triangle.fill",
                                    title: "ปัจจัยเสี่ยง",
                                    items: indicators.risk_factors,
                                    color: .orange
                                )
                            }
                            
                            // Recommendations
                            if !indicators.recommendations.isEmpty {
                                RecommendationCard(
                                    icon: "lightbulb.fill",
                                    title: "คำแนะนำ",
                                    items: indicators.recommendations,
                                    color: .blue
                                )
                            }
                        }
                        
                        // 3. (ลบส่วน Exercise และ Shoe Recommendations ออกตามที่ขอ)
                        
                        Spacer(minLength: 20)
                        
                        // 4. ปุ่มไปหน้า HomeView
                        Button(action: {
                            navigateToHome = true
                        }) {
                            Text("เข้าสู่หน้าหลัก")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 94/255, green: 84/255, blue: 68/255)) // สีธีม
                                .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true) // ซ่อนปุ่ม Back เดิม
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView() // ไปหน้า HomeView
        }
        .task {
            await loadScanResult()
        }
    }
    
    func loadScanResult() async {
        // ... (Code เดิม) ...
        do {
            let response: [FootScanResult] = try await UserProfile.supabase
                .from("foot_scans")
                .select("""
                        *,
                        pf_indicators (*),
                        exercise_recommendations (*),
                        shoe_recommendations (*)
                    """)
                .eq("id", value: scanId)
                .execute()
                .value
            
            if let result = response.first {
                scanResult = result
            } else {
                errorMessage = "Scan not found"
            }
            
        } catch {
            errorMessage = "Failed to load results: \(error.localizedDescription)"
        }
        
        isLoading = false
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

// ... (Supporting Views: InfoCard, RecommendationCard คงเดิม) ...
// (ExerciseCard และ ShoeRecommendationCard ลบออกได้ถ้าไม่ได้ใช้ที่อื่น หรือปล่อยไว้ก็ได้แต่ไม่ได้เรียกใช้)

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct RecommendationCard: View {
    let icon: String
    let title: String
    let items: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }
            
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(color)
                        .padding(.top, 6)
                    
                    Text(item)
                        .font(.body)
                }
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
