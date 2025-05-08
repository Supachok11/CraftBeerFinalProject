//
//  ProfileView.swift
//  Weed
//
//  Created by Supachok Chatupamai on 29/4/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {

    // MARK: – State / env
    @State private var err: String?
    @State private var displayName = Auth.auth().currentUser?.displayName ?? ""
    @State private var favCount   = 0
    @State private var logCount   = 0
    @AppStorage("appTheme") private var appTheme: String = "system"   // system | light | dark
    @Environment(\.colorScheme) private var systemScheme

    // MARK: – UI
    var body: some View {
        NavigationStack {
            Form {
                // -------- user header ------------
                Section {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.tint)
                        VStack(alignment: .leading) {
                            Text(displayName.isEmpty
                                 ? Auth.auth().currentUser?.email ?? "Unknown"
                                 : displayName)
                                .font(.headline)
                            Text("Logged in").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }

                // -------- quick stats -----------
                Section("Activity") {
                    HStack { Label("Favorites", systemImage: "heart"); Spacer(); Text("\(favCount)") }
                    HStack { Label("Log entries", systemImage: "note.text"); Spacer(); Text("\(logCount)") }
                }

                // -------- account settings ------
                Section("Account") {
                    TextField("Display name", text: $displayName, onCommit: saveDisplayName)
                        .textInputAutocapitalization(.words)

                    Button("Log Out", role: .destructive) { logOut() }
                    Button("Delete Account", role: .destructive) { confirmDelete() }
                }

                // -------- appearance ------------
                Section("Appearance") {
                    Picker("Theme", selection: $appTheme) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: appTheme) { _ in updateTheme() }
                }

                if let err {
                    Section { Text(err).foregroundColor(.red) }
                }
            }
            .navigationTitle("Settings")
            .onAppear { loadCounts(); updateTheme() }
        }
    }

    // MARK: – Actions
    private func loadCounts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("userFavorites").whereField("userId", isEqualTo: uid).getDocuments { snap, _ in
            favCount = snap?.documents.count ?? 0
        }
        db.collection("userLogs").whereField("userId", isEqualTo: uid).getDocuments { snap, _ in
            logCount = snap?.documents.count ?? 0
        }
    }

    private func saveDisplayName() {
        guard let user = Auth.auth().currentUser, !displayName.isEmpty else { return }
        Task {
            let request = user.createProfileChangeRequest()
            request.displayName = displayName
            do {
                try await request.commitChanges()
            } catch {
                err = error.localizedDescription
            }
        }
    }

    private func logOut() {
        do   { try Auth.auth().signOut() }
        catch { err = error.localizedDescription }
    }

    private func confirmDelete() {
        err = nil
        guard let root = UIApplication.shared.windows.first?.rootViewController else { return }
        let alert = UIAlertController(
            title: "Delete Account?",
            message: "This is irreversible.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            deleteAccount()
        })
        root.present(alert, animated: true)
    }

    private func deleteAccount() {
        Task {
            do {
                try await Auth.auth().currentUser?.delete()
            } catch {
                err = error.localizedDescription
            }
        }
    }

    private func updateTheme() {
        switch appTheme {
        case "light":  UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        case "dark":   UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        default:       UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
        }
    }
}


