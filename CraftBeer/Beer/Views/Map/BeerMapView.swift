//
//  BeerMapView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 8/5/2568 BE.
//

import SwiftUI
import MapKit
import UIKit

/// ObservableObject to request and publish the user’s current location.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocationCoordinate2D?
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async {
            self.location = loc.coordinate
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle errors if needed
        print("Location error:", error)
    }
}

/// Opens Apple Maps or Google Maps with driving directions to the given coordinate.
private func openExternalMaps(for bar: BarLocation) {
    let lat = bar.coordinate.latitude
    let lon = bar.coordinate.longitude
    // Try Google Maps first
    if let url = URL(string: "comgooglemaps://?daddr=\(lat),\(lon)&directionsmode=driving"),
       UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    } else if let appleURL = URL(string: "http://maps.apple.com/?daddr=\(lat),\(lon)&dirflg=d") {
        UIApplication.shared.open(appleURL)
    }
}

struct BeerMapView: View {

    // 1️⃣ hard-coded bar list — add / edit as you like
    private let bars: [BarLocation] = [
        BarLocation(
            name: "Beer Belly",
            coordinate: CLLocationCoordinate2D(latitude: 13.734768, longitude: 100.583120),
            imageURL: "https://firebasestorage.googleapis.com/v0/b/finalprojecswift.firebasestorage.app/o/barImages%2FBeer%20Belly.jpg?alt=media&token=36f06669-bf7b-4714-8d20-ecea38f076d0",
            address: "72 ถ. ทองหล่อ แขวงคลองตันเหนือ เขตวัฒนา กรุงเทพมหานคร 10110",
            hours: [
                "วันอาทิตย์ - วันอังคาร 18:00–0:00",
                "วันพฤหัสบดี - วันเสาร์ 18:00–3:00"
            ]
        ),
        BarLocation(
            name: "Belga Rooftop Bar & Brasserie",
            coordinate: CLLocationCoordinate2D(latitude: 13.739273, longitude: 100.557775),
            imageURL: "https://firebasestorage.googleapis.com/v0/b/finalprojecswift.firebasestorage.app/o/barImages%2FBelga%20Rooftop%20Bar%20%26%20Bresserie.jpg?alt=media&token=fe2c2aff-3b1c-4659-8776-f169d2a3efd5",
            address: "189 ถ. สุขุมวิท แขวงคลองเตยเหนือ เขตวัฒนา กรุงเทพมหานคร 10110",
            hours: [
                "ทุกวัน 17:00–1:00"
            ]
        ),
        BarLocation(
            name: "Brewski",
            coordinate: CLLocationCoordinate2D(latitude: 13.735290, longitude: 100.564098),
            imageURL: "https://firebasestorage.googleapis.com/v0/b/finalprojecswift.firebasestorage.app/o/barImages%2FBrewski.jpg?alt=media&token=f30650f8-ce4f-4dd2-a02c-46976b3d0891",
            address: "Radisson Blu Plaza Bangkok, 489 ถนนสุขุมวิท แขวงคลองเตยเหนือ เขตวัฒนา กรุงเทพมหานคร 10110",
            hours: [
                "ทุกวัน 17:00–2:00"
            ]
        ),
        BarLocation(
            name: "Save Our Souls Craft Beer",
            coordinate: CLLocationCoordinate2D(latitude: 13.724691, longitude: 100.508992),
            imageURL: "https://firebasestorage.googleapis.com/v0/b/finalprojecswift.firebasestorage.app/o/barImages%2FSave%20Our%20Souls%20Craft%20Beer.jpg?alt=media&token=97ceaea1-de74-4be6-a756-71c43c0e7d14",
            address: "ถ. เจริญนคร แขวงคลองต้นไทร คลองสาน กรุงเทพมหานคร 10600",
            hours: [
                "วันจันทร์ - วันศุกร์ 16:00–23:00",
                "วันเสาร์ - วันอาทิตย์ 12:00–23:00"
            ]
        ),
        BarLocation(
            name: "ไท่ซุนบาร์ (Tai Soon Bar)",
            coordinate: CLLocationCoordinate2D(latitude: 13.752512, longitude: 100.504524),
            imageURL: "https://firebasestorage.googleapis.com/v0/b/finalprojecswift.firebasestorage.app/o/barImages%2FTai%20Soon%20Bar.jpg?alt=media&token=952c3a61-5fd6-440e-8c2f-5d2aa8398639",
            address: "190 ถ. มหาไชย แขวงสำราญราษฎร์ เขตพระนคร กรุงเทพมหานคร 10200",
            hours: [
                "วันอังคาร - วันอาทิตย์ 18:00–1:00",
                "ปิดวันจันทร์"
            ]
        ),
        BarLocation(
            name: "Bottle Rocket",
            coordinate: CLLocationCoordinate2D(latitude: 13.730200, longitude: 100.534065),
            imageURL: "https://firebasestorage.googleapis.com/v0/b/finalprojecswift.firebasestorage.app/o/barImages%2FBottle%20Rocket.jpg?alt=media&token=d2e98a8d-b5f2-44d9-b3f0-610c135248c9",
            address: "942, 26 ถ. พระรามที่ 4 แขวงสุริยวงศ์ เขตบางรัก กรุงเทพมหานคร 10500",
            hours: [
                "วันจันทร์ - วันเสาร์ 18:00–2:00",
                "ปิดวันอาทิตย์"
            ]
        ),
        BarLocation(
            name: "โรงเบียร์สหประชาชื่น",
            coordinate: CLLocationCoordinate2D(latitude: 13.833508, longitude: 100.550844),
            imageURL: "https://firebasestorage.googleapis.com/v0/b/finalprojecswift.firebasestorage.app/o/barImages%2F%E0%B9%82%E0%B8%A3%E0%B8%87%E0%B9%80%E0%B8%9A%E0%B8%B5%E0%B8%A2%E0%B8%A3%E0%B9%8C%E0%B8%AA%E0%B8%AB%E0%B8%9B%E0%B8%A3%E0%B8%B0%E0%B8%8A%E0%B8%B2%E0%B8%8A%E0%B8%B7%E0%B9%88%E0%B8%99.jpg?alt=media&token=39474c3f-2a77-483d-a8bb-bbeadd18644c",
            address: "109 เทศบาลนิมิตใต้ ซอย 1 แขวงลาดยาว เขตจตุจักร กรุงเทพมหานคร 10900",
            hours: [
                "ทุกวัน 11:00–23:00"
            ]
        ),
        BarLocation(
            name: "Highland Café",
            coordinate: CLLocationCoordinate2D(latitude: 13.812985, longitude: 100.560576),
            imageURL: "https://firebasestorage.googleapis.com/v0/b/finalprojecswift.firebasestorage.app/o/barImages%2FHighland%20Cafe%CC%81.jpg?alt=media&token=0a2638c0-89d4-4961-867d-8dfd918e034a",
            address: "12 7 ถ. ลาดพร้าว แขวงจอมพล เขตจตุจักร กรุงเทพมหานคร 10900",
            hours: [
                "วันจันทร์ - วันศุกร์ 7:00–18:00",
                "วันเสาร์ 8:00–17:00",
                "ปิดวันอาทิตย์"
            ]
        ),
        BarLocation(
            name: "Yolo Craft Beer Bar",
            coordinate: CLLocationCoordinate2D(latitude: 13.763615, longitude: 100.495655),
            imageURL: "https://firebasestorage.googleapis.com/v0/b/finalprojecswift.firebasestorage.app/o/barImages%2FYolo%20Craft%20Beer%20Bar.jpg?alt=media&token=080f6bb2-6895-4640-bdc9-f8503820a1a9",
            address: "140 ถนน พระสุเมรุ แขวงชนะสงคราม เขตพระนคร กรุงเทพมหานคร 10200 ",
            hours: [
                "ทุกวัน 17:00–1:00"
            ]
        ),
        BarLocation(
            name: "Beerable",
            coordinate: CLLocationCoordinate2D(latitude: 13.778660, longitude: 100.576763),
            imageURL: "https://firebasestorage.googleapis.com/v0/b/finalprojecswift.firebasestorage.app/o/barImages%2FBeerable.jpg?alt=media&token=d6513f65-0a77-4d8c-8d4c-3c1e21a50407",
            address: "251 ถ. ประชาราษฎร์บำเพ็ญ แขวงห้วยขวาง เขตห้วยขวาง กรุงเทพมหานคร 10310",
            hours: [
                "วันจันทร์ - วันศุกร์ 17:00–1:00",
                "วันเสาร์ - วันอาทิตย์ 15:00–1:00"
            ]
        ),
        
    ]

    // 2️⃣ map region — starts centered on Thailand
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 15.8700, longitude: 100.9925),
        span: MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 8)
    )

    @State private var trackingMode: MapUserTrackingMode = .none

    @StateObject private var locationManager = LocationManager()
    @State private var selectedBar: BarLocation? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                // 1️⃣ Map with user tracking
                Map(
                    coordinateRegion: $region,
                    showsUserLocation: true,
                    userTrackingMode: $trackingMode,
                    annotationItems: bars
                ) { bar in
                    MapAnnotation(coordinate: bar.coordinate) {
                        VStack(spacing: 4) {
                            // 1️⃣ Show callout bubble when this bar is selected
                            if selectedBar?.id == bar.id {
                                VStack(spacing: 4) {
                                    Text(bar.name)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    // you can add Image(uiImage:) or more details here if desired
                                }
                                .padding(8)
                                .background(Color.primaryColor)
                                .cornerRadius(8)
                                .onTapGesture {
                                    // Open external maps when tapping the bubble
                                    openExternalMaps(for: bar)
                                }
                            }

                            // 2️⃣ Pin icon toggles selection
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(Color.primaryColor)
                                .onTapGesture {
                                    // Toggle this bar as the selected one
                                    if selectedBar?.id == bar.id {
                                        selectedBar = nil
                                    } else {
                                        selectedBar = bar
                                    }
                                }
                        }
                    }
                }
                
                // 2️⃣ Locate Me Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            // center map on user location
                            if let userLoc = locationManager.location {
                                region.center = userLoc
                                trackingMode = .follow
                            }
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .padding()
                                .background(Color.surfaceColor)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .sheet(item: $selectedBar) { bar in
                BarDetailSheet(bar: bar)
            }
            .onReceive(locationManager.$location.compactMap { $0 }) { loc in
                // Only recenter when in follow mode
                if trackingMode == .follow {
                    region.center = loc
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationTitle("Craft-Beer Bars")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BarDetailSheet: View {
    let bar: BarLocation

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(bar.name)
                .font(.title2.bold())
            
            if let url = URL(string: bar.imageURL), !bar.imageURL.isEmpty {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 150)
                .clipped()
                .cornerRadius(8)
            }

            Text(bar.address)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

            Divider()

            Text("Hours")
                .font(.headline)

            ForEach(bar.hours, id: \.self) { line in
                Text(line)
                    .font(.body)
            }
            
            Divider()
            
            Button(action: {
                openExternalMaps(for: bar)
            }) {
                HStack {
                    Image(systemName: "map.fill")
                    Text("Get Directions")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
        .presentationDetents([.height(600)])
    }
}
