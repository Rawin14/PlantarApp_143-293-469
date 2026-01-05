//
//  TermsView.swift
//  Plantar
//
//  Created by Jeerapan Chirachanchai on 4/1/2569 BE.
//

import SwiftUI

struct TermsView: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // ✅ 1. เพิ่มตัวแปรนี้เพื่อให้สื่อสารกับ PlantarApp (ชื่อต้องตรงกันเป๊ะ)
    @AppStorage("isTermsAccepted") var isTermsAccepted: Bool = false
    
    // --- State ---
    @State private var isAccepted: Bool = false // เช็คว่าติ๊กถูกหรือยัง
    @State private var showBounceAnimation: Bool = false // Animation เตือนถ้าไม่ติ๊ก
    
    // --- Theme Colors ---
    let backgroundColor = Color(red: 248/255, green: 247/255, blue: 241/255) // ครีม
    let primaryColor = Color(red: 94/255, green: 84/255, blue: 68/255)     // น้ำตาล
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255)    // เขียว
    
    var body: some View {
        ZStack {
            // Background
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Text("ข้อกำหนดและนโยบาย")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                    Spacer()
                    Image(systemName: "doc.text.fill")
                        .font(.title2)
                        .foregroundColor(accentColor)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // MARK: - Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Intro Text
                        Text("แอปพลิเคชันนี้ให้ความสำคัญกับการคุ้มครองข้อมูลส่วนบุคคลและข้อมูลด้านสุขภาพของผู้ใช้งานเป็นอย่างยิ่ง")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 24)
                        
                        // --- Section 1 ---
                        TermCard(title: "1. ข้อมูลที่เก็บรวบรวม", content: """
                        • ข้อมูลส่วนบุคคล (อายุ, เพศ)
                        • ข้อมูลสุขภาพ (น้ำหนัก, ส่วนสูง, BMI)
                        • ภาพถ่ายฝ่าเท้าจากการประเมิน
                        • ข้อมูลการใช้งานภายในแอป
                        """, icon: "folder.fill", color: primaryColor)
                        
                        // --- Section 2 ---
                        TermCard(title: "2. วัตถุประสงค์การใช้งาน", content: """
                        • เพื่อประเมินสภาพฝ่าเท้าเบื้องต้น
                        • วิเคราะห์และแสดงผลข้อมูลสุขภาพ
                        • แนะนำแนวทางการดูแลรักษา
                        • พัฒนาประสิทธิภาพของแอป
                        """, icon: "target", color: primaryColor)
                        
                        // --- Section 3: Warning ---
                        WarningCard(content: "แอปนี้สำหรับการประเมินเบื้องต้นเท่านั้น ไม่ใช่การวินิจฉัยทางการแพทย์ หากมีอาการผิดปกติรุนแรง โปรดปรึกษาแพทย์โดยตรง")
                        
                        // --- Other Sections ---
                        TermCard(title: "ข้อกำหนดอื่นๆ", content: """
                        4. การใช้กล้อง: ใช้เพื่อประเมินฝ่าเท้าเท่านั้น
                        5. ความยินยอม: ท่านสามารถถอนความยินยอมได้
                        6. ความปลอดภัย: เก็บข้อมูลด้วยมาตรฐานความปลอดภัย
                        7. การเก็บรักษา: เก็บตลอดระยะเวลาการใช้งาน
                        8. การเปิดเผย: ไม่เปิดเผยแก่บุคคลภายนอก
                        """, icon: "list.bullet.clipboard", color: primaryColor)
                        
                        // --- Plantar Specific Terms ---
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ข้อตกลงเฉพาะสำหรับแอป Plantar")
                                .font(.headline)
                                .foregroundColor(primaryColor)
                                .padding(.bottom, 4)
                            
                            ForEach(plantarTerms, id: \.self) { term in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(accentColor)
                                        .font(.subheadline)
                                        .padding(.top, 2)
                                    Text(term)
                                        .font(.subheadline)
                                        .foregroundColor(.black.opacity(0.7))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 100) // เว้นที่ให้ปุ่มด้านล่าง
                    }
                    .padding(.top, 10)
                }
                
                // MARK: - Bottom Action Bar
                VStack(spacing: 16) {
                    Divider()
                    
                    // Checkbox
                    Button(action: {
                        withAnimation(.spring()) {
                            isAccepted.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: isAccepted ? "checkmark.square.fill" : "square")
                                .font(.title3)
                                .foregroundColor(isAccepted ? accentColor : .gray)
                            
                            Text("ฉันได้อ่านและยอมรับข้อกำหนดทั้งหมด")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                    .scaleEffect(showBounceAnimation ? 1.1 : 1.0)
                    .animation(.spring(dampingFraction: 0.5), value: showBounceAnimation)
                    
                    // Accept Button
                    Button(action: {
                        if isAccepted {
                            // ✅ 2. สั่งเปลี่ยนค่า AppStorage
                            // PlantarApp จะรู้ทันทีและสลับหน้าไป Profile() ให้
                            withAnimation {
                                isTermsAccepted = true
                            }
                        } else {
                            // แจ้งเตือนให้กด Checkbox
                            showBounceAnimation = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                showBounceAnimation = false
                            }
                        }
                    }) {
                        Text("ยอมรับและเริ่มใช้งาน")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isAccepted ? primaryColor : Color.gray.opacity(0.5))
                            .cornerRadius(15)
                            .shadow(color: isAccepted ? primaryColor.opacity(0.3) : .clear, radius: 5, x: 0, y: 5)
                    }
                    .disabled(!isAccepted)
                }
                .padding(24)
                .background(Color.white.ignoresSafeArea(edges: .bottom))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
            }
        }
        .navigationBarHidden(true)
    }
    
    // ข้อมูลข้อตกลงเฉพาะ
    private let plantarTerms = [
        "พัฒนาเพื่อช่วยบรรเทาอาการรองช้ำเบื้องต้น",
        "เป็นข้อมูลดูแลตนเอง ไม่ใช่การรักษาทางการแพทย์",
        "ไม่สามารถทดแทนคำแนะนำจากแพทย์ได้",
        "มุ่งเน้นลดค่าใช้จ่ายในการดูแลรักษาเบื้องต้น"
    ]
}

// MARK: - Components (เหมือนเดิม)

struct TermCard: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.black.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 24)
    }
}

struct WarningCard: View {
    let content: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("ข้อจำกัดสำคัญ")
                    .font(.headline)
                    .foregroundColor(.orange)
                Text(content)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
}

#Preview {
    TermsView()
}
