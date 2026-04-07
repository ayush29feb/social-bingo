import XCTest
@testable import SocialBingo

final class AuthTests: XCTestCase {

    func test_usernameFromEmail_basic() {
        XCTAssertEqual(AuthManager.usernameFrom(email: "alice@example.com"), "alice")
    }

    func test_usernameFromEmail_numbersAllowed() {
        XCTAssertEqual(AuthManager.usernameFrom(email: "user123@test.com"), "user123")
    }

    func test_usernameFromEmail_specialCharsStripped() {
        XCTAssertEqual(AuthManager.usernameFrom(email: "john.doe+tag@example.com"), "johndoetag")
    }

    func test_usernameFromEmail_emptyEmail() {
        let result = AuthManager.usernameFrom(email: "")
        XCTAssertTrue(result.hasPrefix("user"))
        XCTAssertEqual(result.count, 8)
    }

    func test_usernameFromEmail_truncatesAt20() {
        let result = AuthManager.usernameFrom(email: "verylongusernamethatexceedslimit@example.com")
        XCTAssertLessThanOrEqual(result.count, 20)
    }
}
