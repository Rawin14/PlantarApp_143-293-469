//
//  AgeView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 18/10/2568 BE.
//

//
// AgeView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 18/10/2568 BE.
//

import SwiftUI

// MARK: - AgeView Colors
extension Color {
    // 🎨 **Age-Specific Colors** (Must be unique)
    static let Age_Background = Color(red: 247/255, green: 246/255, blue: 236/255) // Main Background (Light Cream)
    static let Age_Primary = Color(red: 139/255, green: 122/255, blue: 184/255)  // Main Purple (for numbers, ruler marks)
    static let Age_Accent = Color(red: 172/255, green: 187/255, blue: 98/255)    // Light Green (for top circle, if used)
    static let Age_SecondaryText = Color(red: 100/255, green: 100/255, blue: 100/255) // Grey for text
    static let Age_InfoBox = Color(red: 220/255, green: 220/255, blue: 220/255) // Info box background color
    static let Age_PageIndicatorActive = Color.black // Active Page Indicator dot color
    static let Age_PageIndicatorInactive = Color(red: 200/255, green: 200/255, blue: 200/255) // Inactive Page Indicator dot color
}

struct AgeView: View {
    // 👤 Initial Age
    @State private var currentAge: Double = 55.0 // Changed initial value
    // 📍 For Page Indicator at the bottom
    @State private var currentPage: Int = 2 // Adjusted for a typical starting page

    // **Constants for Age Range**
    let minAge: Double = 1.0
    let maxAge: Double = 100.0
    let ageStep: Double = 1.0

    var body: some View {
        ZStack {
            Color.Age_Background.ignoresSafeArea()
            
            VStack {
                // MARK: - Header (Back Button + Title)
                HStack {
                    // Back Button
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .padding(.leading, 10)
                        .onTapGesture {
                            print("Back button tapped")
                        }
                    Spacer()
                    // Status Bar (Placeholder)
                    Spacer()
                    HStack(spacing: 4) {
                        // Status Bar content placeholder (removed to simplify)
                    }
                    // Fixed: Used system font parameters correctly
                    .font(.system(size: 15, weight: .medium))
                    .padding(.trailing, 10)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // MARK: - Title (Centered)
                Text("What's your Age?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    // เปลี่ยน .frame(maxWidth: .infinity, alignment: .leading) เป็น .frame(maxWidth: .infinity, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

                Spacer()
                
                // MARK: - Current Age Display
                HStack(alignment: .bottom, spacing: 5) {
                    Text("\(Int(currentAge.rounded()))") // Display rounded age
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(Color.Age_Primary)
                    
                    // Removed the unit text (e.g., "kg")
                    Text("")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(Color.Age_Primary.opacity(0.8))
                        .offset(y: -10)
                }
                .padding(.vertical, 30)

                // MARK: - Ruler/Slider
                AgeRuler(currentValue: $currentAge, min: minAge, max: maxAge, step: ageStep)
                    .frame(height: 100)
                    .padding(.vertical, 20)

                Spacer()
                
                // MARK: - Info Box
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ornare.")
                    .font(.body)
                    .foregroundColor(Color.Age_SecondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.Age_InfoBox)
                    .cornerRadius(15)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 20)

                // MARK: - Next Button
                Button(action: {
                    print("Next button tapped. Final Age: \(Int(currentAge.rounded()))")
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
                            .fill(index == currentPage ? Color.Age_PageIndicatorActive : Color.Age_PageIndicatorInactive)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Custom Views for AgeView

// Custom Ruler/Slider
struct AgeRuler: View {
    @Binding var currentValue: Double
    let min: Double
    let max: Double
    let step: Double

    // State for dragging
    @State private var dragOffset: CGFloat = 0
    @State private var cumulativeOffset: CGFloat = 0 // Cumulative Offset
    
    // Constant values
    let pixelsPerUnit: CGFloat = 8 // Set length as 8 pixels per 1 unit (1 step)

    var body: some View {
        GeometryReader { geometry in
            let rulerWidth = geometry.size.width
            let centerOffset = rulerWidth / 2
            
            ZStack(alignment: .leading) {
                // Current Value Indicator (Triangle) - Always centered
                VStack {
                    ATriangle()
                        .fill(Color.Age_Primary)
                        .frame(width: 15, height: 10)
                        .rotationEffect(.degrees(180))
                        .offset(y: -5)
                }
                .frame(width: rulerWidth)
                
                // Ruler Line
                Rectangle()
                    .fill(Color.Age_Primary.opacity(0.3))
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                    .offset(y: 10) // Move down so numbers are above the line

                // Markings
                HStack(spacing: 0) {
                    // Changed: Max range is now Int(max) for age (e.g., 100)
                    ForEach(Int(min)...Int(max), id: \.self) { value in
                        let isMajor = value % 5 == 0 // Every 5 units is a long mark
                        
                        VStack(spacing: 0) {
                            // Major mark (long)
                            Rectangle()
                                .fill(Color.Age_Primary.opacity(0.8))
                                .frame(width: 2, height: isMajor ? 25 : 15)
                            
                            // Number
                            if isMajor {
                                Text("\(value)")
                                    .font(.caption)
                                    .foregroundColor(.Age_SecondaryText)
                                    .offset(y: 5)
                            }
                        }
                        .padding(.trailing, isMajor ? 0 : pixelsPerUnit - 2) // Spacing between marks
                        
                        // Minor marks (between major marks)
                        if !isMajor && value < Int(max) {
                            ForEach(1..<Int(1/step), id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.Age_Primary.opacity(0.4))
                                    .frame(width: 1, height: 15)
                                    .padding(.trailing, pixelsPerUnit - 1)
                            }
                        }
                    }
                }
                // Move the ruler
                .offset(x: offsetForValue(rulerWidth, centerOffset) + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // Calculate new offset
                            dragOffset = cumulativeOffset + gesture.translation.width
                            
                            // Convert offset to Age value
                            let deltaX = dragOffset - centerOffset
                            let newValue = -(deltaX / pixelsPerUnit) + min
                            
                            // Snap to step and limit the value
                            let snappedValue = (newValue / step).rounded() * step
                            // **Fixed max/min error**
                            currentValue = Swift.max(min, Swift.min(max, snappedValue))
                        }
                        .onEnded { _ in
                            // Calculate final offset based on the snapped currentValue
                            let finalOffset = centerOffset - (currentValue - min) * pixelsPerUnit
                            
                            withAnimation(.spring()) {
                                dragOffset = finalOffset
                                cumulativeOffset = finalOffset
                            }
                            
                            // Check and limit boundaries (though the `onChanged` does most of the work)
                            if currentValue == min || currentValue == max {
                                cumulativeOffset = dragOffset
                            }
                        }
                )
            }
        }
    }
    
    // Calculate initial offset to center the starting value
    private func offsetForValue(_ rulerWidth: CGFloat, _ centerOffset: CGFloat) -> CGFloat {
        let initialValueOffset = (currentValue - min) * pixelsPerUnit
        return centerOffset - initialValueOffset
    }
}

// Custom Shape for Triangle (Indicator)
struct ATriangle: Shape {
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
struct AgeView_Previews: PreviewProvider {
    static var previews: some View {
        AgeView()
    }
}
