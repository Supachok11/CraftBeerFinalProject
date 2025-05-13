//
//  BeerCardView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import SwiftUI
import Kingfisher
import Firebase

struct BeerCardView: View {
    let beer: Beer
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                KFImage(URL(string: beer.image))
                    .resizable()
//                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(10)

                // ABV badge
                Text(String(format: "%.1f%% ABV", beer.abv))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .padding(8)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(beer.name)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .padding(.top, 8)
                Text(beer.style)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                Text(beer.brewery)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
        .background(Color.surfaceColor)
        .cornerRadius(12)
        .shadow(color: Color.textPrimary.opacity(0.1), radius: 4, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
}
