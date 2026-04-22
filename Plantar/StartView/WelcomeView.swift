//
//  welcome.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//

//
//import SwiftUI
//
//struct WelcomeView: View {
//    // ✅ 1. ใช้ AppStorage เพื่อบอกสถานะกับ PlantarApp
//    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
//    
//    var body: some View {
//        ZStack {
//            // พื้นหลังเป็นรูปภาพ
//            Color(red: 0.98, green: 0.96, blue: 0.90)
//                .ignoresSafeArea()
//            // Overlay เนื้อหา
//            VStack {
//                
//                Spacer()
//                
//                // ปุ่ม Get Started
//                Button(action: {
//                    // ✅ 2. เปลี่ยนค่าเป็น false เพื่อให้ PlantarApp สลับหน้าให้
//                    withAnimation(.easeInOut) {
//                        isFirstLaunch = false
//                    }
//                }) {
//                    Text("เริ่มต้น")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundColor(.white)
//                        .frame(maxWidth: 250)
//                        .padding()
//                        .background(Color(red: 74/255, green: 59/255, blue: 49/255)) // น้ำตาลโทนอุ่น
//                        .cornerRadius(20)
//                        .padding(.horizontal, 40)
//                        .shadow(radius: 5) // เพิ่มเงาให้ปุ่มดูนูนขึ้น
//                }
//                Text("เวอร์ชัน iOS 15 ขึ้นไป")
//                    .padding(.bottom, 20)
//            }
//        }
//    }
//}
//
//#Preview {
//    WelcomeView()
//}


import SwiftUI

struct WelcomeView: View {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var body: some View {
        ZStack {
            Image("welcome")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(
                    Color.black.opacity(0.25)
                )
            
            VStack {
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut) {
                        isFirstLaunch = false
                    }
                }) {
                    Text("เริ่มต้น")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: 250)
                        .padding()
                        .background(
                            Color(red: 247/255, green: 246/255, blue: 236/255)
                        )
                        .cornerRadius(20)
                        .shadow(radius: 5)
                }
                
                Text("เวอร์ชัน iOS 15 ขึ้นไป")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 10)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 30)
        }
    }
}

#Preview {
    WelcomeView()
}
