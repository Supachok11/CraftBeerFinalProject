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
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.title.bold())

            Text("Enter your email to receive a password reset link.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color("BackgroundColor").opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)

            Button {
                sendReset()
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Send Reset Email")
                        .font(.headline)
                }
            }
            .disabled(email.isEmpty || isLoading)
            .padding()
            .frame(maxWidth: .infinity)
            .background((email.isEmpty || isLoading) ? Color.gray : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
        .alert(message ?? "", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                if message == "Password reset email sent. Check your inbox." {
                    dismiss()
                }
            }
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

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}
