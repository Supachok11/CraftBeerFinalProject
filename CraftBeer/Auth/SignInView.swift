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

            VStack {
                Spacer()
                VStack(spacing: 24) {
                    
                    // White card container
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)

                        // Forgot password link
                        HStack {
                            Spacer()
                            NavigationLink("Forgot Password?", destination: PasswordResetView())
                                .font(.footnote)
                                .foregroundColor(.blue)
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
                                Text("SIGN\u{202F}IN")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .padding()
                        .background((isLoading || email.isEmpty || password.isEmpty) ? Color.gray : Color.blue)
                        .cornerRadius(10)

                        // Error message
                        if let error {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 24)

                    // Sign Up navigation
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white)
                        NavigationLink("Sign\u{202F}Up", destination: SignUpView())
                            .foregroundColor(.blue)
                            .bold()
                    }
                }
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
    
