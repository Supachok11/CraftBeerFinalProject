//
//  SignInView.swift
//  Weed
//
//  Created by Supachok Chatupamai on 29/4/2568 BE.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    
    @AppStorage("justLoggedIn") private var justLoggedIn = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Welcome").font(.title.bold())

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if error != nil {
                    Text("Invalid email or password")
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button("Sign In") {
                    signIn()
                }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)

                NavigationLink("Create a new account") {
                    SignUpView()
                }
                    .font(.footnote)
            }
            .padding()
        }
    }

    private func signIn() {
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                justLoggedIn = true
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}

