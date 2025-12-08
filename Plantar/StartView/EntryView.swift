//
//  EntryView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 4/12/2568 BE.
//
import SwiftUI

struct EntryView: View {
    var body: some View {
        ZStack {
            Color(red: 247/255, green: 246/255, blue: 236/255)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("Welcome to the app")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                
                Text("Next, you'll begin a quick assessment to evaluate your risk of plantar fasciitis.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                Button(action: {
                    print("Start assessment tapped")
                }) {
                    Text("Start")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 94/255, green: 84/255, blue: 68/255))
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    EntryView()
}

