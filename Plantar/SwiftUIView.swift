//
//  SwiftUIView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI
import ARKit
import RealityKit
import ModelIO
import MetalKit


// Enum สถานะการสแกน เพื่อให้ SwiftUI กับ UIKit คุยกัน
enum ScanState {
    case idle       // ยังไม่เริ่ม
    case scanning   // กำลังสแกน
    case saving     // กำลังบันทึกไฟล์
    case finished   // บันทึกเสร็จ (เผื่อใช้)
}

struct ARScanViewWrapper: UIViewRepresentable {
    
    // 1. "สะพาน" รับคำสั่งจาก SwiftUI
    @Binding var scanState: ScanState
    // "สะพาน" ส่งผลลัพธ์กลับไป (เช่น URL ของไฟล์ที่เซฟ)
    @Binding var exportedURL: URL?

    let selectedFoot: ScanView.FootSide
    // 2. สร้าง Coordinator (ผู้จัดการ)
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // 3. สร้าง ARView (ครั้งเดียว)
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator // มอบหมายให้ Coordinator จัดการ ARSession
        
        // ตั้งค่า ARView เบื้องต้น
        guard ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) else {
            print("อุปกรณ์นี้ไม่รองรับ LiDAR.")
            // ควรแสดง Alert ใน SwiftUI
            return arView
        }
        
        return arView
    }

    // 4. อัปเดต ARView (เมื่อ State ใน SwiftUI เปลี่ยน)
    func updateUIView(_ uiView: ARView, context: Context) {
        
        switch scanState {
        case .idle:
            // หยุดทุกอย่าง
            uiView.session.pause()
            uiView.debugOptions.remove(.showSceneUnderstanding)
            context.coordinator.resetScan() // ล้าง mesh เก่า
            
        case .scanning:
            // เริ่มสแกน
            let configuration = ARWorldTrackingConfiguration()
            configuration.sceneReconstruction = .mesh
            uiView.debugOptions.insert(.showSceneUnderstanding) // โชว์ตาข่าย
            uiView.session.run(configuration, options: .resetTracking)
            
        case .saving:
            // สั่งให้ Coordinator เซฟไฟล์
            uiView.session.pause() // หยุดสแกนก่อน
            context.coordinator.exportScannedMesh(arView: uiView)
            
        case .finished:
            // ไม่ต้องทำอะไร รอ SwiftUI สั่ง idle
            break
        }
    }

    // --- 5. Coordinator (สมองหลัก) ---
    // อยู่ในนี้เพื่อจะได้เข้าถึง 'parent' (ตัว struct) ได้
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARScanViewWrapper
        var meshAnchors = [ARMeshAnchor]()

        init(parent: ARScanViewWrapper) {
            self.parent = parent
        }
        
        func resetScan() {
            meshAnchors.removeAll()
        }

        // --- ARSessionDelegate Callbacks ---
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard parent.scanState == .scanning else { return }
            
            for anchor in anchors {
                if let meshAnchor = anchor as? ARMeshAnchor {
                    meshAnchors.append(meshAnchor)
                }
            }
        }

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard parent.scanState == .scanning else { return }
            
            for anchor in anchors {
                if let meshAnchor = anchor as? ARMeshAnchor {
                    if let index = meshAnchors.firstIndex(where: { $0.identifier == meshAnchor.identifier }) {
                        meshAnchors[index] = meshAnchor // อัปเดตตัวเก่า
                    }
                }
            }
        }
        
        // --- Logic การ Export (ยกมาจาก ViewController) ---
        
        func exportScannedMesh(arView: ARView) {
            guard !meshAnchors.isEmpty else {
                print("ไม่พบ Mesh ที่สแกนได้")
                DispatchQueue.main.async {
                    self.parent.scanState = .scanning // กลับไปสแกนต่อ
                }
                return
            }
            
            print("กำลังรวม Mesh ทั้งหมด \(meshAnchors.count) ชิ้น...")

            let asset = MDLAsset()
            
            for anchor in meshAnchors {
                let vertices = anchor.geometry.vertices
                let vertexData = Data(bytes: vertices.buffer.contents(), count: vertices.buffer.length)
                
                let faces = anchor.geometry.faces
                let faceData = Data(bytes: faces.buffer.contents(), count: faces.count * 3 * faces.bytesPerIndex)
                
                let vertexBuffer = MDLMeshBufferData(type: .vertex, data: vertexData)
                let faceBuffer = MDLMeshBufferData(type: .index, data: faceData)
                
                let indexType: MDLIndexBitDepth = faces.bytesPerIndex == 4 ? .uInt32 : .uInt16
                
                let submesh = MDLSubmesh(indexBuffer: faceBuffer,
                                         indexCount: faces.count * 3,
                                         indexType: indexType,
                                         geometryType: .triangles,
                                         material: nil)
                
                let vertexDescriptor = MDLVertexDescriptor()
                vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
                vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: vertices.stride)

                let mesh = MDLMesh(vertexBuffer: vertexBuffer,
                                   vertexCount: vertices.count,
                                   descriptor: vertexDescriptor,
                                   submeshes: [submesh])
                
                asset.add(mesh)
            }
            
            // --- การบันทึกไฟล์ ---
            guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                DispatchQueue.main.async { self.parent.scanState = .scanning }
                return
            }
            
            // ตั้งชื่อไฟล์ตามเท้าที่เลือก (จาก parent)
            let footSide = parent.selectedFoot == .left ? "Left" : "Right"
            let fileName = "foot_scan_\(footSide).stl"
            let fileURL = directory.appendingPathComponent(fileName)

            do {
                try asset.export(to: fileURL)
                print("บันทึกไฟล์สำเร็จ! ที่: \(fileURL)")
                
                // ส่ง URL กลับไปให้ SwiftUI
                DispatchQueue.main.async {
                    self.parent.exportedURL = fileURL
                    self.parent.scanState = .finished // แจ้งว่าเสร็จแล้ว
                }
                
            } catch {
                print("Error: ไม่สามารถ Export mesh ได้ - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.parent.scanState = .scanning // กลับไปสแกนต่อถ้าเฟล
                }
            }
        }
    }
}
