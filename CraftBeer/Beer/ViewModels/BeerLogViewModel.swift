//
//  BeerLogViewModel.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import SwiftUI
import FirebaseFirestore

/// Handles “favorite” status + errors for a single beer.
final class BeerLogViewModel: ObservableObject {

    @Published var isFavorite    = false
    @Published var errorMessage: ErrorMessage?

    /// Check if the beer is already favorited by this user.
    func checkIfFavorite(userId: String, beerId: String) {
        let db = Firestore.firestore()
        db.collection("userFavorites")
            .whereField("userId", isEqualTo: userId)
            .whereField("beerId", isEqualTo: beerId)
            .getDocuments { [weak self] snap, err in
                DispatchQueue.main.async {
                    if let err {
                        self?.errorMessage = ErrorMessage(message: err.localizedDescription)
                    } else {
                        self?.isFavorite = !(snap?.documents.isEmpty ?? true)
                    }
                }
            }
    }

    /// Toggle favorite status (add / remove) in Firestore.
    func saveBeerToFavorites(userId: String, beer: Beer) {
        guard let beerId = beer.id else {
            errorMessage = ErrorMessage(message: "Invalid beer ID")
            return
        }

        let db = Firestore.firestore()

        if isFavorite {
            // remove
            db.collection("userFavorites")
                .whereField("userId", isEqualTo: userId)
                .whereField("beerId", isEqualTo: beerId)
                .getDocuments { [weak self] snap, err in
                    if let err {
                        DispatchQueue.main.async {
                            self?.errorMessage = ErrorMessage(message: err.localizedDescription)
                        }
                        return
                    }
                    guard let doc = snap?.documents.first else { return }
                    doc.reference.delete { err in
                        DispatchQueue.main.async {
                            if let err {
                                self?.errorMessage = ErrorMessage(message: err.localizedDescription)
                            } else {
                                self?.isFavorite = false
                            }
                        }
                    }
                }
        } else {
            // add
            let favorite: [String: Any] = [
                "userId": userId,
                "beerId": beerId,
                "beerName": beer.name,
                "addedDate": Timestamp(date: .now)
            ]
            db.collection("userFavorites").addDocument(data: favorite) { [weak self] err in
                DispatchQueue.main.async {
                    if let err {
                        self?.errorMessage = ErrorMessage(message: err.localizedDescription)
                    } else {
                        self?.isFavorite = true
                    }
                }
            }
        }
    }
}
