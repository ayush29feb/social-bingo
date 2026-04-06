import AuthenticationServices
import CryptoKit
import Foundation
import Supabase

@MainActor
final class AuthManager: NSObject, ObservableObject {
    static let shared = AuthManager()

    @Published var session: Session?
    @Published var isLoading = true

    private var currentNonce: String?

    override init() {
        super.init()
        Task { await restoreSession() }
    }

    // MARK: - Session restore

    private func restoreSession() async {
        session = try? await supabase.auth.session
        isLoading = false
    }

    // MARK: - Apple Sign-In

    func startAppleSignIn() {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }

    // MARK: - Username generation (static for testability)

    static func usernameFrom(appleName: PersonNameComponents?) -> String {
        let raw = [appleName?.givenName, appleName?.familyName]
            .compactMap { $0 }
            .joined()
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
        let trimmed = String(raw.prefix(20))
        return trimmed.isEmpty ? "user\(Int.random(in: 1000...9999))" : trimmed
    }

    // MARK: - Private helpers

    private func randomNonceString(length: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    private func ensureUserProfile(userId: UUID, appleName: PersonNameComponents?) async {
        // Check if profile already exists
        let existing = try? await supabase
            .from("users")
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()

        // Non-empty response means user already exists
        if let data = existing?.data, !data.isEmpty, data != Data("[]".utf8) {
            return
        }

        // New user — create profile
        let emojis = ["😊","🌊","🎸","🌿","🚀","🎯","🦊","🌙","⚡️","🎨"]
        let profile: [String: String] = [
            "id": userId.uuidString,
            "username": AuthManager.usernameFrom(appleName: appleName),
            "avatar_emoji": emojis.randomElement() ?? "😊",
            "bio": ""
        ]

        _ = try? await supabase
            .from("users")
            .insert(profile)
            .execute()

        // Clear prototype data if needed
        let user = User(
            id: userId.uuidString,
            username: profile["username"] ?? "user",
            avatarEmoji: profile["avatar_emoji"] ?? "😊",
            bio: ""
        )
        if AppStorage.shared.currentUser.id == "current-user" {
            AppStorage.shared.resetForNewUser(user: user)
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce,
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else { return }

        Task {
            do {
                let session = try await supabase.auth.signInWithIdToken(
                    credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
                )
                await ensureUserProfile(userId: session.user.id, appleName: credential.fullName)
                self.session = session
            } catch {
                print("[AuthManager] Sign-in error: \(error)")
            }
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        print("[AuthManager] Apple Sign-In cancelled or failed: \(error)")
    }
}
