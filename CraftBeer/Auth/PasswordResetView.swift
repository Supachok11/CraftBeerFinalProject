//
//  PasswordResetView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 12/5/2568 BE.
//

import SwiftUI



//
//  PasswordResetView.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 12/5/2568 BE.
//

import SwiftUI
import FirebaseAuth

struct PasswordResetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var message: String?
    @State private var showAlert = false
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.primaryColor, Color.accentColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    Spacer()

                    // Card container
                    VStack(spacing: 16) {
                        Text("Reset Password")
                            .font(.title2.bold())
                            .foregroundColor(.textPrimary)

                        Text("Enter your email to receive a password reset link.")
                            .font(.body)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)

                        // Email field
                        IconTextField(
                            systemIcon: "envelope",
                            placeholder: "Email",
                            text: $email,
                            keyboard: .emailAddress,
                            isSecure: false
                        )

                        // Send button
                        Button {
                            sendReset()
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Send Reset Email")
                                    .font(.headline)
                                    .kerning(1)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .disabled(email.isEmpty || isLoading)
                        .padding()
                        .background(Color.primaryColor.opacity((email.isEmpty || isLoading) ? 0.5 : 1))
                        .cornerRadius(10)
                        .opacity((email.isEmpty || isLoading) ? 0.6 : 1)

                        // Error message
                        if let message {
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.errorColor)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                    .background(Color.surfaceColor)
                    .cornerRadius(30)
                    .shadow(color: Color.textPrimary.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 24)

                    // Back to sign in link
                    HStack {
                        Text("Remember your password?")
                            .foregroundColor(.white)
                        Button("Sign In") {
                            dismiss()
                        }
                        .foregroundColor(.primaryColor)
                        .bold()
                    }
                    .padding(.top, 12)

                    Spacer()
                }
            }
            .alert(message ?? "", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    if message == "Password reset email sent. Check your inbox." {
                        dismiss()
                    }
                }
            }
            .navigationBarBackButtonHidden(false)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func sendReset() {
        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            isLoading = false
            if let error = error {
                message = error.localizedDescription
            } else {
                message = "Password reset email sent. Check your inbox."
            }
            showAlert = true
        }
    }
}

private struct IconTextField: View {
    let systemIcon : String
    let placeholder: String
    @Binding var text: String
    let keyboard   : UIKeyboardType
    let isSecure   : Bool

    var body: some View {
        HStack {
            Image(systemName: systemIcon)
                .foregroundColor(.accentColor)
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
        .background(Color.surfaceColor.opacity(0.5))
        .cornerRadius(8)
    }
}

