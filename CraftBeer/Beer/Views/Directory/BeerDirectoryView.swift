//
//  BeerDirectoryView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import SwiftUI
import Firebase
import Kingfisher
import FirebaseAuth
import FirebaseFirestore
import Foundation
import WaterfallGrid

struct BeerDirectoryView: View {
    @StateObject private var viewModel = BeerDirectoryViewModel()
    @State private var searchText = ""
    @State private var isFilterSheetPresented = false

    // Recommendations based on favorites
    @StateObject private var favVM = BeerFavoritesViewModel()

    /// Compute top-favorite style and recommend beers matching it
    private var recommendedBeers: [Beer] {
        // Count favorite styles
        let styles = favVM.favorites.map(\.style)
        let counts = Dictionary(grouping: styles, by: { $0 }).mapValues(\.count)
        guard let topStyle = counts.max(by: { $0.value < $1.value })?.key else {
            return []
        }
        // Recommend up to 5 beers of that style
        return viewModel.beers.filter { $0.style == topStyle && !favVM.favorites.map(\.id).contains($0.id ?? "") }
                             .prefix(5)
                             .map { $0 }
    }
    
    var filteredBeers: [Beer] {
        if searchText.isEmpty {
            return viewModel.beers
        } else {
            return viewModel.beers.filter { beer in
                beer.name.localizedCaseInsensitiveContains(searchText) ||
                beer.style.localizedCaseInsensitiveContains(searchText) ||
                beer.brewery.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: – Subviews for body

    private var recommendationSection: some View {
        Group {
            if !recommendedBeers.isEmpty {
                VStack(alignment: .leading) {
                    Text("Recommended for you")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(recommendedBeers) { beer in
                                NavigationLink(destination: BeerDetailView(beer: beer)) {
                                    BeerCardView(beer: beer)
                                        .frame(width: 200)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var beerListSection: some View {
        Group {
            ForEach(filteredBeers) { beer in
                NavigationLink(destination: BeerDetailView(beer: beer)) {
                    BeerCardView(beer: beer)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                // MARK: – Recommended for you (unchanged)
                if !recommendedBeers.isEmpty {
                    recommendationSection
                        .padding(.bottom, 16)
                }

                // MARK: – Masonry grid of beers
                WaterfallGrid(filteredBeers) { beer in
                    NavigationLink(destination: BeerDetailView(beer: beer)) {
                        BeerCardView(beer: beer)
                            .frame(width: 200) // reduced card width
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .gridStyle(
                    columns: 2,
                    spacing: 12,
                    animation: .default
                )
            }
            .background(Color.backgroundColor.ignoresSafeArea())
            .navigationTitle("Thai Craft Beers")
            .searchable(text: $searchText, prompt: "Search beers or breweries")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isFilterSheetPresented = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .accentColor(.primaryColor)
        .sheet(isPresented: $isFilterSheetPresented) {
            BeerFilterView(activeFilters: $viewModel.activeFilters, applyFilters: viewModel.applyFilters)
        }
        .onAppear {
            if viewModel.beers.isEmpty {
                viewModel.fetchBeers()
            }
            favVM.startListening()
        }
        .onDisappear {
            favVM.stopListening()
        }
        .alert(item: $viewModel.errorMessage) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
}
