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
    static let Height_ButtonBackground = Color.white // สีพื้นหลังปุ่ม +/-
    static let Height_NextButton = Color(red: 94/255, green: 84/255, blue: 68/255) // สีปุ่ม Next (น้ำตาลเทา)
}

// MARK: - HeightView Main View
struct HeightView: View {
    // 📏 ส่วนสูงเริ่มต้น
    @State private var currentHeight: Double = 170.0 // ตั้งค่าเริ่มต้นให้เหมาะสมกับส่วนสูง
    // 📍 สำหรับ Page Indicator ด้านล่าง
    @State private var currentPage: Int = 1 // ปรับ Page Indicator
    // 🔄 Navigation
    @State private var navigateToWeight = false

    // **Constants for Height Range**
    let minHeight: Double = 40.0 // Min Height in CM
    let maxHeight: Double = 250.0 // Max Height in CM
    let heightStep: Double = 1.0 // Step 1 cm

    var body: some View {
        ZStack {
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
                Text("What's your Height?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

                Spacer()
                
                // MARK: - Current Height Display
                HStack(alignment: .bottom, spacing: 5) {
                    Text("\(Int(currentHeight.rounded()))")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(Color.Height_Primary)
                    
                    Text("CM")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(Color.Height_Primary.opacity(0.8))
                        .offset(y: -10)
                }
                .padding(.vertical, 30)

                // MARK: - Ruler/Slider (แถบไม้บรรทัดที่เลื่อนได้)
                HeightRuler(currentValue: $currentHeight, min: minHeight, max: maxHeight, step: heightStep)
                    .frame(height: 100)
                    .padding(.vertical, 20)
                
                // MARK: - Plus/Minus Buttons
                HStack(spacing: 40) {
                    // ปุ่มลด (-)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentHeight > minHeight {
                                currentHeight -= heightStep
                            }
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(currentHeight <= minHeight ? Color.Height_SecondaryText.opacity(0.3) : Color.Height_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Height_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentHeight <= minHeight)
                    
                    // ปุ่มเพิ่ม (+)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentHeight < maxHeight {
                                currentHeight += heightStep
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(currentHeight >= maxHeight ? Color.Height_SecondaryText.opacity(0.3) : Color.Height_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Height_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentHeight >= maxHeight)
                }
                .padding(.top, 10)

                Spacer()
                
                // MARK: - Info Box
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ornare .")
                    .font(.body)
                    .foregroundColor(Color.Height_SecondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.Height_InfoBox)
                    .cornerRadius(15)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 20)

                // MARK: - Next Button
                Button(action: {
                    print("Next button tapped. Final Height: \(Int(currentHeight.rounded())) CM")
                    navigateToWeight = true
                }) {
                    Text("Next")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.Height_NextButton)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)

                // MARK: - Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<6) { index in
                        Circle()
                            .fill(index == currentPage ? Color.Height_PageIndicatorActive : Color.Height_PageIndicatorInactive)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
                
                NavigationLink(
                    destination: WeightView(),
                    isActive: $navigateToWeight
                ) {
                    EmptyView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Custom Views for HeightView
// Custom Ruler/Slider
struct HeightRuler: View {
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
                    HTriangle()
                        .fill(Color.Height_Primary)
                        .frame(width: 15, height: 10)
                        .rotationEffect(.degrees(180))
                        .offset(y: -5)
                }
                .frame(width: rulerWidth)
                
                // Ruler Line
                Rectangle()
                    .fill(Color.Height_Primary.opacity(0.3))
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                    .offset(y: 10)

                // Markings
                HStack(spacing: 0) {
                    ForEach(Int(min)...Int(max), id: \.self) { value in
                        let isMajor = value % 10 == 0 // ทุก 10 CM เป็นขีดยาว
                        let isMedium = value % 5 == 0 && value % 10 != 0 // ทุก 5 CM เป็นขีดกลาง
                        
                        VStack(spacing: 0) {
                            // ขีดหลัก (ยาว/กลาง)
                            Rectangle()
                                .fill(Color.Height_Primary.opacity(0.8))
                                .frame(width: 2, height: isMajor ? 25 : (isMedium ? 20 : 15))
                            
                            // ตัวเลข
                            if isMajor {
                                Text("\(value)")
                                    .font(.caption)
                                    .foregroundColor(.Height_SecondaryText)
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
        NavigationView {
            HeightView()
        }
    }
}
