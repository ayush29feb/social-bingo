import SwiftUI
struct FriendCardView: View {
    let user: User
    var body: some View { Text("Friend Card: \(user.username)") }
}
