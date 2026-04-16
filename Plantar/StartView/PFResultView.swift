//
//  PFResultView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 19/11/2568 BE.
//

//
//import SwiftUI
//import SceneKit
//import Supabase
//
//struct PFResultView: View {
//
//    // MARK: - Properties
//    let scanId: String
//
//    @EnvironmentObject var userProfile: UserProfile
//    @AppStorage("isProfileSetupCompleted") var isProfileSetupCompleted: Bool = false
//
//    // Navigation State
//    @State private var navigateToHome = false
//
//    // Data States
//    @State private var scanResult: FootScanResult?
//    @State private var isLoading = true
//    @State private var errorMessage: String?
//
//    // Image Enhancement State (สำหรับปรับรูปขาวดำ)
//    @State private var isEnhancedMode: Bool = true
//
//    // MARK: - Init (รองรับ Preview Mock Data)
//    init(scanId: String, mockResult: FootScanResult? = nil) {
//        self.scanId = scanId
//
//        if let result = mockResult {
//            _scanResult = State(initialValue: result)
//            _isLoading = State(initialValue: false)
//        }
//    }
//
//    // MARK: - Body
//    var body: some View {
//        ZStack {
//            // Background
//            Color(red: 247/255, green: 246/255, blue: 236/255).ignoresSafeArea()
//
//            if isLoading {
//                VStack(spacing: 20) {
//                    ProgressView()
//                        .scaleEffect(1.5)
//                    Text("กำลังประมวลผลและวิเคราะห์...")
//                        .font(.headline)
//                        .foregroundColor(.gray)
//                }
//            } else if let result = scanResult {
//                ScrollView {
//                    VStack(spacing: 24) {
//
//                        // 1. Header
//                        Text("ผลการวิเคราะห์")
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                            .padding(.top, 20)
//                            .foregroundColor(Color(hex: "50463C"))
//
//                        // 2. ส่วนแสดงรูปภาพ (Image) หรือ 3D Model
//                        displayScanVisuals(result: result)
//
//                        // 3. ส่วนแสดงคะแนนความเสี่ยง (Total Risk Score)
//                        riskScoreSection
//
//                        // 4. ส่วนแสดงรายละเอียดคะแนนย่อย (Score Details)
//                        scoreDetailsSection
//
//                        // 5. ข้อมูลลักษณะเท้า (Arch Type)
//                        archTypeSection(result: result)
//
//                        // 6. ปุ่มกลับหน้าหลัก
//                        homeButton
//                    }
//                    .padding(.bottom, 40)
//                }
//            } else if let error = errorMessage {
//                // Error View
//                VStack(spacing: 16) {
//                    Image(systemName: "exclamationmark.triangle")
//                        .font(.largeTitle)
//                        .foregroundColor(.red)
//                    Text("เกิดข้อผิดพลาด")
//                        .font(.headline)
//                    Text(error)
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                    Button("ลองใหม่") {
//                        Task { await loadScanResult() }
//                    }
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//        .navigationDestination(isPresented: $navigateToHome) {
//            HomeView()
//        }
//        .task {
//            if scanResult == nil {
//                await loadScanResult()
//            }
//            await markUserAsScanned()
//        }
//    }
//
//    // MARK: - Subviews
//
//    // ส่วนแสดงผลภาพและ 3D
//    @ViewBuilder
//    func displayScanVisuals(result: FootScanResult) -> some View {
//        VStack(spacing: 16) {
//
//            // A. แสดงรูปภาพ 2D (ถ้ามี URL)
//            // เช็คว่ามีรูปใน Array images_url อย่างน้อย 1 รูป หรือใช้ image_url แบบเดี่ยว (ถ้า API เปลี่ยน)
//            if let firstImage = result.images_url.first, let url = URL(string: firstImage) {
//                VStack(spacing: 10) {
//                    HStack {
//                        Image(systemName: "photo")
//                            .foregroundColor(.gray)
//                        Text("ภาพสแกน")
//                            .font(.headline)
//                            .foregroundColor(.gray)
//                        Spacer()
//                    }
//                    .padding(.horizontal)
//
//                    AsyncImage(url: url) { phase in
//                        switch phase {
//                        case .empty:
//                            Rectangle().fill(Color.gray.opacity(0.1)).frame(height: 250)
//                                .overlay(ProgressView())
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .scaledToFit()
//                                .frame(maxHeight: 300)
//                                .cornerRadius(12)
//                                // 🔥 Effect ปรับขาวดำ/Contrast
//                                .saturation(isEnhancedMode ? 0 : 1)
//                                .contrast(isEnhancedMode ? 2.0 : 1)
//                                .shadow(radius: 3)
//                        case .failure:
//                            Rectangle().fill(Color.gray.opacity(0.1)).frame(height: 250)
//                                .overlay(Image(systemName: "photo.badge.exclamationmark"))
//                        @unknown default:
//                            EmptyView()
//                        }
//                    }
//                    .padding(.horizontal)
//
//                    // Toggle Switch
//                    Toggle(isOn: $isEnhancedMode) {
//                        Text("เน้นรอยเท้า (ขาว-ดำ)")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    }
//                    .padding(.horizontal, 30)
//                }
//            }
//
//            // B. แสดง 3D Model (ถ้ามี)
//            if let modelUrlStr = result.model_3d_url, let modelUrl = URL(string: modelUrlStr) {
//                VStack(spacing: 10) {
//                    HStack {
//                        Image(systemName: "cube.transparent")
//                            .foregroundColor(.blue)
//                        Text("แบบจำลอง 3 มิติ")
//                            .font(.headline)
//                            .foregroundColor(.gray)
//                        Spacer()
//                    }
//                    .padding(.horizontal)
//
//                    Foot3DView(modelUrl: modelUrl)
//                        .frame(height: 250)
//                        .background(Color.gray.opacity(0.05))
//                        .cornerRadius(12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                        )
//                        .padding(.horizontal)
//                }
//            }
//        }
//    }
//
//    // ส่วนแสดงวงกลมคะแนน
//    var riskScoreSection: some View {
//        ZStack {
//            Circle()
//                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
//                .frame(width: 180, height: 180)
//
//            // วงกลมคะแนน (คำนวณ % จากคะแนนเต็มประมาณ 23)
//            Circle()
//                .trim(from: 0, to: userProfile.totalRiskScore / 23.0)
//                .stroke(riskColor(userProfile.riskSeverity), style: StrokeStyle(lineWidth: 20, lineCap: .round))
//                .frame(width: 180, height: 180)
//                .rotationEffect(.degrees(-90))
//
//            VStack(spacing: 4) {
//                Text("\(Int(userProfile.totalRiskScore))")
//                    .font(.system(size: 60, weight: .bold))
//                    .foregroundColor(riskColor(userProfile.riskSeverity))
//
//                Text(userProfile.riskSeverity.capitalized) // Low/Medium/High
//                    .font(.headline)
//                    .fontWeight(.bold)
//                    .foregroundColor(.gray)
//            }
//        }
//        .padding(.vertical)
//    }
//
//    // ส่วนรายละเอียดคะแนน
//    var scoreDetailsSection: some View {
//        HStack(spacing: 15) {
//            // BMI Score
//            ScoreDetailCard(
//                title: "BMI Score",
//                score: "\(userProfile.bmiScore)",
//                max: "3",
//                color: .blue
//            )
//
//            // Evaluate Score
//            ScoreDetailCard(
//                title: "Evaluate",
//                score: "\(Int(userProfile.evaluateScore))",
//                max: "17",
//                color: riskColor(userProfile.riskSeverity)
//            )
//        }
//        .padding(.horizontal)
//    }
//
//    // ส่วนลักษณะเท้า
//    @ViewBuilder
//    func archTypeSection(result: FootScanResult) -> some View {
//        if let archType = result.arch_type {
//            VStack(alignment: .leading, spacing: 10) {
//                Text("ลักษณะรูปเท้า (จากการสแกน)")
//                    .font(.headline)
//                    .foregroundColor(Color(hex: "50463C"))
//                    .padding(.horizontal)
//
//                InfoCard(
//                    icon: "figure.walk",
//                    title: "ประเภทโค้งเท้า",
//                    value: archTypeText(archType),
//                    color: Color(hex: "50463C")
//                )
//                .padding(.horizontal)
//
//                RecommendationCard(
//                    icon: "exclamationmark.triangle",
//                    title: "คำเตือน: ผลการวิเคราะห์ที่เห็นเป็นเพียงแค่การวินิจฉัยรอยเท้าเบื้องต้นเท่านั้น โปรดปรึกษาแพทย์เพื่อการรักษาที่ถูกต้อง",
//                    color: .red
//                )
//                .padding(.horizontal)
//            }
//        }
//    }
//
//    // ปุ่มกลับ
//    var homeButton: some View {
//        Button(action: {
//            isProfileSetupCompleted = true
//            navigateToHome = true
//        }) {
//            Text("เข้าสู่หน้าหลัก")
//                .font(.headline)
//                .fontWeight(.bold)
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color(red: 94/255, green: 84/255, blue: 68/255))
//                .cornerRadius(15)
//        }
//        .padding(.horizontal)
//    }
//
//    // MARK: - Functions
//
//    func loadScanResult() async {
//        isLoading = true
//        errorMessage = nil
//
//        do {
//            // ดึงข้อมูลจาก Table 'foot_scans'
//            let response: [FootScanResult] = try await UserProfile.supabase
//                .from("foot_scans")
//                .select("*")
//                .eq("id", value: scanId)
//                .execute()
//                .value
//
//            if let result = response.first {
//                await MainActor.run {
//                    self.scanResult = result
//                }
//            } else {
//                errorMessage = "ไม่พบข้อมูลการสแกน"
//            }
//        } catch {
//            print("Error: \(error)")
//            errorMessage = "โหลดข้อมูลไม่สำเร็จ: \(error.localizedDescription)"
//        }
//
//        await MainActor.run {
//            isLoading = false
//        }
//    }
//
//    // Helper Functions
//        func archTypeText(_ type: String) -> String {
//            switch type.lowercased() {
//            // กรณีเท้าแบน (รับทั้ง flat และ flat_foot)
//            case "flat", "flat_foot":
//                return "เท้าแบน (Flat Foot)"
//
//            // กรณีอุ้งเท้าสูง (รับทั้ง high และ high_arch)
//            case "high", "high_arch":
//                return "อุ้งเท้าสูง (High Arch)"
//
//            // กรณีอุ้งเท้าสูงมาก (เพิ่มใหม่)
//            case "severe_high_arch":
//                return "อุ้งเท้าสูงมาก (Severe High Arch)"
//
//            // กรณีเท้าปกติ
//            case "normal":
//                return "เท้าปกติ (Normal)"
//
//            // กรณีอื่นๆ
//            default:
//                return type.capitalized
//            }
//        }
//
//    func riskColor(_ severity: String) -> Color {
//        switch severity.lowercased() {
//        case "low": return .green
//        case "medium": return .orange
//        case "high": return .red
//        default: return .gray
//        }
//    }
//
//    func markUserAsScanned() async {
//            let userId = userProfile.userId
//
//            do {
//                // อัปเดตตาราง profiles
//                try await UserProfile.supabase
//                    .from("profiles")
//                    .update(["has_completed_scan": true])
//                    .eq("id", value: userId)
//                    .execute()
//
//                print("✅ Updated user scan status to TRUE")
//
//                // อัปเดตค่าใน Local State ด้วย เพื่อให้ AuthManager รู้ทันที
//                // (ถ้า userProfile มีตัวแปร profileData ให้แก้ตรงนั้นด้วย)
//                // userProfile.profileData?.hasCompletedScan = true
//
//            } catch {
//                print("⚠️ Failed to update scan status: \(error)")
//            }
//        }
//}
//
//// MARK: - 3D View Helper
//struct Foot3DView: UIViewRepresentable {
//    let modelUrl: URL
//
//    func makeUIView(context: Context) -> SCNView {
//        let scnView = SCNView()
//        scnView.backgroundColor = UIColor.clear
//        scnView.allowsCameraControl = true
//        scnView.autoenablesDefaultLighting = true
//        return scnView
//    }
//
//    func updateUIView(_ uiView: SCNView, context: Context) {
//        // ใช้ Thread Background โหลดเพื่อไม่ให้ UI กระตุก
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                // หมายเหตุ: การโหลดไฟล์ .scn/.usdz จาก URL ตรงๆ อาจมีข้อจำกัดเรื่อง ATS หรือ Format
//                // ถ้าใช้จริงอาจต้อง Download file ลงเครื่องก่อนแล้วค่อย Load path
//                let scene = try SCNScene(url: modelUrl, options: nil)
//                DispatchQueue.main.async {
//                    uiView.scene = scene
//                }
//            } catch {
//                print("⚠️ Error loading 3D model: \(error)")
//            }
//        }
//    }
//}
//
//// MARK: - Component Views
//
//struct ScoreDetailCard: View {
//    let title: String
//    let score: String
//    let max: String
//    let color: Color
//
//    var body: some View {
//        VStack {
//            Text(title)
//                .font(.caption)
//                .foregroundColor(.secondary)
//
//            HStack(alignment: .lastTextBaseline, spacing: 2) {
//                Text(score)
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundColor(color)
//                Text("/\(max)")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.05), radius: 5)
//    }
//}
//
//struct InfoCard: View {
//    let icon: String
//    let title: String
//    let value: String
//    let color: Color
//
//    var body: some View {
//        HStack(spacing: 15) {
//            Image(systemName: icon)
//                .font(.title2)
//                .foregroundColor(color)
//                .frame(width: 40, height: 40)
//                .background(Color.white)
//                .clipShape(Circle())
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(title)
//                    .font(.caption)
//                    .fontWeight(.semibold)
//                    .foregroundColor(color.opacity(0.8))
//
//                Text(value)
//                    .font(.headline)
//                    .fontWeight(.bold)
//                    .foregroundColor(color)
//            }
//            Spacer()
//        }
//        .padding()
//        .background(color.opacity(0.1))
//        .cornerRadius(16)
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(color.opacity(0.2), lineWidth: 1)
//        )
//    }
//}
//
//struct RecommendationCard: View {
//    let icon: String
//    let title: String
//    let color: Color
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            Image(systemName: icon)
//                .font(.title3)
//                .foregroundColor(color)
//                .padding(.top, 2)
//
//            Text(title)
//                .font(.subheadline)
//                .foregroundColor(Color(hex: "50463C"))
//                .fixedSize(horizontal: false, vertical: true)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(color.opacity(0.1))
//        .cornerRadius(15)
//    }
//}
//
//// MARK: - Models
//// (ต้องตรงกับ Database Table 'foot_scans')
//
//struct FootScanResult: Codable {
//    let id: String
//    let user_id: String
//    let foot_side: String?
//    let images_url: [String] // เป็น Array
//    let model_3d_url: String?
//    let pf_severity: String?
//    let pf_score: Double?
//    let arch_type: String?
//    let status: String?
//    // ถ้าไม่มีฟิลด์เหล่านี้ใน Table ให้ทำเป็น Optional หรือลบออก
//    let error_message: String?
//    let pf_indicators: [PFIndicator]?
//    let exercise_recommendations: [Exercise]?
//    let shoe_recommendations: [ShoeRecommendation]?
//}
//
//// Model ย่อยๆ (ถ้า JSON เก็บเป็น Object/Array)
//struct PFIndicator: Codable {
//    let id: String?
//    // ใส่ field อื่นๆ ตาม JSON ที่ตอบกลับ
//}
//
//struct Exercise: Codable {
//    let id: String?
//    let exercise_name: String?
//}
//
//struct ShoeRecommendation: Codable {
//    let id: String?
//    let shoe_name: String?
//}
//
//
//// MARK: - Preview
//
//#Preview {
//    // 1. Mock Data
//    let mockResult = FootScanResult(
//        id: "preview_id",
//        user_id: "user_preview",
//        foot_side: "left",
//        images_url: ["https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/foot-scan/EAEA5D8F-D894-4F9F-9BF0-D52D2DEBDB7F/1767378656/0.jpg"], // รูปตัวอย่าง
//        model_3d_url: nil,
//        pf_severity: "medium",
//        pf_score: 85.5,
//        arch_type: "flat",
//        status: "completed",
//        error_message: nil,
//        pf_indicators: [],
//        exercise_recommendations: [],
//        shoe_recommendations: []
//    )
//
//    let mockProfile = UserProfile()
//    mockProfile.evaluateScore = 12
//    mockProfile.height = 175
//    mockProfile.weight = 75 // BMI ~24 (Score 1) -> Total Risk ~13 (Medium)
//
//    return NavigationStack {
//        PFResultView(scanId: "test_id", mockResult: mockResult)
//            .environmentObject(mockProfile)
//    }
//}



import SwiftUI
import SceneKit
import Supabase

struct PFResultView: View {
    
    // MARK: - Properties
    let scanId: String
    
    @EnvironmentObject var userProfile: UserProfile
    @AppStorage("isProfileSetupCompleted") var isProfileSetupCompleted: Bool = false
    
    // Navigation State
    @State private var navigateToHome = false
    
    // Data States
    @State private var scanResult: FootScanResult?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    // Image Enhancement State
    @State private var isEnhancedMode: Bool = false
    @State private var showUnknownAlert = false
    
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode // เพิ่มการนำเข้าการนำเสนอ
    
    // MARK: - Init
    init(scanId: String, mockResult: FootScanResult? = nil) {
        self.scanId = scanId
        
        if let result = mockResult {
            _scanResult = State(initialValue: result)
            _isLoading = State(initialValue: false)
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color(red: 247/255, green: 246/255, blue: 236/255).ignoresSafeArea()
            
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("กำลังประมวลผลและวิเคราะห์...")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            } else if let result = scanResult {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // 1. Header
                        Text("ผลการวิเคราะห์")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                            .foregroundColor(Color(hex: "50463C"))
                        
                        // 2. ส่วนแสดงรูปภาพ (Image) หรือ 3D Model
                        displayScanVisuals(result: result)
                        
                        // 3. ส่วนแสดงคะแนนความเสี่ยง (Total Risk Score)
                        riskScoreSection
                        
                        // 4. ส่วนแสดงรายละเอียดคะแนนย่อย (Score Details)
                        scoreDetailsSection
                        
                        // 5. ข้อมูลลักษณะเท้า (Arch Type)
                        archTypeSection(result: result)
                        
                        // 6. ปุ่มกลับ
                        backButton // เพิ่มปุ่มกลับที่นี่
                        
                        // 7. ปุ่มเข้าสู่หน้าหลัก
                        homeButton
                    }
                    .padding(.bottom, 40)
                }
            } else if let error = errorMessage {
                // Error View
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("เกิดข้อผิดพลาด")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("ลองใหม่") {
                        Task { await loadScanResult() }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
        }
        .task {
            if scanResult == nil {
                await loadScanResult()
            }
            await markUserAsScanned()
        }
        // ✅ เพิ่ม Alert ดักรูปพังตรงนี้
        .alert("ไม่สามารถวิเคราะห์รอยเท้าได้", isPresented: $showUnknownAlert) {
            Button("สแกนใหม่", role: .cancel) {
                presentationMode.wrappedValue.dismiss() // เด้งกลับไปหน้ากล้อง
            }
        } message: {
            Text("ระบบตรวจไม่พบรอยเท้า หรือรูปภาพมืดเกินไป กรุณาถ่ายรอยเท้าใหม่อีกครั้งในที่ที่มีแสงสว่าง")
        }
    }
    
    // MARK: - Subviews
    
    // ส่วนแสดงผลภาพและ 3D
    @ViewBuilder
    func displayScanVisuals(result: FootScanResult) -> some View {
        VStack(spacing: 16) {
            // A. แสดงรูปภาพ 2D
            if let firstImage = result.images_url.first, let url = URL(string: firstImage) {
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                        Text("ภาพสแกน")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle().fill(Color.gray.opacity(0.1)).frame(height: 250)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                                .saturation(isEnhancedMode ? 0 : 1)
                                .contrast(isEnhancedMode ? 2.0 : 1)
                                .shadow(radius: 3)
                        case .failure:
                            Rectangle().fill(Color.gray.opacity(0.1)).frame(height: 250)
                                .overlay(Image(systemName: "photo.badge.exclamationmark"))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                    
                    Toggle(isOn: $isEnhancedMode) {
                        Text("เน้นรอยเท้า (ขาว-ดำ)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 30)
                }
            }
            
            // B. แสดง 3D Model
            if let modelUrlStr = result.model_3d_url, let modelUrl = URL(string: modelUrlStr) {
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "cube.transparent")
                            .foregroundColor(.blue)
                        Text("แบบจำลอง 3 มิติ")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Foot3DView(modelUrl: modelUrl)
                        .frame(height: 250)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                }
            }
        }
    }
    
    // ปุ่มกลับ
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss() // ปิดหน้าปัจจุบัน
        }) {
            Text("กลับ")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray)
                .cornerRadius(15)
        }
        .padding(.horizontal)
    }
    
    // ส่วนแสดงวงกลมคะแนน
    var riskScoreSection: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 180, height: 180)
            
            Circle()
                .trim(from: 0, to: userProfile.totalRiskScore / 23.0)
                .stroke(riskColor(userProfile.riskSeverity), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 4) {
                Text("\(Int(userProfile.totalRiskScore))")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(riskColor(userProfile.riskSeverity))
                
                Text(userProfile.riskSeverity.capitalized)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical)
    }
    
    // ส่วนรายละเอียดคะแนน
    var scoreDetailsSection: some View {
        HStack(spacing: 15) {
            ScoreDetailCard(
                title: "BMI Score",
                score: "\(userProfile.bmiScore)",
                max: "3",
                color: .blue
            )
            
            ScoreDetailCard(
                title: "Evaluate",
                score: "\(Int(userProfile.evaluateScore))",
                max: "17",
                color: riskColor(userProfile.riskSeverity)
            )
        }
        .padding(.horizontal)
    }
    
    // ส่วนลักษณะเท้า
    @ViewBuilder
    func archTypeSection(result: FootScanResult) -> some View {
        if let archType = result.arch_type {
            VStack(alignment: .leading, spacing: 10) {
                Text("ลักษณะรูปเท้า (จากการสแกน)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "50463C"))
                    .padding(.horizontal)
                
                InfoCard(
                    icon: "figure.walk",
                    title: "ประเภทโค้งเท้า",
                    value: archTypeText(archType),
                    color: Color(hex: "50463C")
                )
                .padding(.horizontal)
                
                RecommendationCard(
                    icon: "exclamationmark.triangle",
                    title: "คำเตือน: ผลการวิเคราะห์ที่เห็นเป็นเพียงแค่การวินิจฉัยรอยเท้าเบื้องต้นเท่านั้น โปรดปรึกษาแพทย์เพื่อการรักษาที่ถูกต้อง",
                    color: .red
                )
                .padding(.horizontal)
            }
        }
    }
    
    // ปุ่มเข้าสู่หน้าหลัก
    var homeButton: some View {
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
    }
    
    // MARK: - Functions
    
    func loadScanResult() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [FootScanResult] = try await UserProfile.supabase
                .from("foot_scans")
                .select("*")
                .eq("id", value: scanId)
                .execute()
                .value
            
            if let result = response.first {
                await MainActor.run {
                    // ✅ เช็คผลลัพธ์ ถ้าเป็น unknown ให้โชว์ Alert
                    if result.arch_type?.lowercased() == "unknown" {
                        self.showUnknownAlert = true
                    } else {
                        self.scanResult = result
                    }
                }
            } else {
                errorMessage = "ไม่พบข้อมูลการสแกน"
            }
        } catch {
            print("Error: \(error)")
            errorMessage = "โหลดข้อมูลไม่สำเร็จ: \(error.localizedDescription)"
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    // Helper Functions
    func archTypeText(_ type: String) -> String {
        switch type.lowercased() {
        case "flat", "flat_foot":
            return "เท้าแบน (Flat Foot)"
        case "high", "high_arch":
            return "อุ้งเท้าสูง (High Arch)"
        case "severe_high_arch":
            return "อุ้งเท้าสูงมาก (Severe High Arch)"
        case "normal":
            return "เท้าปกติ (Normal)"
        default:
            return type.capitalized
        }
    }
    
    func riskColor(_ severity: String) -> Color {
        switch severity.lowercased() {
        case "low": return .green
        case "medium": return .orange
        case "high": return .red
        default: return .gray
        }
    }
    
    func markUserAsScanned() async {
        let userId = userProfile.userId
        
        do {
            try await UserProfile.supabase
                .from("profiles")
                .update(["has_completed_scan": true])
                .eq("id", value: userId)
                .execute()
            
            print("✅ Updated user scan status to TRUE")
        } catch {
            print("⚠️ Failed to update scan status: \(error)")
        }
    }
}

// MARK: - 3D View Helper
struct Foot3DView: UIViewRepresentable {
    let modelUrl: URL
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = UIColor.clear
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let scene = try SCNScene(url: modelUrl, options: nil)
                DispatchQueue.main.async {
                    uiView.scene = scene
                }
            } catch {
                print("⚠️ Error loading 3D model: \(error)")
            }
        }
    }
}

// MARK: - Component Views

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
                .background(Color.white)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(color.opacity(0.8))
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct RecommendationCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .padding(.top, 2)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color(hex: "50463C"))
                .fixedSize(horizontal: false, vertical: true)
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
    let foot_side: String?
    let images_url: [String]
    let model_3d_url: String?
    let pf_severity: String?
    let arch_type: String?
    let status: String?
    let error_message: String?
    let pf_indicators: [PFIndicator]?
    let exercise_recommendations: [Exercise]?
    let shoe_recommendations: [ShoeRecommendation]?
}

struct PFIndicator: Codable {
    let id: String?
    // ใส่ field อื่นๆ ตาม JSON ที่ตอบกลับ
}

struct Exercise: Codable {
    let id: String?
    let exercise_name: String?
}

struct ShoeRecommendation: Codable {
    let id: String?
    let shoe_name: String?
}

// MARK: - Preview
#Preview {
    let mockResult = FootScanResult(
        id: "preview_id",
        user_id: "user_preview",
        foot_side: "left",
        images_url: ["https://wwdvyjvziujyaymwmrcr.supabase.co/storage/v1/object/public/foot-scan/EAEA5D8F-D894-4F9F-9BF0-D52D2DEBDB7F/1767378656/0.jpg"],
        model_3d_url: nil,
        pf_severity: "medium",
        arch_type: "flat",
        status: "completed",
        error_message: nil,
        pf_indicators: [],
        exercise_recommendations: [],
        shoe_recommendations: []
    )
    
    let mockProfile = UserProfile()
    mockProfile.evaluateScore = 12
    mockProfile.height = 175
    mockProfile.weight = 75
    
    return NavigationStack {
        PFResultView(scanId: "test_id", mockResult: mockResult)
            .environmentObject(mockProfile)
    }
}
