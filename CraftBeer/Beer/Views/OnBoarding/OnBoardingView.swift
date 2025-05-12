//
//  OnBoardingView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 13/5/2568 BE.
//

import SwiftUI

/// Onboarding screen guiding users through key features before sign-in.
struct OnboardingView: View {
    private struct Page: Identifiable {
        let id: Int
        let title: String
        let text: String
        let image: String
    }

    private let pages: [Page] = [
        .init(id: 0,
              title: "Browse Beers",
              text: "Explore a wide variety of craft beers from around the world.",
              image: "list.bullet"),
        .init(id: 1,
              title: "Save Favorites",
              text: "Keep track of your favorite beers and access them anytime.",
              image: "heart.fill"),
        .init(id: 2,
              title: "Track Tastings",
              text: "Log your tasting notes and ratings for every beer you try.",
              image: "square.and.pencil"),
        .init(id: 3,
              title: "Discover Bars",
              text: "Find craft beer bars near you on an interactive map.",
              image: "map.fill")
    ]

    @State private var selection: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color("GradientStart"), Color("GradientEnd")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                TabView(selection: $selection) {
                    ForEach(pages) { page in
                        VStack(spacing: 20) {
                            Spacer()
                            Image(systemName: page.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(Color("PrimaryColor"))
                            Text(page.title)
                                .font(.title.bold())
                                .foregroundColor(.white)
                            Text(page.text)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                            Spacer()

                            if page.id == pages.count - 1 {
                                NavigationLink(destination: SignInView()
                                                .navigationBarBackButtonHidden(true)) {
                                    Text("Get Started")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color("PrimaryColor"))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 40)
                                }
                            } else {
                                Button(action: {
                                    withAnimation {
                                        selection += 1
                                    }
                                }) {
                                    Text("Next")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color("PrimaryColor").opacity(0.8))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 40)
                                }
                            }

                            Spacer()
                        }
                        .tag(page.id)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            }
            .accentColor(Color("PrimaryColor"))
            .navigationBarHidden(true)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
