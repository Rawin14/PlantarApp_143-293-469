//
//  welcome.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//

import SwiftUI

struct WelcomeView: View {
    // ✅ 1. ใช้ AppStorage เพื่อบอกสถานะกับ PlantarApp
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var body: some View {
        ZStack {
            // พื้นหลังเป็นรูปภาพ
            Color(red: 0.98, green: 0.96, blue: 0.90)
                .ignoresSafeArea()
            // Overlay เนื้อหา
            VStack {
                Spacer()
                
                // ชื่อแผน
                Text("Stretching\nPlan")
                    .font(.system(size: 36, weight: .semibold, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.bottom, 40)
                
                Spacer()
                
                // ปุ่ม Get Started
                Button(action: {
                    // ✅ 2. เปลี่ยนค่าเป็น false เพื่อให้ PlantarApp สลับหน้าให้
                    withAnimation(.easeInOut) {
                        isFirstLaunch = false
                    }
                }) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 250)
                        .padding()
                        .background(Color(red: 74/255, green: 59/255, blue: 49/255)) // น้ำตาลโทนอุ่น
                        .cornerRadius(20)
                        .padding(.horizontal, 40)
                        .shadow(radius: 5) // เพิ่มเงาให้ปุ่มดูนูนขึ้น
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    WelcomeView()
}
