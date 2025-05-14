//
//  SessionManager.swift
//  Weed
//
//  Created by Supachok Chatupamai on 29/4/2568 BE.
//

import FirebaseAuth
import Combine
import SwiftUI

@MainActor
final class SessionManager: ObservableObject {
    @Published var user: User?

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }

    deinit {
        if let h = handle
        {
        Auth.auth().removeStateDidChangeListener(h)
    }
    }
}
