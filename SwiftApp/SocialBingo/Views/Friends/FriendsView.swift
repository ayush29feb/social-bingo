import SwiftUI

struct FriendsView: View {
    var body: some View {
        NavigationStack {
            List(mockUsers) { user in
                NavigationLink(destination: FriendCardView(user: user)) {
                    HStack(spacing: 12) {
                        Text(user.avatarEmoji)
                            .font(.system(size: 32))
                            .frame(width: 44, height: 44)
                            .background(Color.appPrimaryLight)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.username)
                                .font(.headline)
                            if !user.bio.isEmpty {
                                Text(user.bio)
                                    .font(.subheadline)
                                    .foregroundColor(.appMuted)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Friends")
        }
    }
}
