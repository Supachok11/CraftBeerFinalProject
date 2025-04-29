//
//  BeerDetailView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import SwiftUI
import Firebase
import Kingfisher

struct BeerDetailView: View {
    let beer: Beer
    @EnvironmentObject var session: SessionManager
    @StateObject private var viewModel = BeerLogViewModel()
    @State private var showingLogSheet = false
    @State private var userRating: Int = 0
    @State private var userNotes: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Beer Image
                KFImage(URL(string: beer.image))
                    .placeholder {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
                    .cornerRadius(10)
                
                // Beer Details
                VStack(alignment: .leading, spacing: 12) {
                    Text(beer.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label("\(beer.style)", systemImage: "tag")
                            .font(.headline)
                        
                        Spacer()
                        
                        Label("\(String(format: "%.1f", beer.abv))% ABV", systemImage: "drop")
                            .font(.headline)
                    }
                    .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("Description")
                        .font(.headline)
                    
                    Text(beer.description)
                        .font(.body)
                        .padding(.bottom, 8)
                    
                    Text("Brewery: \(beer.brewery)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let ibu = beer.ibu {
                        Text("IBU: \(ibu)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let releaseYear = beer.releaseYear {
                        Text("First Released: \(releaseYear)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Actions
                    VStack(spacing: 12) {
                        if session.user != nil {
                            Button(action: {
                                showingLogSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add to Beer Log")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                viewModel.saveBeerToFavorites(
                                    userId: session.user?.uid ?? "",
                                    beer: beer)
                            }) {
                                HStack {
                                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                    Text(viewModel.isFavorite ? "Saved to Favorites" : "Save to Favorites")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isFavorite ? Color.green : Color.gray.opacity(0.2))
                                .foregroundColor(viewModel.isFavorite ? .white : .primary)
                                .cornerRadius(10)
                            }
                        } else {
                            Text("Log in to save this beer to your collection!")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 16)
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingLogSheet) {
            BeerLogEntryView(beer: beer,
                             isPresented: $showingLogSheet)
                .environmentObject(session)
        }
        .onAppear {
            if let uid = session.user?.uid {
                            viewModel.checkIfFavorite(userId: uid,
                                                      beerId: beer.id ?? "")
            }
        }
        .alert(item: $viewModel.errorMessage) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
}
