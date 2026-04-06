import XCTest
@testable import SocialBingo

final class StorageTests: XCTestCase {
    var suiteName: String!
    var defaults: UserDefaults!
    var storage: AppStorage!

    override func setUp() {
        super.setUp()
        suiteName = "test-\(UUID().uuidString)"
        defaults  = UserDefaults(suiteName: suiteName)!
        storage   = AppStorage(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    // MARK: - Default state

    func test_freshStorage_loadsDefaultUser() {
        XCTAssertEqual(storage.currentUser.id, currentUserId)
        XCTAssertEqual(storage.currentUser.username, "you")
        XCTAssertEqual(storage.currentUser.avatarEmoji, "🎯")
    }

    func test_freshStorage_seedsItems() {
        XCTAssertEqual(storage.bingoItems.count, seedBingoItems.count)
    }

    // MARK: - User

    func test_saveUser_persists() {
        storage.currentUser.username = "testuser"
        storage.currentUser.avatarEmoji = "🤖"
        storage.saveUser()

        let reloaded = AppStorage(defaults: defaults)
        XCTAssertEqual(reloaded.currentUser.username, "testuser")
        XCTAssertEqual(reloaded.currentUser.avatarEmoji, "🤖")
    }

    // MARK: - BingoItem CRUD

    func test_saveBingoItem_addsNewItem() {
        let item = storage.makeItem(position: 4, emoji: "🧪", title: "Test item")
        storage.saveBingoItem(item)
        XCTAssertTrue(storage.bingoItems.contains { $0.id == item.id })
    }

    func test_saveBingoItem_updatesExistingItem() {
        var item = storage.makeItem(position: 4, emoji: "🧪", title: "Original")
        storage.saveBingoItem(item)

        item.title = "Updated"
        storage.saveBingoItem(item)

        let stored = storage.bingoItems.first { $0.id == item.id }
        XCTAssertEqual(stored?.title, "Updated")
    }

    func test_deleteBingoItem_removesItem() {
        let item = storage.makeItem(position: 4, emoji: "🧪", title: "To delete")
        storage.saveBingoItem(item)
        XCTAssertTrue(storage.bingoItems.contains { $0.id == item.id })

        storage.deleteBingoItem(id: item.id)
        XCTAssertFalse(storage.bingoItems.contains { $0.id == item.id })
    }

    func test_bingoItems_persistAcrossReloads() {
        let item = storage.makeItem(position: 4, emoji: "🧪", title: "Persist me")
        storage.saveBingoItem(item)

        let reloaded = AppStorage(defaults: defaults)
        XCTAssertTrue(reloaded.bingoItems.contains { $0.id == item.id })
    }

    func test_makeItem_setsCorrectPosition() {
        let item = storage.makeItem(position: 9, emoji: "🎯", title: "Position test")
        XCTAssertEqual(item.position, 9)
        XCTAssertEqual(item.userId, storage.currentUser.id)
    }

    func test_makeItem_generatesUniqueIds() {
        let a = storage.makeItem(position: 0, emoji: "A", title: "A")
        let b = storage.makeItem(position: 1, emoji: "B", title: "B")
        XCTAssertNotEqual(a.id, b.id)
    }

    // MARK: - Multiple saves

    func test_saveBingoItem_twoItems_noDuplication() {
        let a = storage.makeItem(position: 4,  emoji: "🅰️", title: "A")
        let b = storage.makeItem(position: 9,  emoji: "🅱️", title: "B")
        storage.saveBingoItem(a)
        storage.saveBingoItem(b)

        let aCount = storage.bingoItems.filter { $0.id == a.id }.count
        let bCount = storage.bingoItems.filter { $0.id == b.id }.count
        XCTAssertEqual(aCount, 1)
        XCTAssertEqual(bCount, 1)
    }

    func test_resetForNewUser_clearsItems() {
        let suite = UserDefaults(suiteName: "test_reset")!
        let storage = AppStorage(defaults: suite)
        let item = storage.makeItem(position: 0, emoji: "🎯", title: "Test")
        storage.saveBingoItem(item)
        XCTAssertFalse(storage.bingoItems.isEmpty)

        let newUser = User(id: "real-uuid", username: "alice", avatarEmoji: "🌊", bio: "")
        storage.resetForNewUser(user: newUser)

        XCTAssertEqual(storage.currentUser.id, "real-uuid")
        XCTAssertTrue(storage.bingoItems.isEmpty)
        suite.removePersistentDomain(forName: "test_reset")
    }

    func test_resetForNewUser_persistsUser() {
        let suite = UserDefaults(suiteName: "test_reset_persist")!
        let storage = AppStorage(defaults: suite)
        let newUser = User(id: "real-uuid-2", username: "bob", avatarEmoji: "😊", bio: "hello")
        storage.resetForNewUser(user: newUser)

        let storage2 = AppStorage(defaults: suite)
        XCTAssertEqual(storage2.currentUser.id, "real-uuid-2")
        XCTAssertEqual(storage2.currentUser.username, "bob")
        suite.removePersistentDomain(forName: "test_reset_persist")
    }
}
