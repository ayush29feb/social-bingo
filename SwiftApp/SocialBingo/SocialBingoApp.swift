import SwiftUI

@main
struct SocialBingoApp: App {
    @StateObject private var storage = AppStorage.shared
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storage)
                .environmentObject(authManager)
        }
    }
}
