//
//  WeightView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 18/10/2568 BE.
//

// ไฟล์: WeightView.swift


import SwiftUI

// MARK: - WeightView Colors (ตัวแปรสีห้ามซ้ำ)
extension Color {
    static let Weight_Background = Color(red: 247/255, green: 246/255, blue: 236/255) // สีพื้นหลังหลัก (ครีมอ่อน)
    static let Weight_Primary = Color(red: 139/255, green: 122/255, blue: 184/255)  // สีม่วงหลัก (สำหรับตัวเลข, ขีดบน Ruler)
    static let Weight_Accent = Color(red: 172/255, green: 187/255, blue: 98/255)    // สีเขียวอ่อน (สำหรับวงกลมด้านบน)
    static let Weight_SecondaryText = Color(red: 100/255, green: 100/255, blue: 100/255) // สีเทาสำหรับข้อความ
    static let Weight_InfoBox = Color(red: 220/255, green: 220/255, blue: 220/255) // สีพื้นหลังกล่องข้อความ
    static let Weight_PageIndicatorActive = Color.black // สีจุด Page Indicator ที่ใช้งานอยู่
    static let Weight_PageIndicatorInactive = Color(red: 200/255, green: 200/255, blue: 200/255) // สีจุด Page Indicator ที่ไม่ใช้งาน
}

// MARK: - WeightView Main View
struct WeightView: View {
    // น้ำหนักเริ่มต้น
    @State private var currentWeight: Double = 55.0
    // สำหรับ Page Indicator ด้านล่าง
    @State private var currentPage: Int = 0

    var body: some View {
        ZStack {
            Color.Weight_Background.ignoresSafeArea()
            
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
                
                Text("What's your weight?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

                Spacer()
                
                // MARK: - Current Weight Display
                HStack(alignment: .bottom, spacing: 5) {
                    Text("\(Int(currentWeight.rounded()))") // แสดงตัวเลขที่ถูกปัดเศษแล้ว
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(Color.Weight_Primary)
                    Text("KG")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(Color.Weight_Primary.opacity(0.8))
                        .offset(y: -10)
                }
                .padding(.vertical, 30)

                // MARK: - Ruler/Slider (แถบไม้บรรทัดที่เลื่อนได้)
                Weight_Ruler(currentValue: $currentWeight, min: 0, max: 1000, step: 1.0) // ปรับ step เป็น 1.0 เพื่อความแม่นยำ
                    .frame(height: 100)
                    .padding(.vertical, 20)

                Spacer()
                
                // MARK: - Info Box
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ornare .")
                    .font(.body)
                    .foregroundColor(Color.Weight_SecondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.Weight_InfoBox)
                    .cornerRadius(15)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 20)

                // MARK: - Next Button
                Button(action: {
                    print("Next button tapped. Final Weight: \(Int(currentWeight.rounded())) KG")
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
                            .fill(index == currentPage ? Color.Weight_PageIndicatorActive : Color.Weight_PageIndicatorInactive)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Custom Views for WeightView

// Custom Ruler/Slider
struct Weight_Ruler: View {
    @Binding var currentValue: Double
    let min: Double
    let max: Double
    let step: Double

    // State สำหรับการลาก
    @State private var dragOffset: CGFloat = 0
    @State private var cumulativeOffset: CGFloat = 0 // Offset สะสม
    
    // ค่าคงที่
    let pixelsPerUnit: CGFloat = 8 // กำหนดความยาวเป็น 8 พิกเซลต่อ 1 กิโลกรัม (หรือ 1 step)

    var body: some View {
        GeometryReader { geometry in
            let rulerWidth = geometry.size.width
            let centerOffset = rulerWidth / 2
            
            ZStack(alignment: .leading) {
                // Current Value Indicator (Triangle) - วางไว้กึ่งกลางเสมอ
                VStack {
                    Triangle()
                        .fill(Color.Weight_Primary)
                        .frame(width: 15, height: 10)
                        .rotationEffect(.degrees(180))
                        .offset(y: -5)
                }
                .frame(width: rulerWidth)
                
                // Ruler Line
                Rectangle()
                    .fill(Color.Weight_Primary.opacity(0.3))
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                    .offset(y: 10) // เลื่อนลงเพื่อให้ตัวเลขอยู่เหนือเส้น

                // Markings
                HStack(spacing: 0) {
                    ForEach(Int(min)...Int(max), id: \.self) { value in
                        let isMajor = value % 5 == 0 // ทุก 5 กิโลกรัมเป็นขีดยาว
                        
                        VStack(spacing: 0) {
                            // ขีดหลัก (ยาว)
                            Rectangle()
                                .fill(Color.Weight_Primary.opacity(0.8))
                                .frame(width: 2, height: isMajor ? 25 : 15)
                            
                            // ตัวเลข
                            if isMajor {
                                Text("\(value)")
                                    .font(.caption)
                                    .foregroundColor(.Weight_SecondaryText)
                                    .offset(y: 5)
                            }
                        }
                        .padding(.trailing, isMajor ? 0 : pixelsPerUnit - 2) // เว้นระยะห่างขีด
                        
                        // ขีดเล็ก (ระหว่างขีดใหญ่)
                        if !isMajor && value < Int(max) {
                            ForEach(1..<Int(1/step), id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.Weight_Primary.opacity(0.4))
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
                            
                            // แปลง offset เป็นค่า Weight
                            let deltaX = dragOffset - centerOffset
                            let newValue = -(deltaX / pixelsPerUnit) + min
                            
                            // ปัดเศษให้ตรงกับ step และจำกัดค่า
                            let snappedValue = (newValue / step).rounded() * step
                            // **แก้ไข Error max/min**
                            currentValue = Swift.max(min, Swift.min(max, snappedValue))
                        }
                        .onEnded { gesture in
                            // คำนวณ offset สุดท้ายตามค่า currentValue ที่ถูก Snap
                            let finalOffset = centerOffset - (currentValue - min) * pixelsPerUnit
                            
                            withAnimation(.spring()) {
                                dragOffset = finalOffset
                                cumulativeOffset = finalOffset
                            }
                            
                            // ตรวจสอบและจำกัดขอบเขต
                            if currentValue == min || currentValue == max {
                                cumulativeOffset = dragOffset
                            }
                        }
                )
                
            }
        }
    }
    
    // คำนวณ offset เริ่มต้นเพื่อให้ค่าเริ่มต้นอยู่ตรงกลาง
    private func offsetForValue(_ rulerWidth: CGFloat, _ centerOffset: CGFloat) -> CGFloat {
        // ตำแหน่งของขีด 'min' (40) ควรจะเริ่มต้นที่ offset
        let initialValueOffset = (currentValue - min) * pixelsPerUnit
        return centerOffset - initialValueOffset
    }
}

// Custom Shape for Triangle (Indicator)
struct Triangle: Shape {
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
struct WeightView_Previews: PreviewProvider {
    static var previews: some View {
        WeightView()
    }
}
