//
// ClinicsNearMeView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 31/10/2568 BE.
//

//
// ClinicsNearMeView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 31/10/2568 BE.
//

import SwiftUI
import MapKit

// MARK: - Clinic Model
struct Clinic: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let phone: String
    let rating: Double
    let reviewCount: Int
    let distance: String
    let coordinate: CLLocationCoordinate2D
    let isOpen: Bool
    let openingHours: String
}

// MARK: - Clinic Annotation
struct ClinicAnnotation: Identifiable {
    let id = UUID()
    let clinic: Clinic
}

struct ClinicsNearMeView: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018), // กรุงเทพ
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedClinic: Clinic?
    @State private var showClinicDetail = false
    @State private var searchText = ""
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // ม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียวมะนาว
    let cardBackground = Color(red: 248/255, green: 247/255, blue: 241/255) // ครีม
    
    // --- Sample Clinics Data ---
    let clinics: [Clinic] = [
        Clinic(
            name: "คลินิกกายภาพบำบัด เฮลท์แคร์",
            address: "123 ถนนสุขุมวิท แขวงคลองเตย กรุงเทพฯ 10110",
            phone: "02-123-4567",
            rating: 4.5,
            reviewCount: 128,
            distance: "0.8 km",
            coordinate: CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018),
            isOpen: true,
            openingHours: "เปิด 09:00 - 20:00"
        ),
        Clinic(
            name: "ศูนย์กายภาพบำบัด วิทยาการ",
            address: "456 ถนนพระราม 4 แขวงคลองเตย กรุงเทพฯ 10110",
            phone: "02-234-5678",
            rating: 4.8,
            reviewCount: 256,
            distance: "1.2 km",
            coordinate: CLLocationCoordinate2D(latitude: 13.7463, longitude: 100.5118),
            isOpen: true,
            openingHours: "เปิด 08:00 - 19:00"
        ),
        Clinic(
            name: "คลินิกกายภาพ แอดวานซ์",
            address: "789 ถนนเพชรบุรี แขวงมักกะสัน กรุงเทพฯ 10400",
            phone: "02-345-6789",
            rating: 4.3,
            reviewCount: 89,
            distance: "2.1 km",
            coordinate: CLLocationCoordinate2D(latitude: 13.7663, longitude: 100.4918),
            isOpen: false,
            openingHours: "ปิด • เปิด 10:00"
        ),
        Clinic(
            name: "ศูนย์ฟื้นฟูสุขภาพ โปร เฮลท์",
            address: "321 ถนนอโศก แขวงคลองเตย กรุงเทพฯ 10110",
            phone: "02-456-7890",
            rating: 4.7,
            reviewCount: 342,
            distance: "1.5 km",
            coordinate: CLLocationCoordinate2D(latitude: 13.7363, longitude: 100.5218),
            isOpen: true,
            openingHours: "เปิด 07:00 - 21:00"
        )
    ]
    
    var body: some View {
        ZStack {
            // MARK: - Map View
            Map(coordinateRegion: $region, annotationItems: clinics.map { ClinicAnnotation(clinic: $0) }) { annotation in
                MapAnnotation(coordinate: annotation.clinic.coordinate) {
                    ClinicMapPin(
                        clinic: annotation.clinic,
                        isSelected: selectedClinic?.id == annotation.clinic.id,
                        accentColor: accentColor
                    )
                    .onTapGesture {
                        withAnimation {
                            selectedClinic = annotation.clinic
                            showClinicDetail = true
                        }
                    }
                }
            }
            .ignoresSafeArea()
            
            // MARK: - Top Overlay
            VStack(spacing: 0) {
                // Top Bar
                topBar
                
                // Search Bar
                searchBar
                
                Spacer()
                
                // Bottom Clinic Detail Sheet
                if showClinicDetail, let clinic = selectedClinic {
                    clinicDetailCard(clinic: clinic)
                        .transition(.move(edge: .bottom))
                }
            }
            
            // MARK: - Current Location Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // TODO: Get current location
                        print("Get current location")
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            .overlay(
                                Image(systemName: "location.fill")
                                    .font(.title3)
                                    .foregroundColor(accentColor)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, showClinicDetail ? 280 : 100)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.body)
                            .foregroundColor(backgroundColor)
                    )
            }
            Spacer()
            Text("คลินิกกายภาพใกล้ฉัน")
                .font(.headline)
                .foregroundColor(backgroundColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.95))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            Spacer()
            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search Location", text: $searchText)
                .foregroundColor(backgroundColor)
            
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(accentColor)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    // MARK: - Clinic Detail Card
    private func clinicDetailCard(clinic: Clinic) -> some View {
        VStack(spacing: 0) {
            // Drag Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack(alignment: .top, spacing: 12) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(accentColor.opacity(0.2))
                                .frame(width: 60, height: 60)
                            Image(systemName: "cross.case.fill")
                                .font(.title2)
                                .foregroundColor(accentColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(clinic.name)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(backgroundColor)
                            
                            HStack(spacing: 4) {
                                Image(systemName: clinic.isOpen ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(clinic.isOpen ? .green : .red)
                                    .font(.caption)
                                Text(clinic.openingHours)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        // Close Button
                        Button(action: {
                            withAnimation {
                                showClinicDetail = false
                                selectedClinic = nil
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Rating & Distance
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text(String(format: "%.1f", clinic.rating))
                                .font(.body)
                                .fontWeight(.semibold)
                            Text("(\(clinic.reviewCount))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text("•")
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .foregroundColor(accentColor)
                                .font(.caption)
                            Text(clinic.distance)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider()
                    
                    // Address
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(primaryColor)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ที่อยู่")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(clinic.address)
                                .font(.body)
                                .foregroundColor(backgroundColor)
                        }
                        Spacer()
                    }
                    
                    // Phone
                    HStack(spacing: 12) {
                        Image(systemName: "phone.circle.fill")
                            .foregroundColor(accentColor)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("โทรศัพท์")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(clinic.phone)
                                .font(.body)
                                .foregroundColor(backgroundColor)
                        }
                        Spacer()
                        Button(action: {
                            // TODO: Call phone
                            if let url = URL(string: "tel://\(clinic.phone.replacingOccurrences(of: "-", with: ""))") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(accentColor)
                                .clipShape(Circle())
                        }
                    }
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            // TODO: Open in Maps
                            openInMaps(clinic: clinic)
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("เส้นทาง")
                            }
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(primaryColor)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // TODO: Share
                            print("Share clinic info")
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("แชร์")
                            }
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(primaryColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(primaryColor.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(20)
            }
            .frame(maxHeight: 400)
        }
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: -5)
    }
    
    // MARK: - Helper Function
    private func openInMaps(clinic: Clinic) {
        let coordinate = clinic.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = clinic.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

// MARK: - Clinic Map Pin
struct ClinicMapPin: View {
    let clinic: Clinic
    let isSelected: Bool
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: isSelected ? 60 : 50, height: isSelected ? 60 : 50)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Circle()
                    .fill(accentColor)
                    .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)
                
                Image(systemName: "cross.case.fill")
                    .font(.system(size: isSelected ? 24 : 20))
                    .foregroundColor(.white)
            }
            
            // Pin bottom
            Triangle()
                .fill(Color.white)
                .frame(width: 20, height: 10)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath() // ✅ ใช้ closeSubpath() ตัวพิมพ์เล็ก
        return path
    }
}

// MARK: - Custom Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ClinicsNearMeView()
    }
}
