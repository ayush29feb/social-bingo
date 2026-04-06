import SwiftUI

struct ContentView: View {
    @EnvironmentObject var storage: AppStorage
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        Group {
            if authManager.isLoading {
                ProgressView()
            } else if authManager.session == nil {
                SignInView()
            } else {
                mainTabView
            }
        }
    }

    private var mainTabView: some View {
        TabView {
            MyCardView()
                .tabItem {
                    Label("My Card", systemImage: "square.grid.3x3")
                }

            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }

            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
                .badge(getUnreadCount())
        }
        .tint(.appPrimary)
    }
}
