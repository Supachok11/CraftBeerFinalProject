//
//  SignInView.swift
//  Weed
//
//  Created by Supachok Chatupamai on 29/4/2568 BE.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var email        = ""
    @State private var password     = ""
    @State private var error        : String?
    @AppStorage("justLoggedIn") private var justLoggedIn = false
    @State private var isLoading    = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color("GradientStart"), Color("GradientEnd")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 32) {
                    // App logo (set your asset in Assets.xcassets)
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .padding(.top, 40)

                    Text("Welcome")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    // Input card
                    VStack(spacing: 16) {
                        IconTextField(
                            systemIcon: "envelope",
                            placeholder: "Email",
                            text: $email,
                            keyboard: .emailAddress,
                            isSecure: false
                        )
                        IconTextField(
                            systemIcon: "lock",
                            placeholder: "Password",
                            text: $password,
                            keyboard: .default,
                            isSecure: true
                        )
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)

                    // Error message
                    if let error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Sign In button
                    Button {
                        signIn()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign In")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .padding()
                    .background(
                        (isLoading || email.isEmpty || password.isEmpty)
                        ? Color.gray
                        : Color.accentColor
                    )
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 24)

                    // Navigation to Sign Up
                    NavigationLink("Create a new account", destination: SignUpView())
                        .font(.footnote)
                        .foregroundColor(.blue.opacity(0.8))
                        .padding(.top, 8)

                    Spacer()
                }
            }
        }
    }

    private func signIn() {
        isLoading = true
        Task {
            do {
                _ = try await Auth.auth().signIn(withEmail: email, password: password)
                await MainActor.run {
                    justLoggedIn = true
                    isLoading = false
                    error = nil
                }
            } catch let signInError {
                await MainActor.run {
                    self.error = signInError.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// Reusable icon + text-field combo
private struct IconTextField: View {
    let systemIcon : String
    let placeholder: String
    @Binding var text: String
    let keyboard   : UIKeyboardType
    let isSecure   : Bool

    var body: some View {
        HStack {
            Image(systemName: systemIcon)
                .foregroundColor(.secondary)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.6))
        .cornerRadius(8)
    }
}

