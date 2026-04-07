import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        if authManager.magicLinkSent {
            checkEmailView
        } else {
            emailEntryView
        }
    }

    private var emailEntryView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Text("🎯")
                    .font(.system(size: 64))
                Text("Social Bingo")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appPrimary)
                Text("Your bucket list, shared with friends.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 12) {
                TextField("your@email.com", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal, 40)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 40)
                }

                Button {
                    Task { await sendLink() }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Send Magic Link")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.appPrimary)
                .disabled(email.isEmpty || isLoading)
                .padding(.horizontal, 40)
            }

            Spacer()
                .frame(height: 32)
        }
        .padding()
    }

    private var checkEmailView: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("📬")
                .font(.system(size: 64))
            Text("Check your email")
                .font(.title2.bold())
            Text("We sent a sign-in link to\n**\(email)**\n\nTap the link in your email to sign in.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Use a different email") {
                authManager.magicLinkSent = false
                email = ""
            }
            .foregroundStyle(Color.appPrimary)

            Spacer()
                .frame(height: 32)
        }
        .padding()
    }

    private func sendLink() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authManager.sendMagicLink(email: email)
        } catch {
            errorMessage = "Couldn't send link. Check your email and try again."
        }
        isLoading = false
    }
}
