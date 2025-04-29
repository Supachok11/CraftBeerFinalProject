//
//  ProfileView.swift
//  Weed
//
//  Created by Supachok Chatupamai on 29/4/2568 BE.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var err: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(.tint)
                        VStack(alignment: .leading) {
                            Text(Auth.auth().currentUser?.email ?? "Unknown")
                                .font(.headline)
                            Text("Logged in").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                Section("Account") {
                    Button("Log Out", role: .destructive) {
                        logOut()
                    }
                }
                if let err { Section {
                    Text(err).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func logOut() {
        do   { try Auth.auth().signOut() }
        catch { err = error.localizedDescription }
    }
}

