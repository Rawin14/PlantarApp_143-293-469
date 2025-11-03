//
// Profile.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 23/10/2568 BE.
//

import SwiftUI

struct Profile: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @State private var selectedGender: Gender = .female
    @State private var nickname: String = ""
    @State private var birthdate: Date = Date()
    @State private var navigateToAge = false
    
    // --- Gender Enum ---
    enum Gender {
        case female, male
    }
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255)
    let cardBackground = Color.white
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // สีม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // สีเขียว
    let buttonColor = Color(red: 94/255, green: 84/255, blue: 68/255) // สีน้ำตาล
    let femaleColor = Color(red: 255/255, green: 182/255, blue: 193/255) // สีชมพู
    let maleColor = Color(red: 173/255, green: 216/255, blue: 230/255) // สีฟ้า
    
    var body: some View {
        ZStack {
            // Background
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Main Card
                VStack(spacing: 0) {
                    // Title
                    Text("Please fill in the true\ninformation")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 50)
                        .padding(.bottom, 30)
                    
                    // Gender Selection
                    HStack(spacing: 20) {
                        // Female Option
                        VStack(spacing: 12) {
                            Text("Girl")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedGender == .female ? femaleColor : Color.gray)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedGender = .female
                                }
                            }) {
                                ZStack {
                                    // รูปภาพ - ตัดเป็นวงกลมและซูมให้เต็มกรอบ
                                    Image("Female")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 130, height: 130)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    selectedGender == .female ? femaleColor : Color.gray.opacity(0.3),
                                                    lineWidth: 4
                                                )
                                        )
                                }
                                .frame(width: 140, height: 160)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedGender == .female ? femaleColor.opacity(0.1) : Color.gray.opacity(0.05))
                                )
                            }
                        }
                        
                        // Male Option
                        VStack(spacing: 12) {
                            Text("Boy")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedGender == .male ? maleColor : Color.gray)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedGender = .male
                                }
                            }) {
                                ZStack {
                                    // รูปภาพ - ตัดเป็นวงกลมและซูมให้เต็มกรอบ
                                    Image("Male")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 130, height: 130)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    selectedGender == .male ? maleColor : Color.gray.opacity(0.3),
                                                    lineWidth: 4
                                                )
                                        )
                                }
                                .frame(width: 140, height: 160)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedGender == .male ? maleColor.opacity(0.1) : Color.gray.opacity(0.05))
                                )
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    
                    // Nickname Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nickname")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextField("", text: $nickname)
                            .font(.system(size: 16))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    
                    // Birthday Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birthday")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        DatePicker("", selection: $birthdate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        
                        Text("* Real age can quickly match accurate objects")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(cardBackground)
                        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // MARK: - Next Button
                Button(action: {
                    if !nickname.isEmpty {
                        // Action: Save profile and continue
                        print("Gender: \(selectedGender)")
                        print("Nickname: \(nickname)")
                        print("Birthday: \(birthdate)")
                        navigateToAge = true
                    }
                }) {
                    Text("Next")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(
                                    !nickname.isEmpty ?
                                    buttonColor :
                                    buttonColor.opacity(0.5)
                                )
                        )
                }
                .disabled(nickname.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                
                // NavigationLink - ย้ายมาอยู่ใน VStack
                NavigationLink(
                    destination: AgeView(),
                    isActive: $navigateToAge
                ) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .hidden()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationView {
        Profile()
    }
}
