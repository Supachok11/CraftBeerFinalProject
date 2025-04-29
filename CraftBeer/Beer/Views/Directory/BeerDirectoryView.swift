//
//  BeerDirectoryView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import SwiftUI
import Firebase
import Kingfisher

struct BeerDirectoryView: View {
    @StateObject private var viewModel = BeerDirectoryViewModel()
    @State private var searchText = ""
    @State private var isFilterSheetPresented = false
    
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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading {
                    ProgressView("Loading beers...")
                } else if viewModel.beers.isEmpty {
                    VStack {
                        Image(systemName: "mug.fill")
                            .font(.system(size: 72))
                            .foregroundColor(.gray)
                        Text("No beers to display")
                            .font(.headline)
                            .padding()
                        Button("Refresh") {
                            viewModel.fetchBeers()
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredBeers) { beer in
                                NavigationLink(destination: BeerDetailView(beer: beer)) {
                                    BeerCardView(beer: beer)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Thai Craft Beers")
            .searchable(text: $searchText, prompt: "Search beers or breweries")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isFilterSheetPresented = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $isFilterSheetPresented) {
                BeerFilterView(activeFilters: $viewModel.activeFilters, applyFilters: viewModel.applyFilters)
            }
            .onAppear {
                if viewModel.beers.isEmpty {
                    viewModel.fetchBeers()
                }
            }
            .alert(item: $viewModel.errorMessage) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }
}

