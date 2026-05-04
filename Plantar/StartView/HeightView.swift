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
    @State private var currentHeight: Int = 160
    @State private var currentPage: Int = 1
    @State private var navigateToWeight = false
    @EnvironmentObject var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss

    let minHeight: Int = 100
    let maxHeight: Int = 220
    let heightStep: Int = 1

    var body: some View {
        ZStack {
            Color.Height_Background.ignoresSafeArea()

            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                    }
                    .padding(.leading, 10)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Title
                Text("โปรดระบุส่วนสูง ?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

                Spacer()

                // Height Display
                HStack(alignment: .bottom, spacing: 5) {
                    Text("\(currentHeight)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(Color.Height_Primary)

                    Text("ซม.")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(Color.Height_Primary.opacity(0.8))
                        .offset(y: -10)
                }
                .padding(.vertical, 30)

                // Ruler — ส่ง Binding<Int> ตรงๆ ไม่ต้องแปลง
                HeightRuler(selectedHeight: $currentHeight)
                    .padding(.vertical, 20)

                // +/- Buttons
                HStack(spacing: 40) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentHeight > minHeight { currentHeight -= heightStep }
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.title2).fontWeight(.semibold)
                            .foregroundColor(currentHeight <= minHeight
                                ? Color.Height_SecondaryText.opacity(0.3)
                                : Color.Height_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Height_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentHeight <= minHeight)

                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentHeight < maxHeight { currentHeight += heightStep }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2).fontWeight(.semibold)
                            .foregroundColor(currentHeight >= maxHeight
                                ? Color.Height_SecondaryText.opacity(0.3)
                                : Color.Height_Primary)
                            .frame(width: 60, height: 60)
                            .background(Color.Height_ButtonBackground)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(currentHeight >= maxHeight)
                }
                .padding(.top, 10)

                Spacer()

                // Info Box
                Text("ระบุส่วนสูงปัจจุบันเพื่อคำนวณค่า BMI และประเมินสุขภาพของคุณ")
                    .font(.body)
                    .foregroundColor(Color.Height_SecondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.Height_InfoBox)
                    .cornerRadius(15)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 20)

                // Next Button
                Button(action: {
                    userProfile.height = Double(currentHeight)
                    Task { await userProfile.saveToSupabase() }
                    navigateToWeight = true
                }) {
                    Text("ถัดไป")
                        .font(.title3).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.Height_NextButton)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)

                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index == currentPage
                                ? Color.Height_PageIndicatorActive
                                : Color.Height_PageIndicatorInactive)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToWeight) {
            WeightView()
        }
        .onAppear {
            if userProfile.height > 0 {
                currentHeight = Int(userProfile.height)
            }
        }
    }
}

// MARK: - HeightRuler ใหม่ (UIScrollView-based)
struct HeightRuler: View {
    @Binding var selectedHeight: Int
    let range = Array(120...220)

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 20))
                .foregroundColor(Color.Height_Primary)
                .offset(y: -10)
                .zIndex(1)

            RulerScrollView(
                selectedRuler: $selectedHeight,
                range: range,
                themeColor: Color.Height_Primary
            )
            .frame(height: 110)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black, location: 0.28),
                        .init(color: .black, location: 0.72),
                        .init(color: .clear, location: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}

// MARK: - UIScrollView Wrapper
struct RulerScrollView: UIViewRepresentable {
    @Binding var selectedRuler: Int
    let range: [Int]
    let themeColor: Color
    let tickSpacing: CGFloat = 20

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .normal
        scrollView.delegate = context.coordinator

        let canvas = RulerCanvas(
            range: range,
            tickSpacing: tickSpacing,
            themeColor: UIColor(themeColor)
        )
        canvas.coordinator = context.coordinator
        canvas.selectedRuler = selectedRuler

        let totalWidth = CGFloat(range.count) * tickSpacing
        canvas.frame = CGRect(x: 0, y: 0, width: totalWidth, height: 110)
        scrollView.contentSize = CGSize(width: totalWidth, height: 110)
        scrollView.addSubview(canvas)

        context.coordinator.scrollView = scrollView
        context.coordinator.canvas = canvas
        // ✅ เก็บค่าเริ่มต้นไว้ รอ layoutSubviews scroll ให้
        context.coordinator.pendingInitialValue = selectedRuler

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        let coordinator = context.coordinator

        // ✅ อัป canvas สี/highlight เมื่อค่าเปลี่ยนจากปุ่ม +/-
        if coordinator.lastDrawnValue != selectedRuler {
            coordinator.lastDrawnValue = selectedRuler
            coordinator.canvas?.selectedRuler = selectedRuler
            coordinator.canvas?.setNeedsDisplay()
        }

        // ✅ Scroll ตามปุ่ม +/- เฉพาะตอนไม่ได้ drag
        guard !coordinator.isScrolling else { return }

        let halfWidth = scrollView.bounds.width / 2
        guard halfWidth > 0 else { return } // bounds ยังไม่พร้อม

        let inset = halfWidth - tickSpacing / 2
        if scrollView.contentInset.left != inset {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        }

        let targetX = CGFloat(selectedRuler - range[0]) * tickSpacing - inset
        let currentX = scrollView.contentOffset.x
        if abs(currentX - targetX) > 1 {
            scrollView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
        }
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: RulerScrollView
        weak var scrollView: UIScrollView?
        weak var canvas: RulerCanvas?
        var isScrolling = false
        var lastDrawnValue: Int = -1
        var pendingInitialValue: Int? // ✅ รอ scroll หลัง layout เสร็จ
        private let haptic = UIImpactFeedbackGenerator(style: .light)

        init(_ parent: RulerScrollView) {
            self.parent = parent
            super.init()
            haptic.prepare()
        }

        // ✅ เรียกหลัง bounds จริงพร้อมแล้ว — scroll ไปค่าเริ่มต้นได้แม่น
        func scrollViewDidLayoutSubviews(_ scrollView: UIScrollView) {
            guard let initial = pendingInitialValue else { return }
            pendingInitialValue = nil

            let halfWidth = scrollView.bounds.width / 2
            guard halfWidth > 0 else { return }

            let inset = halfWidth - parent.tickSpacing / 2
            scrollView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)

            let targetX = CGFloat(initial - parent.range[0]) * parent.tickSpacing - inset
            scrollView.setContentOffset(CGPoint(x: targetX, y: 0), animated: false)
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isScrolling = true
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let inset = scrollView.contentInset.left
            let x = scrollView.contentOffset.x + inset
            let raw = x / parent.tickSpacing
            let value = parent.range[0] + Int(raw.rounded())
            let clamped = max(parent.range.first!, min(parent.range.last!, value))

            guard clamped != parent.selectedRuler else { return }

            // ✅ ใช้ DispatchQueue.main.async หลีกเลี่ยง modify state ระหว่าง render
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.parent.selectedRuler = clamped
                self.haptic.impactOccurred()
                self.canvas?.selectedRuler = clamped
                self.canvas?.setNeedsDisplay()
            }
        }

        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            let inset = scrollView.contentInset.left
            let rawX = targetContentOffset.pointee.x + inset
            let snapped = parent.range[0] + Int((rawX / parent.tickSpacing).rounded())
            let clamped = max(parent.range.first!, min(parent.range.last!, snapped))
            targetContentOffset.pointee.x = CGFloat(clamped - parent.range[0]) * parent.tickSpacing - inset
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            isScrolling = false
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {
            if !willDecelerate { isScrolling = false }
        }
    }
}

// MARK: - RulerCanvas (วาดด้วย Core Graphics — เร็วกว่า UIView ย่อย)
class RulerCanvas: UIView {
    let range: [Int]
    let tickSpacing: CGFloat
    let themeColor: UIColor
    var selectedRuler: Int
    weak var coordinator: RulerScrollView.Coordinator?

    init(range: [Int], tickSpacing: CGFloat, themeColor: UIColor) {
        self.range = range
        self.tickSpacing = tickSpacing
        self.themeColor = themeColor
        self.selectedRuler = range[range.count / 2]
        super.init(frame: .zero)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        for (i, value) in range.enumerated() {
            let x = CGFloat(i) * tickSpacing + tickSpacing / 2
            let isSelected = value == selectedRuler
            let isMajor = value % 10 == 0
            let isMid   = value % 5 == 0

            // คำนวณขนาดขีด
            let tickH: CGFloat = isSelected ? 58 : isMajor ? 42 : isMid ? 28 : 18
            let tickW: CGFloat = isSelected ? 3.5 : isMajor ? 2.5 : 1.5

            // เลือกสี
            let color: UIColor = isSelected
                ? themeColor
                : isMajor
                    ? UIColor.gray.withAlphaComponent(0.55)
                    : isMid
                        ? UIColor.gray.withAlphaComponent(0.35)
                        : UIColor.gray.withAlphaComponent(0.22)

            ctx.setFillColor(color.cgColor)
            let barRect = CGRect(
                x: x - tickW / 2,
                y: 6,
                width: tickW,
                height: tickH
            )
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 1.5)
            ctx.addPath(path.cgPath)
            ctx.fillPath()

            // วาดตัวเลขทุก 10 ซม.
            if isMajor {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(
                        ofSize: 12,
                        weight: isSelected ? .bold : .medium
                    ),
                    .foregroundColor: isSelected
                        ? themeColor
                        : UIColor.gray.withAlphaComponent(0.6)
                ]
                let str = "\(value)" as NSString
                let size = str.size(withAttributes: attrs)
                str.draw(
                    at: CGPoint(x: x - size.width / 2, y: 6 + tickH + 5),
                    withAttributes: attrs
                )
            }
        }
    }
}
// MARK: - Preview ✔ (แก้แล้ว)
struct HeightView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HeightView()
                .environmentObject(UserProfile())   // ✅ แก้ตรงนี้อย่างเดียว
        }
    }
}
