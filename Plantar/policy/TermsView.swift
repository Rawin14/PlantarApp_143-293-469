//
//  PrivacyPolicyView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 7/10/2568 BE.
//

import SwiftUI

struct TermsView: View {
    @State private var agreed = false
    @State private var goNext = false
    
    var body: some View {
        if goNext {
            LoginView() //หน้าถัดไป
        } else {
            VStack(alignment: .leading, spacing: 20) {
                Text("ข้อจำกัดการใช้งาน")
                    .font(.title)
                    .fontWeight(.bold)
                
                ScrollView {
                    Text("""
                            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque in arcu ut lorem feugiat ultricies vel sed augue. Pellentesque placerat, urna sit amet venenatis fermentum, risus sapien iaculis lectus, in ullamcorper turpis purus id tortor. Aliquam eu pharetra leo...
                            """)
                    .font(.body)
                    .padding()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 3)
                .padding(.horizontal)
                
                Spacer()
                Button(action: {
                    agreed.toggle()
                }) {
                    HStack {
                        Image(systemName: agreed ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(agreed ? .black : .gray)
                        Text("ฉันยอมรับข้อกำหนดการใช้งาน")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                }
                
                Button(action: {
                    if agreed {
                        withAnimation(.easeInOut) {
                            goNext = true
                        }
                    }
                }) {
                    Text("Next")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(agreed ? Color.black : Color.gray)
                        .cornerRadius(20)
                        .shadow(radius: 4)
                }
                .disabled(!agreed)
                
                Spacer()
            }
            .padding()
            .background(Color(red: 1.0, green: 0.99, blue: 0.9))
            .transition(.opacity)
        }
    }
}


#Preview {
    TermsView()
}
