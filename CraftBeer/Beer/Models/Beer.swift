//
//  Beer.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import Foundation
import CoreLocation
import FirebaseFirestore   // for @DocumentID
import FirebaseCore

/// Craft-beer entity pulled from Firestore’s **“beers”** collection.
struct Beer: Identifiable, Codable {
    
    // MARK: – Firestore fields
    @DocumentID var id: String?         // Firestore doc ID
    
    var name:         String            // “Juice Juice IPA”
    var style:        String            // “IPA”, “Stout”, …
    var brewery:      String            // “Outlaw Brewing”
    var description:  String            // full description / tasting notes
    var image:        String            // HTTPS URL string
    
    var abv:          Double            // 5.5 → 5.5 % ABV
    var ibu:          Double?           // optional bitterness
    var releaseYear:  Int?              // optional first-release year
}

struct BeerLogEntry: Identifiable, Codable {
    @DocumentID var id: String?               // Firestore doc-id
    var userId:   String
    var beerId:   String
    var beerName: String
    var rating:   Double
    var notes:    String
    var loggedDate: Date
}

struct BarLocation: Identifiable {
    let id   = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let imageURL: String
    let address: String
    let hours: [String]
}
