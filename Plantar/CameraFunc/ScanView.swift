//
// ScanView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//


import SwiftUI
import Storage

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
    
    @State private var currentPageIndex = 4
    @State private var navigateToCamera = false
    @State private var navigateToResult = false
    @State private var scanId: String?
    @State private var scanState: ScanState = .idle
    @State private var uploadProgress: Double = 0.0
    @State private var errorMessage: String?
    
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255)
    let selectedDotColor = Color(red: 188/255, green: 204/255, blue: 112/255)
    let unselectedDotColor = Color(red: 220/255, green: 220/255, blue: 220/255)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - สถานะต่างๆ
                
                switch scanState {
                    
                // MARK: - Uploading
                case .uploading:
                    VStack(spacing: 20) {
                        Text("Uploading...")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("กำลังอัปโหลดรูปภาพ")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: uploadProgress)
                            .padding(.vertical)
                        
                        Text("\(Int(uploadProgress * 100))%")
                            .font(.title)
                        
                        Spacer()
                    }
                    
                // MARK: - Processing
                case .processing:
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(2)
                            .padding()
                        
                        Text("Processing...")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("กำลังวิเคราะห์รูปเท้า\nโปรดรอ 30-60 วินาที")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    
                // MARK: - Completed
                case .completed:
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.green)
                        
                        Text("Analysis Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("การวิเคราะห์เสร็จสมบูรณ์")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            navigateToResult = true
                        }) {
                            Text("View Results")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.black)
                                .clipShape(Capsule())
                        }
                        
                        Button(action: {
                            scanState = .idle
                            scanId = nil
                        }) {
                            Text("Scan Again")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                // MARK: - Failed
                case .failed:
                    VStack(spacing: 20) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.red)
                        
                        Text("Analysis Failed")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            scanState = .idle
                            errorMessage = nil
                        }) {
                            Text("Try Again")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.black)
                                .clipShape(Capsule())
                        }
                    }
                    
                // MARK: - Idle (เริ่มต้น)
                default:
                    // Back Button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2.weight(.medium))
                            .foregroundColor(.black)
                            .padding(8)
                            .background(.white.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 16)
                    
                    // Title
                    Text("Scan your feet")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("ถ่ายรูปเท้าของคุณเพื่อประเมินอาการรองช้ำ")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.bottom, 24)
                    
                    // Camera Icon
                    HStack {
                        Spacer()
                        Image(systemName: "camera.fill.badge.ellipsis")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200)
                            .foregroundColor(.black.opacity(0.8))
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Start Capture Button
                    Button(action: {
                        navigateToCamera = true
                    }) {
                        Text("Start Capture")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.black)
                            .clipShape(Capsule())
                    }
                    
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .fill(index == currentPageIndex ? selectedDotColor : unselectedDotColor)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToCamera) {
            CameraCaptureView(
                onComplete: { images in
                    // เมื่อถ่ายรูปเสร็จ
                    Task {
                        await uploadAndProcess(images: images)
                    }
                }
            )
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let scanId = scanId {
                PFResultView(scanId: scanId)
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
                scanState = .idle
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - Upload and Process
    
    func uploadAndProcess(images: [UIImage]) async {
        scanState = .uploading
        uploadProgress = 0.0
        
        do {
            // 1. Upload images to Supabase Storage
            let imageUrls = try await uploadImagesToSupabase(images: images)
            
            uploadProgress = 0.5
            
            // 2. Create scan record
            let scanId = try await createScanRecord(imageUrls: imageUrls)
            self.scanId = scanId
            
            uploadProgress = 1.0
            
            // 3. Trigger ML processing
            scanState = .processing
            
            try await triggerMLProcessing(scanId: scanId, imageUrls: imageUrls)
            
            // 4. Wait for results
            try await waitForResults(scanId: scanId)
            
            // 5. Success
            scanState = .completed
            
        } catch {
            errorMessage = "Processing failed: \(error.localizedDescription)"
            scanState = .failed
            print("❌ Error: \(error)")
        }
    }
    
    // MARK: - Upload Images
    
    func uploadImagesToSupabase(images: [UIImage]) async throws -> [String] {
        let session = try await UserProfile.supabase.auth.session
        let userId = session.user.id.uuidString
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var imageUrls: [String] = []
        
        for (index, image) in images.enumerated() {
            guard let data = image.jpegData(compressionQuality: 0.8) else { continue }
            
            let fileName = "\(userId)/\(timestamp)/\(index).jpg"
            
            // Upload to Supabase Storage
            try await UserProfile.supabase.storage
                .from("foot-scan")
                .upload(
                    fileName,
                    data: data,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            // Get public URL
            let url = try UserProfile.supabase.storage
                .from("foot-scan")
                .getPublicURL(path: fileName)
            
            imageUrls.append(url.absoluteString)
            
            // Update progress
            uploadProgress = 0.5 * Double(index + 1) / Double(images.count)
        }
        
        print("✅ Uploaded \(imageUrls.count) images")
        return imageUrls
    }
    
    // MARK: - Create Scan Record
    
    func createScanRecord(imageUrls: [String]) async throws -> String {
        struct ScanInsert: Encodable {
            let id: String
            let user_id: String
            let foot_side: String
            let images_url: [String]
            let status: String
        }
        
        let session = try await UserProfile.supabase.auth.session
        let scanId = UUID().uuidString
        
        let scanData = ScanInsert(
            id: scanId,
            user_id: session.user.id.uuidString,
            foot_side: "left", // หรือให้เลือกได้
            images_url: imageUrls,
            status: "processing"
        )
        
        try await UserProfile.supabase
            .from("foot_scans")
            .insert(scanData)
            .execute()
        
        print("✅ Scan record created: \(scanId)")
        return scanId
    }
    
    // MARK: - Trigger ML Processing
    
    func triggerMLProcessing(scanId: String, imageUrls: [String]) async throws {
        let url = URL(string: "\(AppConfig.mlServiceURL)/process")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "scan_id": scanId,
            "image_urls": imageUrls,
            "questionnaire_score": userProfile.evaluateScore 
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        print("✅ ML processing triggered")
    }
    
    // MARK: - Wait for Results
    
    func waitForResults(scanId: String) async throws {
        let maxAttempts = 60 // 5 นาที (5 วินาที/ครั้ง)
        
        for attempt in 0..<maxAttempts {
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 วินาที
            
            print("⏳ Checking scan status... (\(attempt + 1)/\(maxAttempts))")
            
            // Query scan status
            struct ScanStatus: Codable {
                let status: String
                let pf_severity: String?
                let error_message: String?
            }
            
            let response: [ScanStatus] = try await UserProfile.supabase
                .from("foot_scans")
                .select("status, pf_severity, error_message")
                .eq("id", value: scanId)
                .execute()
                .value
            
            guard let scan = response.first else {
                throw NSError(domain: "Scan", code: 404, userInfo: [NSLocalizedDescriptionKey: "Scan not found"])
            }
            
            if scan.status == "completed" {
                print("✅ Processing completed!")
                return
            } else if scan.status == "failed" {
                throw NSError(domain: "Scan", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: scan.error_message ?? "Processing failed"
                ])
            }
            
            // Still processing...
        }
        
        throw NSError(domain: "Scan", code: -2, userInfo: [NSLocalizedDescriptionKey: "Processing timeout"])
    }
}

#Preview {
    NavigationStack {
        ScanView()
            .environmentObject(UserProfile.preview)
    }
}

