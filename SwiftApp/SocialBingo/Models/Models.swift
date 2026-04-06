import Foundation

struct User: Codable, Identifiable, Equatable {
    var id: String
    var username: String
    var avatarEmoji: String
    var bio: String
}

struct BingoItem: Codable, Identifiable, Equatable {
    var id: String
    var userId: String
    var position: Int
    var emoji: String
    var title: String
    var description: String
    var url: String
    var createdAt: String
}

struct PlusOne: Codable, Identifiable {
    var id: String
    var itemId: String
    var fromUserId: String
    var createdAt: String
}

struct Friendship: Codable, Identifiable {
    var id: String
    var userAId: String
    var userBId: String
}

struct NotificationItem: Codable, Identifiable {
    var id: String
    var itemId: String
    var itemTitle: String
    var fromUserId: String
    var fromUsername: String
    var fromAvatarEmoji: String
    var createdAt: String
    var read: Bool
}
