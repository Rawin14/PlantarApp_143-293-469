//
//  CaptureUploadManager.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI
import FirebaseStorage // 👈 ต้อง import
import Zip              // 👈 ต้อง import

@MainActor
class CaptureUploadManager: ObservableObject {
    
    // สถานะ
    @Published var scanState: ScanState = .idle // (ใช้ enum 'ScanState' จาก ScanView)
    @Published var exportedURL: URL? = nil
    @Published var processingProgress: Double = 0.0 // (จะใช้เป็น Upload Progress)
    
    // ที่เก็บรูป
    @Published var imageCount = 0
    private var tempImageFolder: URL?
    
    // 1. สร้างโฟลเดอร์ชั่วคราวสำหรับเก็บรูป
    func setupFolders(footSide: ScanView.FootSide) {
        self.scanState = .idle
        self.imageCount = 0
        self.exportedURL = nil
        self.processingProgress = 0.0
        
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
    
    // 3. เริ่มการ "อัปโหลด" (แทน "ประมวลผล")
    func startUpload(footSide: ScanView.FootSide) {
        guard let inputFolder = tempImageFolder, imageCount > 10 else {
            print("รูปน้อยเกินไป (ต้องการอย่างน้อย 10 รูป)")
            self.scanState = .idle
            return
        }
        
        self.scanState = .saving // เปลี่ยนสถานะเป็น "กำลังบันทึก/อัปโหลด"
        self.processingProgress = 0.0

        Task { // ทำงานใน Background Thread
            do {
                // 3.1: บีบอัดไฟล์ (Zip)
                print("กำลังบีบอัดไฟล์...")
                let zipURL = try await zipPhotos(inputFolder: inputFolder)
                print("บีบอัดไฟล์สำเร็จที่: \(zipURL)")

                // 3.2: อัปโหลด (Upload to Firebase)
                print("กำลังอัปโหลด...")
                let storageRef = Storage.storage().reference()
                let fileName = "\(UUID().uuidString)_\(footSide == .left ? "L" : "R").zip"
                // 📍 นี่คือ Path ที่ไฟล์จะไปอยู่บน Firebase Storage
                let footScanRef = storageRef.child("foot_scans/\(fileName)")

                // อัปโหลดไฟล์และติดตาม Progress
                let uploadTask = footScanRef.putFile(from: zipURL, metadata: nil) { metadata, error in
                    if let error = error {
                        print("❌ Error อัปโหลด Firebase: \(error)")
                        Task { await MainActor.run { self.scanState = .idle } }
                        return
                    }
                    
                    // อัปโหลดสำเร็จ!
                    print("✅ อัปโหลดสำเร็จ!")
                    Task { await MainActor.run {
                        // เราไม่จำเป็นต้องใช้ URL นี้แล้ว แต่เก็บไว้เผื่อ
                        self.exportedURL = zipURL
                        self.scanState = .finished
                    }}
                }
                
                // ติดตาม Progress
                uploadTask.observe(.progress) { snapshot in
                    let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                    Task { await MainActor.run {
                        self.processingProgress = percentComplete
                    }}
                }

            } catch {
                print("❌ Error ระหว่าง Zip หรือ Upload: \(error)")
                await MainActor.run { self.scanState = .idle }
            }
            
            // 4. ลบโฟลเดอร์รูปชั่วคราว
            try? FileManager.default.removeItem(at: inputFolder.deletingLastPathComponent())
        }
    }

    // 4. (ใหม่) ฟังก์ชันสำหรับบีบอัดไฟล์
    private func zipPhotos(inputFolder: URL) async throws -> URL {
        let zipFilePath = FileManager.default.temporaryDirectory.appendingPathComponent("\(inputFolder.lastPathComponent).zip")
        
        // ลบไฟล์ zip เก่า (ถ้ามี)
        try? FileManager.default.removeItem(at: zipFilePath)
        
        // ใช้ Library 'Zip'
        try Zip.zipFiles(paths: [inputFolder], zipFilePath: zipFilePath, password: nil, progress: nil)
        
        return zipFilePath
    }
}
