//
//  RulerConfig.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 5/5/2569 BE.
//

import SwiftUI

// ✅ Protocol กำหนดว่า View ไหนก็ตามที่ใช้ Ruler ต้องมีอะไรบ้าง
protocol RulerConfigurable {
    var minValue: Int { get }
    var maxValue: Int { get }
    var tickSpacing: CGFloat { get }
    var unitLabel: String { get }
    // Label แต่ละ tick (ค่าเริ่มต้นแสดงทุก 10)
    func shouldShowLabel(for value: Int) -> Bool
}

// ค่า default
extension RulerConfigurable {
    var tickSpacing: CGFloat { 20 }
    func shouldShowLabel(for value: Int) -> Bool { value % 10 == 0 }
}

// MARK: - Preset Configs

struct HeightRulerConfig: RulerConfigurable {
    let minValue = 100
    let maxValue = 220
    let unitLabel = "เซนติเมตร"
}

struct WeightRulerConfig: RulerConfigurable {
    let minValue = 30
    let maxValue = 200
    let unitLabel = "กิโลกรัม"
}

struct AgeRulerConfig: RulerConfigurable {
    let minValue = 1
    let maxValue = 100
    let unitLabel = "ปี"
    func shouldShowLabel(for value: Int) -> Bool { value % 5 == 0 }
}
