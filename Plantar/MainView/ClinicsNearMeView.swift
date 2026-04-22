//
// ClinicsNearMeView.swift
// Plantar
//
// Created by Jeerapan Chirachanchai on 31/10/2568 BE.
//

import SwiftUI
import MapKit
import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
// MARK: - 1. Location Manager (คลาสสำหรับจัดการตำแหน่ง)
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // ขออนุญาตใช้ตำแหน่ง (อย่าลืมเพิ่ม Privacy Key ใน Info.plist)
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location Error: \(error.localizedDescription)")
    }
}

// MARK: - Clinic Model
struct Clinic: Identifiable, Decodable {
    let id: UUID
    let name: String
    let address: String
    let phone: String
    let rating: Double
    let reviewCount: Int
    
    // แยก lat/long เพราะใน DB เก็บแยกกัน
    let latitude: Double
    let longitude: Double
    
    let isOpen: Bool
    let openingHours: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, phone, rating
        case reviewCount = "review_count"
        case latitude, longitude
        case isOpen = "is_open"
        case openingHours = "opening_hours"
    }
    
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    
    func calculateDistance(from userLocation: CLLocationCoordinate2D?) -> String {
        guard let userLoc = userLocation else { return "..." } // ถ้ายังไม่มีพิกัดผู้ใช้ ให้โชว์ ...
        
        let clinicLocation = CLLocation(latitude: latitude, longitude: longitude)
        let myLocation = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        
        // คำนวณระยะทางเป็นเมตร
        let distanceInMeters = clinicLocation.distance(from: myLocation)
        
        // จัดรูปแบบการแสดงผล
        if distanceInMeters < 1000 {
            return String(format: "%.0f ม.", distanceInMeters) // ถ้าน้อยกว่า 1 กม. โชว์เป็นเมตร
        } else {
            return String(format: "%.1f กม.", distanceInMeters / 1000) // ถ้าเกิน 1 กม. โชว์เป็นกิโลเมตร
        }
    }
    
    var isNowOpen: Bool {
        // 1. ดึงเวลาปัจจุบันของเครื่อง
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTimeValue = (currentHour * 60) + currentMinute // แปลงเป็นนาที (เช่น 10:30 -> 630)
        
        // 2. แกะเวลาจาก string (เช่น "เปิด 09:00 - 20:00")
        // หาตัวเลขชุดที่เป็นเวลา (HH:mm)
        let pattern = #"(\d{1,2}):(\d{2})"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return isOpen }
        let nsString = openingHours as NSString
        let results = regex.matches(in: openingHours, options: [], range: NSRange(location: 0, length: nsString.length))
        
        // ต้องเจอเวลาอย่างน้อย 2 ชุด (เวลาเปิด และ เวลาปิด)
        if results.count >= 2 {
            // เวลาเปิด (Start)
            let startMatch = results[0]
            let startHour = Int(nsString.substring(with: startMatch.range(at: 1))) ?? 0
            let startMin = Int(nsString.substring(with: startMatch.range(at: 2))) ?? 0
            let startTimeValue = (startHour * 60) + startMin
            
            // เวลาปิด (End)
            let endMatch = results[1]
            let endHour = Int(nsString.substring(with: endMatch.range(at: 1))) ?? 0
            let endMin = Int(nsString.substring(with: endMatch.range(at: 2))) ?? 0
            let endTimeValue = (endHour * 60) + endMin
            
            // 3. เปรียบเทียบ: เวลาปัจจุบันต้องอยู่ระหว่าง เริ่ม และ จบ
            return currentTimeValue >= startTimeValue && currentTimeValue < endTimeValue
        }
        
        // ถ้าแกะเวลาไม่ได้ ให้ยึดค่าตาม DB ไปก่อน
        return isOpen
    }
}

struct ClinicsNearMeView: View {
    // --- Environment ---
    @Environment(\.dismiss) private var dismiss
    
    // --- Managers ---
    @StateObject private var locationManager = LocationManager()
    
    // --- State Variables ---
    // ปักหมุดเริ่มต้นที่กรุงเทพฯ (แถวสยาม/ปทุมวัน เพื่อให้เห็นคลินิกทั่วถึง)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 13.7469, longitude: 100.5349),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    @State private var selectedClinic: Clinic?
    @State private var showClinicDetail = false
    @State private var searchText = ""
    @State private var clinics: [Clinic] = []
    
    // --- Custom Colors ---
    let backgroundColor = Color(red: 94/255, green: 84/255, blue: 68/255) // น้ำตาล
    let primaryColor = Color(red: 139/255, green: 122/255, blue: 184/255) // ม่วง
    let accentColor = Color(red: 172/255, green: 187/255, blue: 98/255) // เขียวมะนาว
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Map View
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: clinics.filter {
                    let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    return keyword.isEmpty ||
                    $0.name.localizedCaseInsensitiveContains(keyword) ||
                    $0.address.localizedCaseInsensitiveContains(keyword)
                }
            ) { clinic in
                MapAnnotation(coordinate: clinic.coordinate) {
                    ClinicMapPin(
                        clinic: clinic,
                        isSelected: selectedClinic?.id == clinic.id,
                        accentColor: clinic.isNowOpen ? accentColor : .gray
                    )
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedClinic = clinic
                            showClinicDetail = true
                        }
                    }
                }
            }
            .ignoresSafeArea()
            
            // MARK: - Top Overlay (UI ส่วนบน)
            VStack(spacing: 0) {
                topBar
                searchBar
                Spacer()
            }
            
            // MARK: - Current Location Button
            if !showClinicDetail {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            print("📍 Requesting location...")
                            locationManager.requestLocation()
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                                .overlay(
                                    Image(systemName: "location.fill")
                                        .font(.title3)
                                        .foregroundColor(accentColor)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            
            // MARK: - Bottom Clinic Detail Sheet (UI ส่วนล่าง)
            if showClinicDetail, let clinic = selectedClinic {
                // ✅ ห่อด้วย VStack และใช้ Spacer() เพื่อดันขึ้นจากด้านล่าง
                VStack {
                    Spacer()
                    clinicDetailCard(clinic: clinic)
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
                .ignoresSafeArea(edges: .bottom) // ✅ ย้ายมาไว้ที่นี่แทน
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await fetchClinics()
        }
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: locationManager.userLocation) { newLocation in
            if let location = newLocation {
                withAnimation {
                    region.center = location
                    region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                }
            }
        }
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
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.95))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            Spacer()
            // Placeholder เพื่อให้ Title อยู่ตรงกลาง
            Circle().fill(Color.clear).frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16) // ปรับตาม SafeArea
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            
            TextField("ค้นหาคลินิก, โรงพยาบาล...", text: $searchText)
                .foregroundColor(backgroundColor)
            
            // ❌ ปุ่มลบ
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            // 🔍 ปุ่ม search (อยู่ขวาสุด)
            Button(action: {
                // trigger search (จริง ๆ SwiftUI filter อัตโนมัติอยู่แล้ว)
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(accentColor)
                    .cornerRadius(10)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(15)
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
                    // Header Info
                    HStack(alignment: .top, spacing: 14) {
                        // Icon Image
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(accentColor.opacity(0.15))
                                .frame(width: 64, height: 64)
                            Image(systemName: "cross.case.fill")
                                .font(.title)
                                .foregroundColor(accentColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(clinic.name)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(backgroundColor)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack(spacing: 6) {
                                Label(clinic.isNowOpen ? "เปิดอยู่" : "ปิดแล้ว", systemImage: "clock.fill")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(clinic.isNowOpen ? .green : .red)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        (clinic.isNowOpen ? Color.green : Color.red).opacity(0.1)
                                    )
                                    .cornerRadius(6)
                                
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
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                    }
                    
                    Divider()
                    
                    // Stats Row
                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").foregroundColor(.orange)
                            Text(String(format: "%.1f", clinic.rating))
                                .fontWeight(.bold)
                            Text("(\(clinic.reviewCount))").foregroundColor(.gray)
                        }
                        .font(.subheadline)
                        
                        ContainerRelativeShape()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1, height: 16)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill").foregroundColor(accentColor)
                            Text(clinic.calculateDistance(from: locationManager.userLocation))
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                    
                    // Contact Info
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(primaryColor)
                                .frame(width: 24)
                            Text(clinic.address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        HStack(alignment: .center, spacing: 12) {
                            Image(systemName: "phone.fill")
                                .foregroundColor(accentColor)
                                .frame(width: 24)
                            Text(clinic.phone)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(action: {
                                if let url = URL(string: "tel://\(clinic.phone.replacingOccurrences(of: "-", with: ""))") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("โทร")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(accentColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(accentColor.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Primary Action Buttons
                    HStack(spacing: 12) {
                        Button(action: { openInMaps(clinic: clinic) }) {
                            HStack {
                                Image(systemName: "location.circle.fill")
                                Text("นำทาง")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(primaryColor)
                            .cornerRadius(16)
                        }
                        
                    }
                }
                .padding(24)
            }
            .frame(maxHeight: 400)
        }
        .background(Color.white) // ✅ ลบ modifiers ที่เกี่ยวกับ safeArea ออกหมด
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: -5)
    }
    
    // MARK: - Helper Function
    private func openInMaps(clinic: Clinic) {
        let coordinate = clinic.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = clinic.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    // MARK: - Fetch Function
    func fetchClinics() async {
        print("🔄 กำลังโหลดข้อมูลคลินิก...") // 1. เช็คว่าฟังก์ชันถูกเรียกไหม
        
        do {
            let fetchedClinics: [Clinic] = try await UserProfile.supabase
                .from("clinics")
                .select()
                .execute()
                .value
            
            print("✅ โหลดสำเร็จ! เจอคลินิกจำนวน: \(fetchedClinics.count) แห่ง") // 2. เช็คว่าได้ข้อมูลกี่ตัว
            
            if let first = fetchedClinics.first {
                print("📍 ตัวอย่าง: \(first.name) lat: \(first.latitude), long: \(first.longitude)")
            }
            
            await MainActor.run {
                self.clinics = fetchedClinics
            }
        } catch {
            print("❌ Error fetching clinics: \(error)") // 3. ถ้าพัง ให้ดู error ตรงนี้
        }
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
                // Outer glow when selected
                if isSelected {
                    Circle()
                        .fill(accentColor.opacity(0.3))
                        .frame(width: 70, height: 70)
                }
                
                // White border
                Circle()
                    .fill(Color.white)
                    .frame(width: isSelected ? 56 : 44, height: isSelected ? 56 : 44)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                
                // Inner color
                Circle()
                    .fill(isSelected ? accentColor : Color(red: 94/255, green: 84/255, blue: 68/255)) // สีเขียวเมื่อเลือก สีน้ำตาลเมื่อปกติ
                    .frame(width: isSelected ? 48 : 36, height: isSelected ? 48 : 36)
                
                // Icon
                Image(systemName: "cross.case.fill")
                    .font(.system(size: isSelected ? 22 : 16))
                    .foregroundColor(.white)
            }
            
            // Pin Triangle
            Triangle()
                .fill(Color.white)
                .frame(width: 16, height: 10)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                .offset(y: -4) // ดึงขึ้นนิดนึงให้ติดกับวงกลม
        }
        .offset(y: -30) // ยก Pin ขึ้นเพื่อให้ปลายแหลมชี้ที่พิกัดพอดี
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
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
