//
//  PFResultView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 19/11/2568 BE.
//

import SwiftUI

struct PFResultView: View {
    let scanId: String
    
    @State private var scanResult: FootScanResult?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
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
                        
                        Text("อาการรองช้ำ (Plantar Fasciitis)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Severity Score
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .trim(from: 0, to: (result.pf_score ?? 0) / 100)
                                .stroke(severityColor(result.pf_severity), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1), value: result.pf_score)
                            
                            VStack(spacing: 8) {
                                Text("\(Int(result.pf_score ?? 0))")
                                    .font(.system(size: 60, weight: .bold))
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
                        
                        // Recommendations Section
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
                        
                        // Exercise Recommendations
                        if let exercises = result.exercise_recommendations,
                           !exercises.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("แบบฝึกหัดที่แนะนำ")
                                    .font(.headline)
                                
                                ForEach(exercises.prefix(3), id: \.id) { exercise in
                                    ExerciseCard(exercise: exercise)
                                }
                            }
                        }
                        
                        // Shoe Recommendations
                        if let shoes = result.shoe_recommendations,
                           !shoes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("รองเท้าที่แนะนำ")
                                    .font(.headline)
                                
                                ForEach(shoes.prefix(3), id: \.id) { shoe in
                                    ShoeRecommendationCard(shoe: shoe)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("ผลการประเมิน")
        .task {
            await loadScanResult()
        }
    }
    
    // MARK: - Load Scan Result
    
    func loadScanResult() async {
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
    
    // Helper Functions
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

// MARK: - Supporting Views

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

struct ExerciseCard: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 50, height: 50)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exercise_name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(exercise.recommended_frequency)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct ShoeRecommendationCard: View {
    let shoe: ShoeRecommendation
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: shoe.image_url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 80, height: 80)
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shoe.shoe_name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(shoe.brand)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label("\(Int(shoe.match_score))%", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Label(shoe.size_recommendation, systemImage: "ruler")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if let price = shoe.price {
                    Text("฿\(Int(price))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
            }
            
            Spacer()
            
            VStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(Int(shoe.pf_support_score))")
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
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
