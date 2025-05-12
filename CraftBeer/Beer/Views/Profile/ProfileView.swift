//
//  ProfileView.swift
//  Weed
//
//  Created by Supachok Chatupamai on 29/4/2568 BE.
//

import SwiftUI
import UIKit
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

struct ProfileView: View {
    // MARK: – State / Env
    @State private var err: String?
    @State private var displayName = Auth.auth().currentUser?.displayName ?? ""
    @State private var favCount    = 0
    @State private var logCount    = 0
    
    @AppStorage("appTheme") private var appTheme: String = "light"
    
    @State private var avatarImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                // -------- user header ------------
                Section {
                    HStack {
                        Button {
                            showingImagePicker = true
                        } label: {
                            if let uiImage = avatarImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(.tint)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        VStack(alignment: .leading) {
                            Text(displayName.isEmpty
                                 ? Auth.auth().currentUser?.email ?? "Unknown"
                                 : displayName)
                            .font(.headline)
                            Text("Logged in")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // -------- quick stats -----------
                Section("Activity") {
                    HStack {
                        Label("Favorites", systemImage: "heart")
                        Spacer()
                        Text("\(favCount)")
                    }
                    HStack {
                        Label("Log entries", systemImage: "note.text")
                        Spacer()
                        Text("\(logCount)")
                    }
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
                    .onChange(of: appTheme) { _ in
                        updateTheme()
                    }
                    // theme is applied at App level via .preferredColorScheme
                }
                
                if let err {
                    Section { Text(err).foregroundColor(.red) }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadCounts()
                loadAvatar()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $avatarImage)
            }
            .onChange(of: avatarImage) { newImage in
                if let img = newImage {
                    uploadAvatar(img)
                }
            }
        }
    }
    
    // MARK: – Actions
    
    private func loadCounts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("userFavorites")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { snap, _ in
                favCount = snap?.documents.count ?? 0
            }
        
        db.collection("userLogs")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { snap, _ in
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
        do {
            try Auth.auth().signOut()
        } catch {
            err = error.localizedDescription
        }
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
    
    // MARK: – Firestore-backed avatar Blob
    
    private func uploadAvatar(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // Resize to max 256px
        let maxSide: CGFloat = 256
        let aspect = image.size.width / image.size.height
        let newSize: CGSize = image.size.width > image.size.height
        ? CGSize(width: maxSide, height: maxSide / aspect)
        : CGSize(width: maxSide * aspect, height: maxSide)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        guard let data = resized.jpegData(compressionQuality: 0.5) else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid)
            .setData(["avatarBlob": data], merge: true)
    }
    
    private func loadAvatar() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snap, _ in
            if let data = snap?.get("avatarBlob") as? Data,
               let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    avatarImage = img
                }
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
    
    // MARK: – Image Picker
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        
        func makeUIViewController(context: Context) -> PHPickerViewController {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .images
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator { Coordinator(self) }
        
        class Coordinator: NSObject, PHPickerViewControllerDelegate {
            let parent: ImagePicker
            init(_ parent: ImagePicker) { self.parent = parent }
            
            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                picker.dismiss(animated: true)
                guard
                    let provider = results.first?.itemProvider,
                    provider.canLoadObject(ofClass: UIImage.self)
                else { return }
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}
