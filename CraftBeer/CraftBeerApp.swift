//
//  CraftBeerApp.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 29/4/2568 BE.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct CraftBeerApp: App {
    @StateObject private var session = SessionManager()
    
    init() { FirebaseApp.configure() }
    
    var body: some Scene {
        WindowGroup {
            if session.user != nil {
                ContentView()
            } else {
                SignInView()
            }
        }
    }
}
