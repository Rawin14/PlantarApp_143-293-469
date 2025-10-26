//
//  ObjectCaptureManager.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI
import RealityKit // สำหรับ PhotogrammetrySession
import ModelIO // (เรายังต้องใช้ ModelIO สำหรับการแปลงไฟล์)
import CoreML // เพิ่ม import นี้สำหรับ ML

@MainActor
class ObjectCaptureManager: ObservableObject {
    
    // สถานะที่เราจะส่งกลับไปที่ ScanView
    @Published var scanState: ScanState = .idle
    @Published var exportedURL: URL? = nil
    @Published var processingProgress: Double = 0.0
    
    // --- ส่วนของ ML (ใหม่) ---
    @Published var predictedFootShape: String = "" // เก็บผลลัพธ์ ML
    
    // ที่เก็บรูป
    @Published var imageCount = 0
    private var tempImageFolder: URL?
    private var session: PhotogrammetrySession?
    
    // 1. สร้างโฟลเดอร์ชั่วคราวสำหรับเก็บรูป
    func setupFolders(footSide: ScanView.FootSide) {
        self.scanState = .idle
        self.imageCount = 0
        self.exportedURL = nil
        self.predictedFootShape = "" // รีเซ็ตผลลัพธ์ ML
        
        let footFolderName = footSide == .left ? "foot_left" : "foot_right"
        self.tempImageFolder = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent(footFolderName)
        
        try? FileManager.default.createDirectory(at: tempImageFolder!, withIntermediateDirectories: true)
    }
    
    // 2. เพิ่มรูปที่ถ่ายได้
    func addImage(_ image: UIImage) {
        guard let folder = tempImageFolder,
              let data = image.jpegData(compressionQuality: 0.9) else { return }
        
        let url = folder.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        try? data.write(to: url)
        
        // อัปเดต UI
        DispatchQueue.main.async {
            self.imageCount += 1
        }
    }
    
    // 3. เริ่มการประมวลผล (นี่คือส่วนที่นาน)
    func startProcessing(footSide: ScanView.FootSide) {
        guard let inputFolder = tempImageFolder, imageCount > 10 else {
            print("รูปน้อยเกินไป (ต้องการอย่างน้อย 10 รูป)")
            self.scanState = .idle
            return
        }
        
        self.scanState = .saving // ใช้ .saving แทน "processing"
        self.processingProgress = 0.0

        Task { // ทำงานใน Background Thread
            do {
                // 1. สร้าง Session
                var config = PhotogrammetrySession.Configuration()
                
                self.session = try PhotogrammetrySession(input: inputFolder, configuration: config)
                
                // 2. ตั้งค่าไฟล์ Output
                guard let outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    throw NSError(domain: "FileManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "ไม่สามารถเข้าถึง Document Directory ได้"])
                }
                
                let footFileName = "foot_scan_\(footSide == .left ? "Left" : "Right").usdz"
                let outputURL = outputDirectory.appendingPathComponent(footFileName)
                
                // ลบไฟล์เก่า (ถ้ามี)
                try? FileManager.default.removeItem(at: outputURL)
                
                // --- 3. สร้าง Request ---
                // (แก้เป็น .full หรือ .medium หรือ .reduced ตามที่ Target iOS ของคุณรองรับ)
                let request = PhotogrammetrySession.Request.modelFile(url: outputURL, detail: .reduced) // ผมใช้ .reduced เพื่อความเร็ว

                // --- 4. สั่ง Process ---
                guard let session = self.session else {
                    print("⚠️ PhotogrammetrySession ยังไม่ได้ถูกสร้าง")
                    await MainActor.run { self.scanState = .idle }
                    return
                }

                try session.process(requests: [request])

                // --- 5. รอฟังผลลัพธ์ ---
                for try await output in session.outputs {
                    switch output {

                    case .requestProgress(_, let fractionComplete):
                        // อัปเดตแถบ Progress
                        await MainActor.run {
                            self.processingProgress = fractionComplete
                        }

                    case .requestComplete(_, .modelFile(let url)):
                        // ได้ไฟล์ .usdz แล้ว → แปลงเป็น .stl
                        let stlURL = outputURL.deletingPathExtension().appendingPathExtension("stl")
                        try await self.convertToSTL(usdzURL: url, stlURL: stlURL)
                        
                        // --- 6. เรียก ML (ใหม่) ---
                        await MainActor.run { self.scanState = .analyzing } // เปลี่ยนสถานะเป็น "กำลังวิเคราะห์"
                        try await self.analyzeFootShape(stlURL: stlURL) // เรียกฟังก์ชัน ML

                        // --- 7. เสร็จสิ้น ---
                        await MainActor.run {
                            self.exportedURL = stlURL // บันทึก URL สุดท้าย
                            self.scanState = .finished // แจ้งว่าเสร็จแล้ว
                        }

                    case .requestError(_, let error):
                        throw error

                    default:
                        break
                    }
                }

            } catch {
                print("❌ Error ประมวลผล Photogrammetry: \(error)")
                await MainActor.run {
                    self.scanState = .idle
                }
            }

            // --- 8. ลบโฟลเดอร์รูปชั่วคราว ---
            try? FileManager.default.removeItem(at: inputFolder.deletingLastPathComponent())
            self.session = nil
        }
    }

    
    // (Optional) ฟังก์ชันสำหรับแปลง .usdz (ที่ได้มา) ไปเป็น .stl
    private func convertToSTL(usdzURL: URL, stlURL: URL) async throws {
        let asset = MDLAsset(url: usdzURL)
        asset.loadTextures()
        
        // ตรวจสอบว่าไฟล์ STL ปลายทางไม่มีอยู่ 
        try? FileManager.default.removeItem(at: stlURL)
        
        try asset.export(to: stlURL)
        print("แปลงเป็น STL สำเร็จ! ที่: \(stlURL)")
    }
    
    // --- ฟังก์ชัน ML (จำลอง) ---
    private func analyzeFootShape(stlURL: URL) async throws {
        print("กำลังวิเคราะห์รูปทรงเท้าด้วย ML จากไฟล์: \(stlURL.lastPathComponent)")
        
        // --- ส่วนจำลอง ---
        // (ในโลกจริง: คุณจะโหลด .mlmodel และรัน prediction ตรงนี้)
        try await Task.sleep(nanoseconds: 2_000_000_000) // หน่วงเวลา 2 วินาที (จำลองว่า ML กำลังคิด)
        
        // ผลลัพธ์จำลอง
        let result = "Flat Foot (Analyzed)"
        
        await MainActor.run {
            self.predictedFootShape = result // อัปเดตผลลัพธ์
            print("✅ ML Analysis เสร็จสิ้น!")
        }
        
        // (ถ้า ML Error ให้โยน throw error)
        // throw NSError(domain: "MLError", code: 1, userInfo: nil)
    }
}
