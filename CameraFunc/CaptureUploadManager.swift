//
//  UploadManager.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 27/10/2568 BE.
//

import SwiftUI
import FirebaseStorage // <--- เพิ่ม
import Zip // <--- เพิ่ม

@MainActor
class UploadManager: ObservableObject {
    
    // สถานะ
    @Published var scanState: ScanState = .idle // (ใช้ enum 'ScanState' เดิม)
    @Published var exportedURL: URL? = nil
    @Published var processingProgress: Double = 0.0 // (จะใช้เป็น Upload Progress)
    
    // ที่เก็บรูป
    @Published var imageCount = 0
    private var tempImageFolder: URL?
    
    // 1. สร้างโฟลเดอร์ชั่วคราว (เหมือนเดิม)
    func setupFolders(footSide: ScanView.FootSide) {
        self.scanState = .idle
        self.imageCount = 0
        self.exportedURL = nil
        
        let footFolderName = footSide == .left ? "foot_left" : "foot_right"
        self.tempImageFolder = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent(footFolderName)
        
        try? FileManager.default.createDirectory(at: tempImageFolder!, withIntermediateDirectories: true)
    }
    
    // 2. เพิ่มรูปที่ถ่ายได้ (เหมือนเดิม)
    func addImage(_ image: UIImage) {
        guard let folder = tempImageFolder,
              let data = image.jpegData(compressionQuality: 0.9) else { return }
        
        let url = folder.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        try? data.write(to: url)
        
        DispatchQueue.main.async {
            self.imageCount += 1
        }
    }
    
    // 3. (เปลี่ยน) เริ่ม "อัปโหลด" (แทน "ประมวลผล")
    func startUpload(footSide: ScanView.FootSide) {
        guard let inputFolder = tempImageFolder, imageCount > 10 else {
            print("รูปน้อยเกินไป")
            self.scanState = .idle
            return
        }
        
        self.scanState = .saving // เปลี่ยนเป็น "กำลังอัปโหลด"
        self.processingProgress = 0.0

        Task { // ทำงานใน Background Thread
            do {
                // 3.1: บีบอัดไฟล์ (Zip)
                print("กำลังบีบอัดไฟล์...")
                let zipURL = try await zipPhotos(inputFolder: inputFolder)
                print("บีบอัดไฟล์สำเร็จที่: \(zipURL)")

                // 3.2: อัปโหลด (Upload)
                print("กำลังอัปโหลด...")
                let storageRef = Storage.storage().reference()
                let fileName = "\(UUID().uuidString)_\(footSide == .left ? "L" : "R").zip"
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
                        self.exportedURL = zipURL // (แค่ใช้ชั่วคราว)
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
            
            // ลบโฟลเดอร์รูปชั่วคราว (เหมือนเดิม)
            try? FileManager.default.removeItem(at: inputFolder.deletingLastPathComponent())
        }
    }

    // 4. (ใหม่) ฟังก์ชันสำหรับบีบอัดไฟล์
    private func zipPhotos(inputFolder: URL) async throws -> URL {
        let zipFilePath = FileManager.default.temporaryDirectory.appendingPathComponent("\(inputFolder.lastPathComponent).zip")
        
        // ลบไฟล์ zip เก่า (ถ้ามี)
        try? FileManager.default.removeItem(at: zipFilePath)
        
        // ใช้ Library 'Zip'
        try Zip.zipFiles(paths: [inputFolder], zipFilePath: zipFilePath, password: nil, progress: { progress in
            // (เราใช้ progress ของ upload แทน)
        })
        
        return zipFilePath
    }
}
