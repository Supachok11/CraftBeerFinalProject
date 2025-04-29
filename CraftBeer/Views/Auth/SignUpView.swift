//
//  SignUpView.swift
//  Weed
//
//  Created by Supachok Chatupamai on 29/4/2568 BE.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email    = ""
    @State private var password = ""
    @State private var confirm  = ""
    @State private var errorMsg: String?
    @State private var showOK   = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Create Account").font(.title.bold())

            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            SecureField("Password (6+ chars)", text: $password)
                .textFieldStyle(.roundedBorder)

            SecureField("Confirm password", text: $confirm)
                .textFieldStyle(.roundedBorder)

            if let errorMsg { Text(errorMsg).foregroundColor(.red).font(.caption) }

            Button("Sign Up") { signUp() }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .toolbar { Button("Close", role: .cancel) { dismiss() } }
        .alert("Account created! Please sign in.", isPresented: $showOK) {
            Button("OK") { dismiss() }
        }
    }

    private func signUp() {
        guard password == confirm else { errorMsg = "Passwords don’t match"; return }
        Task {
            do {
                try await Auth.auth().createUser(withEmail: email, password: password)
                try? Auth.auth().signOut()
                showOK = true
            } catch { errorMsg = error.localizedDescription }
        }
    }
}

