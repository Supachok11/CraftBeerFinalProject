//
//  FirebaseService.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 30/4/2568 BE.
//

import FirebaseFirestore

/// Central place for all Firestore reads/writes that aren’t user-specific.
final class FirebaseService {

    static let shared = FirebaseService()
    private init() {}

    private let db = Firestore.firestore()

    /// Reads every document from the `beers` collection and decodes them as `Beer`.
    func fetchBeers(completion: @escaping (_ beers: [Beer]?, _ error: Error?) -> Void) {
        db.collection("beers").getDocuments { snapshot, error in
            if let error {
                completion(nil, error);
                return
            }

            let beers = snapshot?.documents.compactMap { doc -> Beer? in
                try? doc.data(as: Beer.self)
            } ?? []

            completion(beers, nil)
        }
    }
}
