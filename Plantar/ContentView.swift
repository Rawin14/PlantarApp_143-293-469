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
            ZStack {
                Color(red: 94/255, green: 84/255, blue: 68/255)
                    .ignoresSafeArea()
                
                VStack {
                    Image("entrylogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .opacity(opacity)
                    
                    Text("Plantar")
                        .font(.system(size: 35, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 250)
                        .padding()
                    
                }
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
