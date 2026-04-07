import Foundation
import Supabase

@MainActor
final class AuthManager: NSObject, ObservableObject {
    static let shared = AuthManager()

    @Published var session: Session?
    @Published var isLoading = true
    @Published var magicLinkSent = false

    override init() {
        super.init()
        Task { await startAuthListener() }
    }

    // MARK: - Auth state listener

    private func startAuthListener() async {
        session = try? await supabase.auth.session
        isLoading = false

        for await (event, session) in await supabase.auth.authStateChanges {
            switch event {
            case .signedIn:
                self.session = session
                self.magicLinkSent = false
                if let session {
                    await ensureUserProfile(session: session)
                }
            case .signedOut:
                self.session = nil
            default:
                break
            }
        }
    }

    // MARK: - Magic link

    func sendMagicLink(email: String) async throws {
        try await supabase.auth.signInWithOTP(
            email: email,
            redirectTo: URL(string: "socialbingo://login-callback")
        )
        magicLinkSent = true
    }

    func handleURL(_ url: URL) {
        supabase.auth.handle(url)
    }

    // MARK: - Username generation (static for testability)

    nonisolated static func usernameFrom(email: String) -> String {
        let prefix = email.components(separatedBy: "@").first ?? ""
        let cleaned = prefix.lowercased().filter { $0.isLetter || $0.isNumber }
        let trimmed = String(cleaned.prefix(20))
        return trimmed.isEmpty ? "user\(Int.random(in: 1000...9999))" : trimmed
    }

    // MARK: - Profile creation

    private func ensureUserProfile(session: Session) async {
        let existing = try? await supabase
            .from("users")
            .select()
            .eq("id", value: session.user.id.uuidString)
            .limit(1)
            .execute()

        if let data = existing?.data, !data.isEmpty, data != Data("[]".utf8) {
            return
        }

        let emojis = ["😊","🌊","🎸","🌿","🚀","🎯","🦊","🌙","⚡️","🎨"]
        let profile: [String: String] = [
            "id": session.user.id.uuidString,
            "username": AuthManager.usernameFrom(email: session.user.email ?? ""),
            "avatar_emoji": emojis.randomElement() ?? "😊",
            "bio": ""
        ]

        _ = try? await supabase
            .from("users")
            .insert(profile)
            .execute()

        let user = User(
            id: session.user.id.uuidString,
            username: profile["username"] ?? "user",
            avatarEmoji: profile["avatar_emoji"] ?? "😊",
            bio: ""
        )
        if AppStorage.shared.currentUser.id == "current-user" {
            AppStorage.shared.resetForNewUser(user: user)
        }
    }
}
