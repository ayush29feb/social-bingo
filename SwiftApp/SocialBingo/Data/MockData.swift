import Foundation

// MARK: - Current User

let currentUserId = "current-user"

// MARK: - Seed items for current user's card (20 of 25 positions filled)

let seedBingoItems: [BingoItem] = [
    BingoItem(id: "mi-0",  userId: currentUserId, position: 0,  emoji: "🗼", title: "Visit Paris",        description: "Eiffel Tower, Louvre, crepes",   url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-1",  userId: currentUserId, position: 1,  emoji: "🏄", title: "Learn surfing",      description: "Take lessons on the coast",       url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-2",  userId: currentUserId, position: 2,  emoji: "🎸", title: "Play guitar",        description: "Learn 10 songs",                  url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-3",  userId: currentUserId, position: 3,  emoji: "🍣", title: "Sushi class",        description: "Learn to roll maki",              url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-5",  userId: currentUserId, position: 5,  emoji: "🏔️", title: "Hike a peak",        description: "Over 3000m elevation",            url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-6",  userId: currentUserId, position: 6,  emoji: "🎨", title: "Take art class",     description: "Watercolor or oil painting",      url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-7",  userId: currentUserId, position: 7,  emoji: "🏊", title: "Open water swim",    description: "Ocean or lake swim",              url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-8",  userId: currentUserId, position: 8,  emoji: "🌮", title: "Taco crawl",         description: "5 taquerias in one day",          url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-10", userId: currentUserId, position: 10, emoji: "🎭", title: "Broadway show",      description: "See a live performance",          url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-11", userId: currentUserId, position: 11, emoji: "🚴", title: "Bike a century",     description: "100 miles in a day",              url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-12", userId: currentUserId, position: 12, emoji: "🌅", title: "Watch sunrise",      description: "From a mountain or rooftop",      url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-13", userId: currentUserId, position: 13, emoji: "🍕", title: "Make pizza",         description: "From scratch with sourdough",     url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-14", userId: currentUserId, position: 14, emoji: "🎻", title: "Concert night",      description: "Classical or jazz",               url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-15", userId: currentUserId, position: 15, emoji: "🧗", title: "Rock climbing",      description: "Outdoor wall, not gym",           url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-16", userId: currentUserId, position: 16, emoji: "🌍", title: "Road trip",          description: "Two weeks, no fixed plan",        url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-17", userId: currentUserId, position: 17, emoji: "🎬", title: "Film a short",       description: "Write, direct, edit",             url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-18", userId: currentUserId, position: 18, emoji: "🥾", title: "Camping weekend",    description: "No phone, real fire",             url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-19", userId: currentUserId, position: 19, emoji: "🎯", title: "Archery range",      description: "Hit a bullseye",                  url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-20", userId: currentUserId, position: 20, emoji: "🎲", title: "Board game cafe",    description: "Try 3 new games",                 url: "", createdAt: "2024-01-01T00:00:00Z"),
    BingoItem(id: "mi-21", userId: currentUserId, position: 21, emoji: "🌸", title: "Cherry blossoms",    description: "Japan in spring",                 url: "", createdAt: "2024-01-01T00:00:00Z"),
]

// MARK: - Mock friends

let mockUsers: [User] = [
    User(id: "alex",   username: "alex",   avatarEmoji: "😄", bio: "Love trying new things"),
    User(id: "maya",   username: "maya",   avatarEmoji: "🌊", bio: "Adventure seeker"),
    User(id: "sam",    username: "sam",    avatarEmoji: "🎸", bio: "Music is life"),
    User(id: "jordan", username: "jordan", avatarEmoji: "🌿", bio: "Nature lover"),
]

// MARK: - Friendships (current user is friends with all mockUsers)

let mockFriendships: [Friendship] = [
    Friendship(id: "f-1", userAId: currentUserId, userBId: "alex"),
    Friendship(id: "f-2", userAId: currentUserId, userBId: "maya"),
    Friendship(id: "f-3", userAId: currentUserId, userBId: "sam"),
    Friendship(id: "f-4", userAId: currentUserId, userBId: "jordan"),
]

// MARK: - Mock friend bingo items (25 per friend)

let mockFriendItems: [String: [BingoItem]] = [
    "alex": (0..<25).map { pos in
        let items: [(String, String)] = [
            ("🗽", "Visit NYC"), ("🏄", "Surf Pipeline"), ("🎸", "Jam session"), ("🍜", "Ramen crawl"), ("🧁", "Bake sourdough"),
            ("🏔️", "Climb Rainier"), ("🎨", "Pottery class"), ("🏊", "Swim English Channel"), ("🌮", "Eat 100 tacos"), ("🎭", "Improv class"),
            ("🚴", "Tour de France"), ("🌅", "See aurora"), ("🍕", "Naples pizza"), ("🎻", "Vienna concert"), ("🧗", "El Cap"),
            ("✈️", "Around the world"), ("🎬", "Make a doc"), ("🏕️", "Appalachian Trail"), ("🎯", "Olympic archery"), ("🎲", "Vegas trip"),
            ("🌸", "Kyoto spring"), ("🐬", "Swim with dolphins"), ("🥋", "Black belt"), ("🏇", "Kentucky Derby"), ("🎪", "Burning Man"),
        ]
        return BingoItem(id: "alex-\(pos)", userId: "alex", position: pos, emoji: items[pos].0, title: items[pos].1, description: "", url: "", createdAt: "2024-01-01T00:00:00Z")
    },
    "maya": (0..<25).map { pos in
        let items: [(String, String)] = [
            ("🤿", "Scuba dive"), ("🧘", "Yoga retreat"), ("🍷", "Wine harvest"), ("🎿", "Ski Japan"), ("🎪", "Coachella"),
            ("🏔️", "Everest base camp"), ("🎨", "Paint en plein air"), ("🏊", "Ironman"), ("🌮", "Mexico City tour"), ("🎭", "West End show"),
            ("🚴", "Coast to coast"), ("🌅", "Santorini sunset"), ("🍕", "Pizza making"), ("🎻", "Open mic night"), ("🧗", "Yosemite valley"),
            ("🌍", "Cross-country drive"), ("🎬", "Short film"), ("🥾", "Pacific Crest Trail"), ("🎯", "Axe throwing"), ("🎲", "Monte Carlo"),
            ("🌸", "Tulip fields"), ("🐬", "Whale watching"), ("🥋", "Kickboxing"), ("🏇", "Horse riding"), ("🎪", "Glastonbury"),
        ]
        return BingoItem(id: "maya-\(pos)", userId: "maya", position: pos, emoji: items[pos].0, title: items[pos].1, description: "", url: "", createdAt: "2024-01-01T00:00:00Z")
    },
    "sam": (0..<25).map { pos in
        let items: [(String, String)] = [
            ("🎵", "Record album"), ("🎸", "Headline festival"), ("🎤", "Open mic"), ("🎺", "Learn trumpet"), ("🥁", "Drum solo"),
            ("🏔️", "Trek Nepal"), ("🎨", "Street art"), ("🏊", "Cold plunge"), ("🌮", "Street food tour"), ("🎭", "Music theater"),
            ("🚴", "Bike Italy"), ("🌅", "Desert sunrise"), ("🍕", "Wood-fired pizza"), ("🎻", "Orchestra seat"), ("🧗", "Bouldering"),
            ("🌍", "Van life month"), ("🎬", "Music video"), ("🥾", "Camino de Santiago"), ("🎯", "Escape room"), ("🎲", "Poker tournament"),
            ("🌸", "Festival season"), ("🐬", "Kayak sea caves"), ("🥋", "Jiu-jitsu"), ("🏇", "Polo match"), ("🎪", "SXSW"),
        ]
        return BingoItem(id: "sam-\(pos)", userId: "sam", position: pos, emoji: items[pos].0, title: items[pos].1, description: "", url: "", createdAt: "2024-01-01T00:00:00Z")
    },
    "jordan": (0..<25).map { pos in
        let items: [(String, String)] = [
            ("🌿", "Grow own food"), ("🐝", "Keep bees"), ("🌲", "Forest bathing"), ("🍄", "Mushroom foraging"), ("🦋", "Butterfly garden"),
            ("🏔️", "Glacier hike"), ("🎨", "Nature photography"), ("🏊", "Wild swimming"), ("🌮", "Farm-to-table"), ("🎭", "Nature documentary"),
            ("🚴", "Green routes"), ("🌅", "Stargazing camp"), ("🍕", "Foraged pizza"), ("🎻", "Outdoor concert"), ("🧗", "Sea cliff"),
            ("🌍", "Eco travel"), ("🎬", "Wildlife doc"), ("🥾", "Long distance trail"), ("🎯", "Wildlife tracking"), ("🎲", "Nature trivia"),
            ("🌸", "Wildflower meadow"), ("🐬", "Swim with seals"), ("🥋", "Tai chi"), ("🏇", "Horse trek"), ("🎪", "Ecology fest"),
        ]
        return BingoItem(id: "jordan-\(pos)", userId: "jordan", position: pos, emoji: items[pos].0, title: items[pos].1, description: "", url: "", createdAt: "2024-01-01T00:00:00Z")
    },
]

// MARK: - Plus-ones on current user's items (from friends)

let mockPlusOnes: [PlusOne] = [
    PlusOne(id: "po-1",  itemId: "mi-0",  fromUserId: "alex",   createdAt: "2024-01-10T09:00:00Z"),
    PlusOne(id: "po-2",  itemId: "mi-0",  fromUserId: "maya",   createdAt: "2024-01-11T10:00:00Z"),
    PlusOne(id: "po-3",  itemId: "mi-1",  fromUserId: "sam",    createdAt: "2024-01-12T11:00:00Z"),
    PlusOne(id: "po-4",  itemId: "mi-3",  fromUserId: "jordan", createdAt: "2024-01-13T12:00:00Z"),
    PlusOne(id: "po-5",  itemId: "mi-3",  fromUserId: "alex",   createdAt: "2024-01-14T13:00:00Z"),
    PlusOne(id: "po-6",  itemId: "mi-6",  fromUserId: "maya",   createdAt: "2024-01-15T14:00:00Z"),
    PlusOne(id: "po-7",  itemId: "mi-10", fromUserId: "sam",    createdAt: "2024-01-16T15:00:00Z"),
    PlusOne(id: "po-8",  itemId: "mi-10", fromUserId: "jordan", createdAt: "2024-01-17T16:00:00Z"),
    PlusOne(id: "po-9",  itemId: "mi-10", fromUserId: "alex",   createdAt: "2024-01-18T17:00:00Z"),
    PlusOne(id: "po-10", itemId: "mi-12", fromUserId: "maya",   createdAt: "2024-01-19T18:00:00Z"),
    PlusOne(id: "po-11", itemId: "mi-16", fromUserId: "sam",    createdAt: "2024-01-20T19:00:00Z"),
    PlusOne(id: "po-12", itemId: "mi-16", fromUserId: "jordan", createdAt: "2024-01-21T20:00:00Z"),
    PlusOne(id: "po-13", itemId: "mi-21", fromUserId: "alex",   createdAt: "2024-01-22T21:00:00Z"),
    PlusOne(id: "po-14", itemId: "mi-21", fromUserId: "maya",   createdAt: "2024-01-23T22:00:00Z"),
]

// MARK: - Notifications (3 unread, 7 read)

let mockNotifications: [NotificationItem] = [
    NotificationItem(id: "n-1",  itemId: "mi-21", itemTitle: "Cherry blossoms", fromUserId: "maya",   fromUsername: "maya",   fromAvatarEmoji: "🌊", createdAt: "2024-01-23T22:00:00Z", read: false),
    NotificationItem(id: "n-2",  itemId: "mi-21", itemTitle: "Cherry blossoms", fromUserId: "alex",   fromUsername: "alex",   fromAvatarEmoji: "😄", createdAt: "2024-01-22T21:00:00Z", read: false),
    NotificationItem(id: "n-3",  itemId: "mi-16", itemTitle: "Road trip",       fromUserId: "jordan", fromUsername: "jordan", fromAvatarEmoji: "🌿", createdAt: "2024-01-21T20:00:00Z", read: false),
    NotificationItem(id: "n-4",  itemId: "mi-16", itemTitle: "Road trip",       fromUserId: "sam",    fromUsername: "sam",    fromAvatarEmoji: "🎸", createdAt: "2024-01-20T19:00:00Z", read: true),
    NotificationItem(id: "n-5",  itemId: "mi-12", itemTitle: "Watch sunrise",   fromUserId: "maya",   fromUsername: "maya",   fromAvatarEmoji: "🌊", createdAt: "2024-01-19T18:00:00Z", read: true),
    NotificationItem(id: "n-6",  itemId: "mi-10", itemTitle: "Broadway show",   fromUserId: "alex",   fromUsername: "alex",   fromAvatarEmoji: "😄", createdAt: "2024-01-18T17:00:00Z", read: true),
    NotificationItem(id: "n-7",  itemId: "mi-10", itemTitle: "Broadway show",   fromUserId: "jordan", fromUsername: "jordan", fromAvatarEmoji: "🌿", createdAt: "2024-01-17T16:00:00Z", read: true),
    NotificationItem(id: "n-8",  itemId: "mi-10", itemTitle: "Broadway show",   fromUserId: "sam",    fromUsername: "sam",    fromAvatarEmoji: "🎸", createdAt: "2024-01-16T15:00:00Z", read: true),
    NotificationItem(id: "n-9",  itemId: "mi-6",  itemTitle: "Take art class",  fromUserId: "maya",   fromUsername: "maya",   fromAvatarEmoji: "🌊", createdAt: "2024-01-15T14:00:00Z", read: true),
    NotificationItem(id: "n-10", itemId: "mi-3",  itemTitle: "Sushi class",     fromUserId: "alex",   fromUsername: "alex",   fromAvatarEmoji: "😄", createdAt: "2024-01-14T13:00:00Z", read: true),
]

// MARK: - Helpers

/// Returns a map of grid position → plus-one count for the current user's items.
func getPlusOneCounts(for items: [BingoItem]) -> [Int: Int] {
    var counts: [Int: Int] = [:]
    for item in items {
        let count = mockPlusOnes.filter { $0.itemId == item.id }.count
        if count > 0 {
            counts[item.position] = count
        }
    }
    return counts
}

func getUnreadCount() -> Int {
    mockNotifications.filter { !$0.read }.count
}

func getMockUser(id: String) -> User? {
    mockUsers.first { $0.id == id }
}

func getFriendItems(for userId: String) -> [BingoItem] {
    mockFriendItems[userId] ?? []
}
