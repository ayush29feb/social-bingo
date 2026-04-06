import SwiftUI

struct NotificationsView: View {
    var body: some View {
        NavigationStack {
            List(mockNotifications) { notification in
                HStack(spacing: 12) {
                    // Unread indicator
                    Circle()
                        .fill(notification.read ? Color.clear : Color.appPrimary)
                        .frame(width: 8, height: 8)

                    // Friend avatar
                    Text(notification.fromAvatarEmoji)
                        .font(.system(size: 28))
                        .frame(width: 40, height: 40)
                        .background(Color.appPrimaryLight)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Group {
                            Text(notification.fromUsername)
                                .fontWeight(.semibold)
                            + Text(" plus-oned '")
                            + Text(notification.itemTitle)
                                .italic()
                            + Text("'")
                        }
                        .font(.subheadline)
                        .foregroundColor(.appText)

                        Text(timeAgo(from: notification.createdAt))
                            .font(.caption)
                            .foregroundColor(.appMuted)
                    }
                }
                .padding(.vertical, 4)
                .listRowBackground(
                    notification.read ? Color.white : Color.appPrimaryLight.opacity(0.5)
                )
            }
            .listStyle(.plain)
            .navigationTitle("Notifications")
        }
    }

    private func timeAgo(from isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return "" }
        let seconds = Int(Date().timeIntervalSince(date))
        switch seconds {
        case ..<60:       return "just now"
        case ..<3600:     return "\(seconds / 60)m ago"
        case ..<86400:    return "\(seconds / 3600)h ago"
        case ..<604800:   return "\(seconds / 86400)d ago"
        default:          return "\(seconds / 604800)w ago"
        }
    }
}
