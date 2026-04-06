import AuthenticationServices
import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Text("🎯")
                    .font(.system(size: 64))
                Text("Social Bingo")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.appPrimary)
                Text("Your bucket list, shared with friends.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            SignInWithAppleButton(
                .signIn,
                onRequest: { _ in },
                onCompletion: { _ in }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal, 40)
            .onTapGesture {
                authManager.startAppleSignIn()
            }

            Spacer()
                .frame(height: 32)
        }
        .padding()
    }
}
