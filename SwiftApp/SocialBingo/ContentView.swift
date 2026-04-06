import SwiftUI

struct ContentView: View {
    @EnvironmentObject var storage: AppStorage

    var body: some View {
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
                .badge(getUnreadCount() > 0 ? getUnreadCount() : 0)
        }
        .tint(.appPrimary)
    }
}
