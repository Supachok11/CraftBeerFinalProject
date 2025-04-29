//
//  BeerCardView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import SwiftUI
import Firebase
import Kingfisher

struct BeerCardView: View {
    let beer: Beer
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
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
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(10)
                
                Text("\(String(format: "%.1f", beer.abv))% ABV")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(beer.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(beer.style)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(beer.brewery)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(beer.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
        .background(Color("CardBackground"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
