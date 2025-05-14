//
//  BeerLogListViewModel.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class BeerLogListViewModel: ObservableObject {
    @Published var logs: [BeerLogEntry] = []
    @Published var error: ErrorMessage?
    @Published var isLoading = false

    private var listener: ListenerRegistration?

    func start() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
            isLoading = true                         // start spinner

            listener = Firestore.firestore()
                .collection("userLogs")
                .whereField("userId", isEqualTo: uid)
                .order(by: "loggedDate", descending: true)
                .addSnapshotListener { [weak self] snap, err in
                    self?.isLoading = false          // stop spinner
                    if let err {
                        self?.error = ErrorMessage(message: err.localizedDescription)
                        return
                    }
                    self?.logs = snap?.documents.compactMap {
                        try? $0.data(as: BeerLogEntry.self)
                    } ?? []
                }
        }
    
    func stop() {
        listener?.remove(); listener = nil
    }

    // delete
    func delete(_ entry: BeerLogEntry) {
        guard let id = entry.id else {
            return
        }
        Firestore.firestore().collection("userLogs").document(id).delete { [weak self] err in
            if let err {
                self?.error = .init(message: err.localizedDescription)
            }
        }
    }
    // update
    func update(entry: BeerLogEntry, rating: Double, notes: String) {
        guard let id = entry.id else {
            return
        }
        Firestore.firestore().collection("userLogs").document(id).updateData([
            "rating": rating,
            "notes":  notes,
            "loggedDate": Date()
        ])
    }
}
