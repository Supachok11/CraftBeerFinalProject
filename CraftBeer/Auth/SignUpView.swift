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

    @State private var email     = ""
    @State private var password  = ""
    @State private var confirm   = ""
    @State private var errorMsg  : String?
    @State private var showOK    = false
    @State private var isLoading = false

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
                    // App logo
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .padding(.top, 40)

                    Text("Create Account")
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
                            placeholder: "Password (6+ chars)",
                            text: $password,
                            keyboard: .default,
                            isSecure: true
                        )
                        IconTextField(
                            systemIcon: "lock.rotation",
                            placeholder: "Confirm Password",
                            text: $confirm,
                            keyboard: .default,
                            isSecure: true
                        )
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)

                    // Error message
                    if let errorMsg {
                        Text(errorMsg)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Sign Up button
                    Button {
                        signUp()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign Up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isLoading || email.isEmpty || password.count < 6 || password != confirm)
                    .padding()
                    .background(
                        (isLoading || email.isEmpty || password.count < 6 || password != confirm)
                        ? Color.gray
                        : Color.accentColor
                    )
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .alert("Account created!", isPresented: $showOK) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Please sign in with your new account.")
            }
        }
    }

    private func signUp() {
        // Clear prior error
        errorMsg = nil
        isLoading = true

        Task {
            do {
                // Create new user
                _ = try await Auth.auth().createUser(withEmail: email, password: password)
                // Sign out immediately so next screen can sign in
                try? Auth.auth().signOut()
                await MainActor.run {
                    isLoading = false
                    showOK = true
                }
            } catch let signUpError {
                await MainActor.run {
                    errorMsg = signUpError.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// Reusable icon + text-field combo (same as in SignInView)
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
