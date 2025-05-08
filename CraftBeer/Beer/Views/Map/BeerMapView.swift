//
//  BeerMapView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 8/5/2568 BE.
//

import SwiftUI
import MapKit

struct BeerMapView: View {

    // 1️⃣ hard-coded bar list — add / edit as you like
    private let bars: [BarLocation] = [
        BarLocation(name: "Mikkeller Bangkok",
                    coordinate: .init(latitude: 13.772827, longitude: 100.590195)),
        BarLocation(name: "Tawandang German Brewery",
                    coordinate: .init(latitude: 13.723993, longitude: 100.587460)),
        BarLocation(name: "Taopiphop Bar Project",
                    coordinate: .init(latitude: 13.763625, longitude: 100.493213)),
        BarLocation(name: "Outlaw Brewing Chiang Mai Taproom",
                    coordinate: .init(latitude: 18.787691, longitude: 98.993262))
    ]

    // 2️⃣ map region — starts centered on Thailand
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 15.8700, longitude: 100.9925),
        span: MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 8)
    )

    var body: some View {
        NavigationStack {
            Map(coordinateRegion: $region, annotationItems: bars) { bar in
                MapMarker(coordinate: bar.coordinate, tint: .blue)
            }
            .ignoresSafeArea(edges: .top)
            .navigationTitle("Craft-Beer Bars")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
