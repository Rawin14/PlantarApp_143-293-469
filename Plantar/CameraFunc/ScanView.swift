//
//  ScanView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI
import Storage
import PhotosUI // ✅ 1. เพิ่ม import PhotosUI

// State ของหน้าจอ
enum ScanState {
    case idle
    case uploading
    case processing
    case completed
    case failed
}

struct ScanView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    
    // Navigation & State
    @State private var navigateToCamera = false
    @State private var navigateToResult = false
    @State private var scanId: String?
    @State private var scanState: ScanState = .idle
    @State private var uploadProgress: Double = 0.0
    @State private var errorMessage: String?
    
    // ✅ 2. เพิ่ม State สำหรับเก็บรูปที่เลือกจากอัลบั้ม
    @State private var selectedItem: PhotosPickerItem? = nil
    
    // UI Colors
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - ส่วนแสดงผลตามสถานะ (State Handling)
                switch scanState {
                    
                    // ---------------------------------------------------------
                    // 1. กำลังอัปโหลด
                    // ---------------------------------------------------------
                case .uploading:
                    VStack(spacing: 20) {
                        Spacer()
                        Text("Uploading...")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("กำลังอัปโหลดรูปภาพรอยเท้า")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: uploadProgress)
                            .padding(.horizontal, 40)
                        
                        Text("\(Int(uploadProgress * 100))%")
                            .font(.title)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    
                    // ---------------------------------------------------------
                    // 2. กำลังประมวลผล (AI Analyzing)
                    // ---------------------------------------------------------
                case .processing:
                    VStack(spacing: 20) {
                        Spacer()
                        ProgressView()
                            .scaleEffect(2)
                            .padding()
                        
                        Text("Processing...")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("ระบบกำลังวิเคราะห์รอยเท้าเปียก\nคำนวณค่า Arch Index...")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    
                    // ---------------------------------------------------------
                    // 3. เสร็จสิ้น
                    // ---------------------------------------------------------
                case .completed:
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.green)
                        
                        Text("Analysis Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("การวิเคราะห์เสร็จสมบูรณ์")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            navigateToResult = true
                        }) {
                            Text("ดูผลลัพธ์")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 94/255, green: 84/255, blue: 68/255))
                                .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            resetState()
                        }) {
                            Text("สแกนใหม่")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom)
                    }
                    
                    // ---------------------------------------------------------
                    // 4. เกิดข้อผิดพลาด
                    // ---------------------------------------------------------
                case .failed:
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.red)
                        
                        Text("Analysis Failed")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            resetState()
                        }) {
                            Text("ลองใหม่อีกครั้ง")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.black)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    
                    // ---------------------------------------------------------
                    // 5. หน้าเริ่มต้น (คำแนะนำ Wet Test)
                    // ---------------------------------------------------------
                default: // .idle
                    VStack {
                        // Header: ปุ่มย้อนกลับ
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "arrow.left")
                                    .font(.title2.weight(.medium))
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Wet Footprint Test")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 94/255, green: 84/255, blue: 68/255))
                                
                                Text("วิธีการทดสอบรอยเท้าเปียกเพื่อวิเคราะห์ลักษณะอุ้งเท้า")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                // กรอบคำแนะนำ
                                VStack(alignment: .leading, spacing: 16) {
                                    InstructionRow(icon: "drop.fill", text: "1. นำฝ่าเท้าไปชุบน้ำให้เปียกพอหมาดๆ")
                                    Divider()
                                    InstructionRow(icon: "doc.fill", text: "2. เหยียบลงบนกระดาษขาว หรือถุงกระดาษสีน้ำตาล ให้เกิดรอยชัดเจน")
                                    Divider()
                                    InstructionRow(icon: "camera.viewfinder", text: "3. ยกเท้าออก แล้วกดปุ่มถ่ายภาพรอยเท้าที่ปรากฏ")
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.05), radius: 5)
                                
                                // ตัวอย่างภาพ (Guide)
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [5]))
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white.opacity(0.5))
                                    
                                    VStack {
                                        Image(systemName: "shoe.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray.opacity(0.5))
                                        Text("ตัวอย่าง: รอยเท้าบนกระดาษ")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        
                        // ปุ่มเริ่มถ่ายภาพ
                        Button(action: {
                            navigateToCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("เริ่มถ่ายภาพ")
                            }
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 94/255, green: 84/255, blue: 68/255))
                            .clipShape(Capsule())
                            .shadow(radius: 3)
                        }
                        .padding(.top, 10)
                        
                        // ✅ 3. ปุ่มเลือกรูปจากอัลบั้ม
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("เลือกจากอัลบั้ม")
                            }
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 94/255, green: 84/255, blue: 68/255))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color(red: 94/255, green: 84/255, blue: 68/255), lineWidth: 2)
                            )
                            .shadow(radius: 3)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        // ไปหน้ากล้อง
        .navigationDestination(isPresented: $navigateToCamera) {
            CameraCaptureView(
                onComplete: { images in
                    // เมื่อถ่ายรูปเสร็จ ให้เริ่มกระบวนการ upload & process
                    Task {
                        await uploadAndProcess(images: images)
                    }
                }
            )
        }
        // ไปหน้าผลลัพธ์
        .navigationDestination(isPresented: $navigateToResult) {
            if let scanId = scanId {
                PFResultView(scanId: scanId)
            }
        }
        // Alert Error
        .alert("เกิดข้อผิดพลาด", isPresented: .constant(errorMessage != nil)) {
            Button("ตกลง") {
                resetState()
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
        // ✅ 4. Logic เมื่อเลือกรูปเสร็จ
        .onChange(of: selectedItem) { newItem in
            Task {
                if let newItem = newItem,
                   let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    // ส่งรูปที่เลือกเข้าสู่กระบวนการวิเคราะห์
                    await uploadAndProcess(images: [image])
                }
                selectedItem = nil // รีเซ็ตค่าเพื่อเลือกรอบหน้าได้ใหม่
            }
        }
    }
    
    // MARK: - Logic Functions
    
    func resetState() {
        errorMessage = nil
        scanState = .idle
        scanId = nil
        uploadProgress = 0.0
    }
    
    // ฟังก์ชันหลักในการจัดการ Upload -> Record -> ML -> Result
    func uploadAndProcess(images: [UIImage]) async {
        scanState = .uploading
        uploadProgress = 0.0
        
        do {
            // 1. อัปโหลดรูป (รอยเท้า) ไป Supabase Storage
            let imageUrls = try await uploadImagesToSupabase(images: images)
            
            uploadProgress = 0.5
            
            // 2. สร้าง Record ในตาราง foot_scans
            let scanId = try await createScanRecord(imageUrls: imageUrls)
            self.scanId = scanId
            
            uploadProgress = 1.0
            
            // 3. ยิง Request ไป ML Service ให้วิเคราะห์
            scanState = .processing
            
            try await triggerMLProcessing(scanId: scanId, imageUrls: imageUrls)
            
            // 4. รอผลลัพธ์ (Polling)
            try await waitForResults(scanId: scanId)
            
            // 5. สำเร็จ
            scanState = .completed
            
        } catch {
            errorMessage = "การประมวลผลล้มเหลว: \(error.localizedDescription)"
            scanState = .failed
            print("❌ Error: \(error)")
        }
    }
    
    // อัปโหลดรูปภาพ
    func uploadImagesToSupabase(images: [UIImage]) async throws -> [String] {
        let session = try await UserProfile.supabase.auth.session
        let userId = session.user.id.uuidString
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var imageUrls: [String] = []
        
        for (index, image) in images.enumerated() {
            // ลดขนาดรูปเพื่อความรวดเร็ว
            guard let data = image.jpegData(compressionQuality: 0.6) else { continue }
            
            let fileName = "\(userId)/\(timestamp)/\(index).jpg"
            
            // Upload
            try await UserProfile.supabase.storage
                .from("foot-scan")
                .upload(
                    fileName,
                    data: data,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            // Get Public URL
            let url = try UserProfile.supabase.storage
                .from("foot-scan")
                .getPublicURL(path: fileName)
            
            imageUrls.append(url.absoluteString)
            
            // Update Progress
            uploadProgress = 0.5 * Double(index + 1) / Double(images.count)
        }
        
        print("✅ Uploaded \(imageUrls.count) images")
        return imageUrls
    }
    
    // สร้าง Record ใน Database
    func createScanRecord(imageUrls: [String]) async throws -> String {
        // Struct สำหรับ Insert
        struct ScanInsert: Encodable {
            let user_id: String // Supabase จะ Gen ID ให้เอง หรือถ้าจะ Gen เองก็ใส่ id ไปด้วย
            let foot_side: String
            let images_url: [String]
            let status: String
        }
        
        let session = try await UserProfile.supabase.auth.session
        
        let scanData = ScanInsert(
            user_id: session.user.id.uuidString,
            foot_side: "right", // ค่า Default หรือให้ user เลือกก่อนหน้านี้
            images_url: imageUrls,
            status: "processing"
        )
        
        // Insert และ Return ข้อมูลที่เพิ่งสร้าง (เพื่อเอา ID)
        let response: [FootScanResult] = try await UserProfile.supabase
            .from("foot_scans")
            .insert(scanData)
            .select() // สำคัญ: ต้อง Select เพื่อให้ได้ ID กลับมา
            .execute()
            .value
        
        guard let createdScan = response.first else {
            throw NSError(domain: "Database", code: -1, userInfo: [NSLocalizedDescriptionKey: "ไม่ได้รับ Scan ID กลับมา"])
        }
        
        print("✅ Scan record created: \(createdScan.id)")
        return createdScan.id
    }
    
    // เรียก ML Service
    func triggerMLProcessing(scanId: String, imageUrls: [String]) async throws {
        // ตรวจสอบ URL Config ให้ถูกต้อง
        guard let url = URL(string: "\(AppConfig.mlServiceURL)/process") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "scan_id": scanId,
            "image_urls": imageUrls,
            "questionnaire_score": userProfile.evaluateScore,
            "bmi_score": userProfile.bmiScore // เพิ่มบรรทัดนี้ (ค่า 1, 2, หรือ 3)
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        print("✅ ML processing triggered")
    }
    
    // รอผลลัพธ์ (Polling)
    func waitForResults(scanId: String) async throws {
        let maxAttempts = 30 // รอสูงสุด 60 วินาที (2 วิ * 30 ครั้ง)
        
        for attempt in 0..<maxAttempts {
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 วินาที
            
            print("⏳ Checking status... (\(attempt + 1)/\(maxAttempts))")
            
            // ดึงสถานะล่าสุด
            struct ScanStatus: Codable {
                let status: String
                let error_message: String?
            }
            
            let response: [ScanStatus] = try await UserProfile.supabase
                .from("foot_scans")
                .select("status, error_message")
                .eq("id", value: scanId)
                .execute()
                .value
            
            guard let scan = response.first else { continue }
            
            if scan.status == "completed" {
                print("✅ Processing completed!")
                return
            } else if scan.status == "failed" {
                throw NSError(domain: "Scan", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: scan.error_message ?? "การวิเคราะห์ล้มเหลวโดยไม่ทราบสาเหตุ"
                ])
            }
        }
        
        throw NSError(domain: "Scan", code: -2, userInfo: [NSLocalizedDescriptionKey: "หมดเวลาการเชื่อมต่อ (Timeout)"])
    }
}

// Helper Component สำหรับแถวคำแนะนำ
struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(red: 172/255, green: 187/255, blue: 98/255)) // สีเขียว Accent
                .frame(width: 30)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

// Preview
#Preview {
    ScanView()
        .environmentObject(UserProfile())
}
