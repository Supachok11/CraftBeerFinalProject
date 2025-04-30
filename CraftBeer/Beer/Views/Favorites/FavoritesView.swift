//
//  FavoritesView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import SwiftUI
import Kingfisher

struct FavoritesView: View {
    @StateObject private var vm = BeerFavoritesViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()

                if vm.isLoading {
                    ProgressView("Loading favorites…")
                } else if vm.favorites.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "heart")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        Text("No favorites yet")
                            .font(.headline)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(vm.favorites) { beer in
                                NavigationLink {
                                    BeerDetailView(beer: beer)
                                } label: {
                                    BeerCardView(beer: beer)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Favorites")
            .onAppear { vm.startListening() }
            .onDisappear { vm.stopListening() }
            .alert(item: $vm.error) { e in
                Alert(title: Text("Error"),
                      message: Text(e.message),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
}

