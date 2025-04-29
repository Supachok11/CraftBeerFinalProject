//
//  ContentView.swift
//  Weed
//
//  Created by Supachok Chatupamai on 29/4/2568 BE.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("justLoggedIn") private var justLoggedIn = false
    @State private var showWelcome = false

    var body: some View {
        TabView {
            // 🔸 Replace this with whatever your new app does
            Text("Home Screen")
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ProfileView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            if justLoggedIn {
                showWelcome = true
                justLoggedIn = false
            }
        }
        .alert("Signed in successfully!", isPresented: $showWelcome) {
            Button("OK") {
                
            }
        }
    }
}
