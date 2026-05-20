//
//  PFResultView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 19/11/2568 BE.
//


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
                            .foregroundColor(Color("50463C"))
                        
                        // 2. ส่วนแสดงรูปภาพ (Image)
                        displayScanVisuals(result: result)
                        
                        // 3. ส่วนแสดงคะแนนความเสี่ยง (Total Risk Score)
                        riskScoreSection
                        
                        // 4. ส่วนแสดงรายละเอียดคะแนนย่อย (Score Details)
                        scoreDetailsSection
                        
                        // 5. ข้อมูลลักษณะเท้า (Arch Type)
                        archTypeSection(result: result)
                        
                        // 6. ส่วนอ้างอิงและคำเตือนทางการแพทย์
                        medicalDisclaimerAndReferencesSection
                        
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
                // กรณีมีข้อมูลส่งมา (แสดงผลปกติ)
                VStack(alignment: .leading, spacing: 10) {
                    Text("ลักษณะรูปเท้า (จากการสแกน)")
                        .font(.headline)
                        // ✅ แก้ไข: ใช้สีแบบ RGB แทน ป้องกันปัญหาสีโปร่งใส
                        .foregroundColor(Color(red: 94/255, green: 84/255, blue: 68/255))
                        .padding(.horizontal)
                    
                    InfoCard(
                        icon: "shoeprints.fill", // เปลี่ยนไอคอนให้สื่อถึงรอยเท้ามากขึ้น (ตัวเลือกเสริม)
                        title: "ประเภทโค้งเท้า",
                        value: archTypeText(archType),
                        // ✅ แก้ไข: ใช้สีแบบ RGB แทน ป้องกันปัญหาสีโปร่งใส
                        color: Color(red: 94/255, green: 84/255, blue: 68/255)
                    )
                    .padding(.horizontal)
                }
            } else {
                // กรณีไม่มีข้อมูล (เพื่อไม่ให้ UI หายไป)
                VStack(alignment: .leading, spacing: 10) {
                    Text("ลักษณะรูปเท้า (จากการสแกน)")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    InfoCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "ประเภทโค้งเท้า",
                        value: "ไม่พบข้อมูล หรือกำลังประมวลผล",
                        color: .gray
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
    
    // MARK: - Medical Information Section
    private var medicalDisclaimerAndReferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
                .padding(.vertical, 8)
            
            // บัตรข้อความจัดกลุ่มความปลอดภัยและข้อมูลอ้างอิง
            VStack(alignment: .leading, spacing: 16) {
                
                // 1. Disclaimer
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .foregroundColor(.orange)
                            .font(.footnote)
                        Text("ข้อควรระวังทางการแพทย์ (Medical Disclaimer)")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Text("แอปพลิเคชันนี้ออกแบบมาเพื่อการประเมินความเสี่ยงเบื้องต้นเท่านั้น ไม่ใช่อุปกรณ์ทางการแพทย์และไม่สามารถแทนที่การวินิจฉัยจากแพทย์ได้ โปรดปรึกษาแพทย์ผู้เชี่ยวชาญก่อนเริ่มทำการรักษา")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
                }
                
                Divider()
                    .opacity(0.5)
                
                // 2. Advisors
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "stethoscope")
                            .foregroundColor(Color(red: 172/255, green: 187/255, blue: 98/255)) // สีเขียวธีมแอป Plantar
                            .font(.footnote)
                        Text("ที่ปรึกษาทางการแพทย์ (Medical Advisors)")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Text("นพ.สุรเมศวร์ ศิริจารุวงศ์, ผศ.ดร.ศรีรัฐ ภักดีรณชิต, ผศ.นพ.ชัชวาลย์ เจริญธรรมรักษา")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                        .multilineTextAlignment(.leading)
                }
                
                Divider()
                    .opacity(0.5)
                
                // 3. References (Links)
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.plaintext.fill")
                            .foregroundColor(.gray)
                            .font(.footnote)
                        Text("แหล่งข้อมูลอ้างอิง (References)")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        referenceLinkRow(number: "1", text: "Lucas et al. (2018). Automated spatial pattern analysis for foot arch height.", url: "https://pubmed.ncbi.nlm.nih.gov/30233395/")
                        
                        referenceLinkRow(number: "2", text: "Boob et al. (2024). Physiotherapy rehabilitation protocol of plantar fasciitis.", url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC10835201/")
                        
                        referenceLinkRow(number: "3", text: "วรพงษ์ คงทอง และปรารถนา เนมีย์. (2568). โรครองช้ำ: บทความทบทวน.", url: "https://he02.tci-thaijo.org/index.php/spsc_journal/article/view/273414/186865")
                    }
                }
            }
            .padding(16)
            .background(Color(.white)) // หรือปรับเป็นความต้องการ เช่น Color(.secondarySystemGroupedBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4) // ทำเงาฟุ้งละมุนๆ
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    // ฟังก์ชันตัวช่วยสร้างแถวลิงก์อ้างอิงให้มีไอคอนระบุการเปิดหน้าเว็บภายนอก
    @ViewBuilder
    private func referenceLinkRow(number: String, text: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(alignment: .top, spacing: 6) {
                Text("\(number).")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(text)
                    .font(.system(size: 11))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.leading)
                    .underline() // เพิ่มเส้นใต้เพื่อให้รู้ว่าเป็นข้อความคลิกได้
                
                Spacer()
                
                Image(systemName: "arrow.up.forward.app.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.blue)
                    .padding(.top, 2)
            }
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
                .foregroundColor(Color("50463C"))
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
