//
//  FootSegmentedControl.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

struct FootSegmentedControl: View {
    
    @Binding var selectedSide: ScanView.FootSide
    
    let unselectedColor: Color
    
    var body: some View {
        HStack(spacing: 4) {
            // ปุ่ม Left
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedSide = .left
                }
            }) {
                Text("Left")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedSide == .left ? .white : .clear)
                    .foregroundColor(selectedSide == .left ? .black : .secondary)
                    .clipShape(Capsule())
            }
            
            // ปุ่ม Right
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedSide = .right
                }
            }) {
                Text("Right")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedSide == .right ? .white : .clear)
                    .foregroundColor(selectedSide == .right ? .black : .secondary)
                    .clipShape(Capsule())
            }
        }
        .padding(4) // ระยะห่างขอบใน
        .background(unselectedColor)
        .clipShape(Capsule())
    }
}
