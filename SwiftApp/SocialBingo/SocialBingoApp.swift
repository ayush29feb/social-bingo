import SwiftUI

@main
struct SocialBingoApp: App {
    @StateObject private var storage = AppStorage.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storage)
        }
    }
}
