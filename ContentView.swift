//
//  ContentView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//

import SwiftUI

struct ContentView: View {
    @State private var isActive = false // ตัวแปรเช็คว่าจะไปหน้าไหน
    @State private var opacity = 0.0 // ใช้ทำ effect จางๆ
    
    var body: some View {
        if isActive {
            WelcomeView() // ✅ ไปหน้า welcome หลังจากโหลดเสร็จ
        } else {
            VStack {
                Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.green)
                    .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeIn(duration: 1.5)) {
                    opacity = 1.0
                }
                
                // ⏱ ตั้งเวลาให้เปลี่ยนหน้า
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
