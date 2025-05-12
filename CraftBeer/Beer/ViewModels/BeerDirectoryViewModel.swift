//
//  BeerDirectoryView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import SwiftUI
import Firebase
import Kingfisher


class BeerDirectoryViewModel: ObservableObject {
    @Published var beers: [Beer] = []
    @Published var isLoading = false
    @Published var activeFilters: [String: Any] = [:]
    @Published var errorMessage: ErrorMessage?
    
    private var allBeers: [Beer] = []
    
    func fetchBeers() {
        isLoading = true

        FirebaseService.shared.fetchBeers { [weak self] (beers: [Beer]?, error: Error?) in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = ErrorMessage(message: "Failed to load beers: \(error.localizedDescription)")
                    return
                }

                self?.allBeers = beers ?? []
                self?.applyFilters()
            }
        }
    }
    
    func applyFilters() {
        var filteredBeers = allBeers
        
        // Filter by style
        if let styles = activeFilters["styles"] as? [String], !styles.isEmpty {
            filteredBeers = filteredBeers.filter { beer in
                styles.contains(beer.style)
            }
        }
        
        // Filter by brewery
        if let breweries = activeFilters["breweries"] as? [String], !breweries.isEmpty {
            filteredBeers = filteredBeers.filter { beer in
                breweries.contains(beer.brewery)
            }
        }
        
        // Filter by ABV range
        if let abvMin = activeFilters["abvMin"] as? Double,
           let abvMax = activeFilters["abvMax"] as? Double {
            filteredBeers = filteredBeers.filter { beer in
                beer.abv >= abvMin && beer.abv <= abvMax
            }
        }
        
        // Sort results if requested
        if let sort = activeFilters["sortBy"] as? String {
            switch sort {
            case "nameAsc":
                filteredBeers.sort {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
            case "abvLow":
                filteredBeers.sort { $0.abv < $1.abv }
            case "abvHigh":
                filteredBeers.sort { $0.abv > $1.abv }
            default:
                break
            }
        }
        
        self.beers = filteredBeers
    }
}
