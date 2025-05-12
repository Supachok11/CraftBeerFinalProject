//
//  CraftBeerApp.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 29/4/2568 BE.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct CraftBeerApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    //  Track whether the user has already seen onboarding
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    @StateObject private var session = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            if session.user != nil {
                ContentView()
                    .environmentObject(session)
            } else if !hasSeenOnboarding {
                OnboardingView()
                    .environmentObject(session)
                    .onDisappear {
                        hasSeenOnboarding = true
                    }
            } else {
                SignInView()          // 🔒 user must log in
                    .environmentObject(session)
            }
        }
    }
}
