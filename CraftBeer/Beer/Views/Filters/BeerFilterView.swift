//
//  BeerFilterView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import SwiftUI
import Firebase
import Kingfisher


struct BeerFilterView: View {
    @Binding var activeFilters: [String: Any]
    let applyFilters: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedStyles: Set<String> = []
    @State private var selectedBreweries: Set<String> = []
    @State private var abvMin: Double = 0
    @State private var abvMax: Double = 15
    
    // Populate with your own beer styles and breweries
    let availableStyles = ["Stout", "Lager", "Pale Ale", "Wheat Ale", "White Ale", "India Pale Ale", "Pilsner", "Fruited Sour", "Herb/Spieced Ale", "Sigle-Hop IPA", "Red IPA", "Imperial Red Ale", "Hefeweizen", "New England IPA", "Sour Pale Ale", "Fruit Beer", "Belgian Witbier", "Golden Ale", "Cream Ale"]
    let availableBreweries = ["Outlaw Brewing", "Mahanakhon Brewery", "Full Moon Brewworks", "Chitbeer", "Wizard Beer", "Sandport Brewery", "Devanom Brewery", "Stone Head Brewery", "Chiang Mai Beer", "72 Brewing", "Eleventh Fort Brewing", "Team Alpha Brewing", "Chant'LA จันฑ'ลา", "Samata Brewing", "Sriracha Brew", "Chiang Mai Brewery", "Sivilai", "Muay Thai Craft", "Beach Boys Brewery"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Beer Style")) {
                    ForEach(availableStyles, id: \.self) { style in
                        Button(action: {
                            if selectedStyles.contains(style) {
                                selectedStyles.remove(style)
                            } else {
                                selectedStyles.insert(style)
                            }
                        }) {
                            HStack {
                                Text(style)
                                Spacer()
                                if selectedStyles.contains(style) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section(header: Text("Brewery")) {
                    ForEach(availableBreweries, id: \.self) { brewery in
                        Button(action: {
                            if selectedBreweries.contains(brewery) {
                                selectedBreweries.remove(brewery)
                            } else {
                                selectedBreweries.insert(brewery)
                            }
                        }) {
                            HStack {
                                Text(brewery)
                                Spacer()
                                if selectedBreweries.contains(brewery) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section(
                  header: Text("ABV Range: \(String(format: "%.1f", abvMin))% - \(String(format: "%.1f", abvMax))%")
                ) {
                    Slider(value: $abvMin, in: 0...abvMax, step: 0.5)
                    Slider(value: $abvMax, in: abvMin...15, step: 0.5)
                }
                
                Section {
                    Button("Reset Filters") {
                        selectedStyles.removeAll()
                        selectedBreweries.removeAll()
                        activeFilters["abvMin"] = abvMin
                        activeFilters["abvMax"] = abvMax
                    }
                }
            }
            .navigationTitle("Filter Beers")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        // Update active filters
                        if !selectedStyles.isEmpty {
                            activeFilters["styles"] = Array(selectedStyles)
                        } else {
                            activeFilters.removeValue(forKey: "styles")
                        }
                        
                        if !selectedBreweries.isEmpty {
                            activeFilters["breweries"] = Array(selectedBreweries)
                        } else {
                            activeFilters.removeValue(forKey: "breweries")
                        }
                        
                        // Apply button
                        activeFilters["abvMin"] = abvMin
                        activeFilters["abvMax"] = abvMax
                        
                        applyFilters()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                // Load existing filters
                if let styles = activeFilters["styles"] as? [String] {
                    selectedStyles = Set(styles)
                }
                
                if let breweries = activeFilters["breweries"] as? [String] {
                    selectedBreweries = Set(breweries)
                }
                
                if let min = activeFilters["abvMin"] as? Double,
                   let max = activeFilters["abvMax"] as? Double {
                    abvMin = min
                    abvMax = max
                }
            }
        }
    }
}
