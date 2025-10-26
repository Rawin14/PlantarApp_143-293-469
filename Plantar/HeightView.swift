//
// HeightView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 18/10/2568 BE.
//

import SwiftUI

// MARK: - HeightView Colors
extension Color {
    // 🎨 **Height-Specific Colors** (ตัวแปรสีห้ามซ้ำ)
    static let Height_Background = Color(red: 247/255, green: 246/255, blue: 236/255) // สีพื้นหลังหลัก (ครีมอ่อน)
    static let Height_Primary = Color(red: 139/255, green: 122/255, blue: 184/255)  // สีม่วงหลัก (สำหรับตัวเลข, ขีดบน Ruler)
    static let Height_Accent = Color(red: 172/255, green: 187/255, blue: 98/255)    // สีเขียวอ่อน (สำหรับวงกลมด้านบน)
    static let Height_SecondaryText = Color(red: 100/255, green: 100/255, blue: 100/255) // สีเทาสำหรับข้อความ
    static let Height_InfoBox = Color(red: 220/255, green: 220/255, blue: 220/255) // สีพื้นหลังกล่องข้อความ
    static let Height_PageIndicatorActive = Color.black // สีจุด Page Indicator ที่ใช้งานอยู่
    static let Height_PageIndicatorInactive = Color(red: 200/255, green: 200/255, blue: 200/255) // สีจุด Page Indicator ที่ไม่ใช้งาน
}

// MARK: - HeightView Main View
struct HeightView: View {
    // 📏 ส่วนสูงเริ่มต้น
    @State private var currentHeight: Double = 170.0 // ตั้งค่าเริ่มต้นให้เหมาะสมกับส่วนสูง
    // 📍 สำหรับ Page Indicator ด้านล่าง
    @State private var currentPage: Int = 1 // ปรับ Page Indicator

    // **Constants for Height Range**
    let minHeight: Double = 40.0 // Min Height in CM
    let maxHeight: Double = 250.0 // Max Height in CM
    let heightStep: Double = 1.0 // Step 1 cm

    var body: some View {
        ZStack {
            // Fixed: ใช้ Height_Background
            Color.Height_Background.ignoresSafeArea()
            
            VStack {
                // MARK: - Header (Back Button + Title + Status Bar)
                HStack {
                    // Back Button
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .padding(.leading, 10)
                        .onTapGesture {
                            print("Back button tapped")
                        }
                    Spacer()
                    // Status Bar (จำลอง)
                    Spacer()
                    HStack(spacing: 4) {
                    
                    }
                    .font(.system(size: 15, weight: .medium))
                    .padding(.trailing, 10)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // MARK: - Title
                Text("What's your Height?") // เปลี่ยน Title
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center) // จัด Title ให้อยู่ตรงกลาง
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

                Spacer()
                
                // MARK: - Current Height Display
                HStack(alignment: .bottom, spacing: 5) {
                    // Fixed: ใช้ currentHeight
                    Text("\(Int(currentHeight.rounded()))") // แสดงตัวเลขที่ถูกปัดเศษแล้ว
                        .font(.system(size: 80, weight: .bold))
                        // Fixed: ใช้ Height_Primary
                        .foregroundColor(Color.Height_Primary)
                    // Fixed: เปลี่ยนหน่วยเป็น CM
                    Text("CM")
                        .font(.system(size: 30, weight: .semibold))
                        // Fixed: ใช้ Height_Primary
                        .foregroundColor(Color.Height_Primary.opacity(0.8))
                        .offset(y: -10)
                }
                .padding(.vertical, 30)

                // MARK: - Ruler/Slider (แถบไม้บรรทัดที่เลื่อนได้)
                // Fixed: ใช้ Height_Ruler และกำหนด min/max/step ที่เหมาะสม
                HeightRuler(currentValue: $currentHeight, min: minHeight, max: maxHeight, step: heightStep)
                    .frame(height: 100)
                    .padding(.vertical, 20)

                Spacer()
                
                // MARK: - Info Box
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ornare .")
                    .font(.body)
                    // Fixed: ใช้ Height_SecondaryText
                    .foregroundColor(Color.Height_SecondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    // Fixed: ใช้ Height_InfoBox
                    .background(Color.Height_InfoBox)
                    .cornerRadius(15)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 20)

                // MARK: - Next Button
                Button(action: {
                    // Fixed: เปลี่ยนข้อความใน print
                    print("Next button tapped. Final Height: \(Int(currentHeight.rounded())) CM")
                }) {
                    Text("Next")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)

                // MARK: - Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<6) { index in
                        Circle()
                            // Fixed: ใช้ Height_PageIndicator
                            .fill(index == currentPage ? Color.Height_PageIndicatorActive : Color.Height_PageIndicatorInactive)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Custom Views for HeightView

// Custom Ruler/Slider
// Fixed: เปลี่ยนชื่อ struct จาก Height_Ruler เป็น HeightRuler
struct HeightRuler: View {
    @Binding var currentValue: Double
    let min: Double
    let max: Double
    let step: Double

    // State สำหรับการลาก
    @State private var dragOffset: CGFloat = 0
    @State private var cumulativeOffset: CGFloat = 0 // Offset สะสม
    
    // ค่าคงที่
    let pixelsPerUnit: CGFloat = 8 // กำหนดความยาวเป็น 8 พิกเซลต่อ 1 หน่วย (1 step)

    var body: some View {
        GeometryReader { geometry in
            let rulerWidth = geometry.size.width
            let centerOffset = rulerWidth / 2
            
            ZStack(alignment: .leading) {
                // Current Value Indicator (Triangle) - วางไว้กึ่งกลางเสมอ
                VStack {
                    // Fixed: ใช้ HTriangle (ที่ถูกกำหนดไว้ด้านล่าง)
                    HTriangle()
                        // Fixed: ใช้ Height_Primary
                        .fill(Color.Height_Primary)
                        .frame(width: 15, height: 10)
                        .rotationEffect(.degrees(180))
                        .offset(y: -5)
                }
                .frame(width: rulerWidth)
                
                // Ruler Line
                Rectangle()
                    // Fixed: ใช้ Height_Primary
                    .fill(Color.Height_Primary.opacity(0.3))
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                    .offset(y: 10) // เลื่อนลงเพื่อให้ตัวเลขอยู่เหนือเส้น

                // Markings
                HStack(spacing: 0) {
                    ForEach(Int(min)...Int(max), id: \.self) { value in
                        let isMajor = value % 10 == 0 // ทุก 10 CM เป็นขีดยาว
                        let isMedium = value % 5 == 0 && value % 10 != 0 // ทุก 5 CM เป็นขีดกลาง
                        
                        VStack(spacing: 0) {
                            // ขีดหลัก (ยาว/กลาง)
                            Rectangle()
                                // Fixed: ใช้ Height_Primary
                                .fill(Color.Height_Primary.opacity(0.8))
                                .frame(width: 2, height: isMajor ? 25 : (isMedium ? 20 : 15)) // ปรับความยาวขีด
                            
                            // ตัวเลข
                            if isMajor {
                                Text("\(value)")
                                    .font(.caption)
                                    // Fixed: ใช้ Height_SecondaryText
                                    .foregroundColor(.Height_SecondaryText)
                                    .offset(y: 5)
                            }
                        }
                        .padding(.trailing, isMajor ? 0 : pixelsPerUnit - 2) // เว้นระยะห่างขีด
                        
                        // ขีดเล็ก (ระหว่างขีดใหญ่) - โค้ดนี้ถูกออกแบบสำหรับ step < 1 ซึ่งในกรณีนี้คือ step=1.0 จึงไม่มีขีดเล็กระหว่าง 1 หน่วย
                        if value < Int(max) {
                            ForEach(1..<Int(1/step), id: \.self) { _ in
                                Rectangle()
                                    // Fixed: ใช้ Height_Primary
                                    .fill(Color.Height_Primary.opacity(0.4))
                                    .frame(width: 1, height: 15)
                                    .padding(.trailing, pixelsPerUnit - 1)
                            }
                        }
                    }
                }
                // เลื่อนไม้บรรทัด
                .offset(x: offsetForValue(rulerWidth, centerOffset) + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // คำนวณ offset ใหม่
                            dragOffset = cumulativeOffset + gesture.translation.width
                            
                            // แปลง offset เป็นค่า Height
                            let deltaX = dragOffset - centerOffset
                            let newValue = -(deltaX / pixelsPerUnit) + min
                            
                            // ปัดเศษให้ตรงกับ step และจำกัดค่า
                            let snappedValue = (newValue / step).rounded() * step
                            currentValue = Swift.max(min, Swift.min(max, snappedValue))
                        }
                        .onEnded { _ in
                            // คำนวณ offset สุดท้ายตามค่า currentValue ที่ถูก Snap
                            let finalOffset = centerOffset - (currentValue - min) * pixelsPerUnit
                            
                            withAnimation(.spring()) {
                                dragOffset = finalOffset
                                cumulativeOffset = finalOffset
                            }
                        }
                )
            }
        }
    }
    
    // คำนวณ offset เริ่มต้นเพื่อให้ค่าเริ่มต้นอยู่ตรงกลาง
    private func offsetForValue(_ rulerWidth: CGFloat, _ centerOffset: CGFloat) -> CGFloat {
        let initialValueOffset = (currentValue - min) * pixelsPerUnit
        return centerOffset - initialValueOffset
    }
}

// Custom Shape for Triangle (Indicator)
// Fixed: เปลี่ยนชื่อ struct จาก HTriangle ให้เป็นชื่อที่ใช้ใน Ruler
struct HTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}


// MARK: - Preview
struct HeightView_Previews: PreviewProvider {
    static var previews: some View {
        HeightView() // Fixed: เปลี่ยนเป็น HeightView()
    }
}
