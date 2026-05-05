//
//  GenericRuler.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 5/5/2569 BE.
//

import SwiftUI

// MARK: - Generic Ruler View (ใช้ได้กับทุก View)
struct GenericRuler: View {
    @Binding var selectedValue: Int
    let config: any RulerConfigurable
    let themeColor: Color

    var range: [Int] { Array(config.minValue...config.maxValue) }

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 20))
                .foregroundColor(themeColor)
                .offset(y: -10)
                .zIndex(1)

            GenericRulerScrollView(
                selectedValue: $selectedValue,
                range: range,
                config: config,
                themeColor: themeColor
            )
            .frame(height: 110)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear,  location: 0.00),
                        .init(color: .black,  location: 0.28),
                        .init(color: .black,  location: 0.72),
                        .init(color: .clear,  location: 1.00)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}

// MARK: - GenericRulerScrollView (แก้ makeUIView + updateUIView)
struct GenericRulerScrollView: UIViewRepresentable {
    @Binding var selectedValue: Int
    let range: [Int]
    let config: any RulerConfigurable
    let themeColor: Color

    var tickSpacing: CGFloat { config.tickSpacing }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> RulerScrollUIView {
        let scrollView = RulerScrollUIView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .normal
        scrollView.delegate = context.coordinator

        let canvas = GenericRulerCanvas(
            range: range,
            config: config,
            themeColor: UIColor(themeColor)
        )
        canvas.selectedValue = selectedValue

        let totalWidth = CGFloat(range.count) * tickSpacing
        canvas.frame = CGRect(x: 0, y: 0, width: totalWidth, height: 110)
        scrollView.contentSize = CGSize(width: totalWidth, height: 110)
        scrollView.addSubview(canvas)

        context.coordinator.scrollView = scrollView
        context.coordinator.canvas = canvas

        // ✅ onLayout ถูกเรียกหลัง bounds จริงพร้อม
        scrollView.onLayout = { [weak scrollView, weak coordinator = context.coordinator] in
            guard
                let scrollView,
                let coordinator,
                coordinator.hasScrolledToInitial == false
            else { return }

            let halfWidth = scrollView.bounds.width / 2
            guard halfWidth > 0 else { return }

            coordinator.hasScrolledToInitial = true

            let inset = halfWidth - coordinator.parent.tickSpacing / 2
            scrollView.contentInset = UIEdgeInsets(
                top: 0, left: inset, bottom: 0, right: inset
            )

            let initial = coordinator.parent.selectedValue
            let targetX = CGFloat(initial - coordinator.parent.range[0])
                        * coordinator.parent.tickSpacing - inset

            // ✅ ไม่ animated เพื่อให้ตรงทันทีตอนเปิด preview / หน้าจอ
            scrollView.setContentOffset(
                CGPoint(x: targetX, y: 0),
                animated: false
            )
        }

        return scrollView
    }

    func updateUIView(_ scrollView: RulerScrollUIView, context: Context) {
        let coordinator = context.coordinator

        if coordinator.lastDrawnValue != selectedValue {
            coordinator.lastDrawnValue = selectedValue
            coordinator.canvas?.selectedValue = selectedValue
            coordinator.canvas?.setNeedsDisplay()
        }

        // Scroll ตามปุ่ม +/- เฉพาะหลัง initial scroll เสร็จและไม่ได้ drag
        guard coordinator.hasScrolledToInitial,
              !coordinator.isScrolling else { return }

        let halfWidth = scrollView.bounds.width / 2
        guard halfWidth > 0 else { return }

        let inset = halfWidth - tickSpacing / 2
        if scrollView.contentInset.left != inset {
            scrollView.contentInset = UIEdgeInsets(
                top: 0, left: inset, bottom: 0, right: inset
            )
        }

        let targetX = CGFloat(selectedValue - range[0]) * tickSpacing - inset
        if abs(scrollView.contentOffset.x - targetX) > 1 {
            scrollView.setContentOffset(
                CGPoint(x: targetX, y: 0),
                animated: true
            )
        }
    }
    // MARK: - UIScrollView Subclass ที่รู้จัก layoutSubviews
    class RulerScrollUIView: UIScrollView {
        var onLayout: (() -> Void)?

        override func layoutSubviews() {
            super.layoutSubviews()
            onLayout?()
        }
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: GenericRulerScrollView
        weak var scrollView: RulerScrollUIView?
        weak var canvas: GenericRulerCanvas?
        var isScrolling = false
        var lastDrawnValue: Int = -1
        // ✅ flag กันเรียก scroll ซ้ำหลัง layout หลายรอบ
        var hasScrolledToInitial = false
        private let haptic = UIImpactFeedbackGenerator(style: .light)

        init(_ parent: GenericRulerScrollView) {
            self.parent = parent
            super.init()
            haptic.prepare()
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isScrolling = true
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // ✅ ไม่อัปเดตระหว่าง initial scroll
            guard hasScrolledToInitial else { return }

            let inset = scrollView.contentInset.left
            let x = scrollView.contentOffset.x + inset
            let raw = x / parent.tickSpacing
            let value = parent.range[0] + Int(raw.rounded())
            let clamped = max(parent.range.first!, min(parent.range.last!, value))

            guard clamped != parent.selectedValue else { return }

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.parent.selectedValue = clamped
                self.haptic.impactOccurred()
                self.canvas?.selectedValue = clamped
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
            targetContentOffset.pointee.x =
                CGFloat(clamped - parent.range[0]) * parent.tickSpacing - inset
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            isScrolling = false
        }

        func scrollViewDidEndDragging(
            _ scrollView: UIScrollView,
            willDecelerate: Bool
        ) {
            if !willDecelerate { isScrolling = false }
        }
    }
}

// MARK: - Canvas (Core Graphics)
class GenericRulerCanvas: UIView {
    let range: [Int]
    let config: any RulerConfigurable
    let themeColor: UIColor
    var selectedValue: Int
    weak var coordinator: GenericRulerScrollView.Coordinator?

    init(range: [Int], config: any RulerConfigurable, themeColor: UIColor) {
        self.range = range
        self.config = config
        self.themeColor = themeColor
        self.selectedValue = range[range.count / 2]
        super.init(frame: .zero)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let spacing = config.tickSpacing

        for (i, value) in range.enumerated() {
            let x = CGFloat(i) * spacing + spacing / 2
            let isSelected = value == selectedValue
            let isMajor    = value % 10 == 0
            let isMid      = value % 5  == 0

            let tickH: CGFloat = isSelected ? 58 : isMajor ? 42 : isMid ? 28 : 18
            let tickW: CGFloat = isSelected ? 3.5 : isMajor ? 2.5 : 1.5

            let color: UIColor = isSelected
                ? themeColor
                : isMajor ? .gray.withAlphaComponent(0.55)
                : isMid   ? .gray.withAlphaComponent(0.35)
                :            .gray.withAlphaComponent(0.22)

            ctx.setFillColor(color.cgColor)
            let path = UIBezierPath(
                roundedRect: CGRect(x: x - tickW/2, y: 6, width: tickW, height: tickH),
                cornerRadius: 1.5
            )
            ctx.addPath(path.cgPath)
            ctx.fillPath()

            // Label ตาม config (Height=ทุก10, Age=ทุก5)
            if config.shouldShowLabel(for: value) {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12,
                                             weight: isSelected ? .bold : .medium),
                    .foregroundColor: isSelected
                        ? themeColor
                        : UIColor.gray.withAlphaComponent(0.6)
                ]
                let str = "\(value)" as NSString
                let size = str.size(withAttributes: attrs)
                str.draw(
                    at: CGPoint(x: x - size.width/2, y: 6 + tickH + 5),
                    withAttributes: attrs
                )
            }
        }
    }
}
