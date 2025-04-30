//
//  BeerFavoritesViewModel.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestore

final class BeerFavoritesViewModel: ObservableObject {

    @Published var favorites: [Beer] = []
    @Published var isLoading = false
    @Published var error: ErrorMessage?

    private var listener: ListenerRegistration?

    /// Realtime listener — call once when the view appears.
    func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        isLoading = true
        let db = Firestore.firestore()

        // 1. listen to user's userFavorites docs
        listener = db.collection("userFavorites")
            .whereField("userId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snap, err in
                if let err {
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        self?.error = ErrorMessage(message: err.localizedDescription)
                    }
                    return
                }

                let beerIds = snap?.documents.compactMap { $0["beerId"] as? String } ?? []

                // 2. fetch the Beer docs for those IDs
                self?.loadBeerDocs(byIDs: beerIds)
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: – Private
    private func loadBeerDocs(byIDs ids: [String]) {
        guard !ids.isEmpty else {
            DispatchQueue.main.async { self.favorites = []; self.isLoading = false }
            return
        }

        let db = Firestore.firestore()
        db.collection("beers")
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments { [weak self] snap, err in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let err {
                        self?.error = ErrorMessage(message: err.localizedDescription)
                        return
                    }
                    self?.favorites = snap?.documents.compactMap {
                        try? $0.data(as: Beer.self)
                    } ?? []
                }
            }
    }
}
