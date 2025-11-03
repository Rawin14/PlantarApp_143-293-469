//
// WeightView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 18/10/2568 BE.
//

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
    static let Weight_ButtonBackground = Color.white // สีพื้นหลังปุ่ม +/-
    static let Weight_NextButton = Color(red: 94/255, green: 84/255, blue: 68/255) // สีปุ่ม Next (น้ำตาลเทา)
}

// MARK: - WeightView Main View
struct WeightView: View {
    // น้ำหนักเริ่มต้น
    @State private var currentWeight: Double = 55.0
    // สำหรับ Page Indicator ด้านล่าง
    @State private var currentPage: Int = 0
    
    // Constants for Weight Range
    let minWeight: Double = 10.0 // Min Weight in KG
    let maxWeight: Double = 200.0 // Max Weight in KG
    let weightStep: Double = 1.0 // Step 1 kg

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
                
                // MARK: - Title
                Text("What's your weight?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

                Spacer()
                
                // MARK: - Current Weight Display
                HStack(alignment: .bottom, spacing: 5) {
                    Text("\(Int(currentWeight.rounded()))")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(Color.Weight_Primary)
                    
                    Text("KG")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(Color.Weight_Primary.opacity(0.8))
                        .offset(y: -10)
                }
                .padding(.vertical, 30)

                // MARK: - Ruler/Slider (แถบไม้บรรทัดที่เลื่อนได้)
                WeightRuler(currentValue: $currentWeight, min: minWeight, max: maxWeight, step: weightStep)
                    .frame(height: 100)
                    .padding(.vertical, 20)
                
                // MARK: - Plus/Minus Buttons
                HStack(spacing: 40) {
                    // ปุ่มลด (-)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentWeight > minWeight {
                                currentWeight -= weightStep
                            }
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(currentWeight <= minWeight ? Color.Weight_SecondaryText.opacity(0.3) : Color.Weight_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Weight_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentWeight <= minWeight)
                    
                    // ปุ่มเพิ่ม (+)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentWeight < maxWeight {
                                currentWeight += weightStep
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(currentWeight >= maxWeight ? Color.Weight_SecondaryText.opacity(0.3) : Color.Weight_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Weight_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentWeight >= maxWeight)
                }
                .padding(.top, 10)

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

                // MARK: - Next Button (สีเปลี่ยนเป็นน้ำตาลเทา)
                Button(action: {
                    print("Next button tapped. Final Weight: \(Int(currentWeight.rounded())) KG")
                }) {
                    Text("Next")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.Weight_NextButton) // เปลี่ยนจาก .black
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
struct WeightRuler: View {
    @Binding var currentValue: Double
    let min: Double
    let max: Double
    let step: Double

    // State สำหรับการลาก
    @State private var dragOffset: CGFloat = 0
    
    // ค่าคงที่
    let pixelsPerUnit: CGFloat = 20 // เพิ่มจาก 8 เป็น 20 (ยิ่งมากยิ่งช้า)
    let dragSensitivity: CGFloat = 0.5 // ค่า 0.5 = ช้าลง 50%

    var body: some View {
        GeometryReader { geometry in
            let rulerWidth = geometry.size.width
            let centerOffset = rulerWidth / 2
            
            ZStack(alignment: .leading) {
                // Current Value Indicator (Triangle) - วางไว้กึ่งกลางเสมอ
                VStack {
                    WTriangle()
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
                    .offset(y: 10)

                // Markings
                HStack(spacing: 0) {
                    ForEach(Int(min)...Int(max), id: \.self) { value in
                        let isMajor = value % 10 == 0 // ทุก 10 KG เป็นขีดยาว
                        let isMedium = value % 5 == 0 && value % 10 != 0 // ทุก 5 KG เป็นขีดกลาง
                        
                        VStack(spacing: 0) {
                            // ขีดหลัก (ยาว/กลาง)
                            Rectangle()
                                .fill(Color.Weight_Primary.opacity(0.8))
                                .frame(width: 2, height: isMajor ? 25 : (isMedium ? 20 : 15))
                            
                            // ตัวเลข
                            if isMajor {
                                Text("\(value)")
                                    .font(.caption)
                                    .foregroundColor(.Weight_SecondaryText)
                                    .offset(y: 5)
                            }
                        }
                        .frame(width: pixelsPerUnit)
                    }
                }
                .offset(x: centerOffset - ((currentValue - min) * pixelsPerUnit) + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // ใช้ dragSensitivity เพื่อลดความไวในการลาก
                            dragOffset = gesture.translation.width * dragSensitivity
                            
                            let deltaValue = -dragOffset / pixelsPerUnit
                            let newValue = currentValue + deltaValue
                            
                            // ปัดเศษให้ตรงกับ step และจำกัดค่า
                            let snappedValue = (newValue / step).rounded() * step
                            currentValue = Swift.max(min, Swift.min(max, snappedValue))
                        }
                        .onEnded { _ in
                            // รีเซ็ต dragOffset พร้อมแอนิเมชั่นแบบ smooth
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                                dragOffset = 0
                            }
                        }
                )
            }
        }
    }
}

// Custom Shape for Triangle (Indicator)
struct WTriangle: Shape {
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
