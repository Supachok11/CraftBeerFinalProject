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
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

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
                VStack(spacing: 16) {
                    
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.bottom, 8)
                    
                    // White card container
                    VStack(spacing: 16) {
                        IconTextField(systemIcon: "envelope",
                                      placeholder: "Email",
                                      text: $email,
                                      keyboard: .emailAddress,
                                      isSecure: false)
                        IconTextField(systemIcon: "lock",
                                      placeholder: "Password",
                                      text: $password,
                                      keyboard: .default,
                                      isSecure: true)

                        // Forgot password link
                        HStack {
                            Spacer()
                            NavigationLink("Forgot Password?", destination: PasswordResetView())
                                .font(.footnote)
                                .foregroundColor(.accentColor)
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
                                    .kerning(1)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .padding()
                        .background(Color.primaryColor.opacity(isLoading || email.isEmpty || password.isEmpty ? 0.5 : 1.0))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .opacity(isLoading || email.isEmpty || password.isEmpty ? 0.6 : 1.0)

                        // Error message
                        if let error {
                            Text("Invalid email or password")
                                .font(.caption)
                                .foregroundColor(.errorColor)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .background(Color.surfaceColor)
                    .cornerRadius(30)
                    .shadow(color: Color.textPrimary.opacity(0.05),
                            radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 24)

                    // Sign Up navigation
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white)
                        NavigationLink("Sign Up", destination: SignUpView())
                            .foregroundColor(.primaryColor)
                            .bold()
                    }
                    
                    // For Debuggin OnBoardingView
                    Button("Show Onboarding") {
                        hasSeenOnboarding = false
                    }
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.top,8)

                    Spacer()
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
    
