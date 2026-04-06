import Foundation
import Combine

final class AppStorage: ObservableObject {
    static let shared = AppStorage()

    @Published var currentUser: User
    @Published var bingoItems: [BingoItem]

    private let defaults: UserDefaults
    private let userKey  = "social_bingo_user"
    private let itemsKey = "social_bingo_items"

    /// Designated init — pass a custom UserDefaults suite for testing.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        // Temporary values — replaced immediately by load()
        self.currentUser = User(id: currentUserId, username: "you", avatarEmoji: "🎯", bio: "")
        self.bingoItems  = []
        loadData()
    }

    // MARK: - User

    func saveUser() {
        guard let data = try? JSONEncoder().encode(currentUser) else { return }
        defaults.set(data, forKey: userKey)
    }

    // MARK: - Bingo items

    func saveBingoItem(_ item: BingoItem) {
        if let idx = bingoItems.firstIndex(where: { $0.id == item.id }) {
            bingoItems[idx] = item
        } else {
            bingoItems.append(item)
        }
        persistItems()
    }

    func deleteBingoItem(id: String) {
        bingoItems.removeAll { $0.id == id }
        persistItems()
    }

    func makeItem(position: Int, emoji: String, title: String,
                  description: String = "", url: String = "") -> BingoItem {
        BingoItem(
            id: "item-\(Int(Date().timeIntervalSince1970 * 1000))-\(Int.random(in: 1000...9999))",
            userId: currentUser.id,
            position: position,
            emoji: emoji,
            title: title,
            description: description,
            url: url,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    // MARK: - Private

    private func loadData() {
        if let data = defaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
        // else keep default constructed above

        if let data = defaults.data(forKey: itemsKey),
           let items = try? JSONDecoder().decode([BingoItem].self, from: data) {
            bingoItems = items
        } else {
            bingoItems = seedBingoItems
            persistItems()
        }
    }

    private func persistItems() {
        guard let data = try? JSONEncoder().encode(bingoItems) else { return }
        defaults.set(data, forKey: itemsKey)
    }
}
