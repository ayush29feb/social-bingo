import XCTest
@testable import SocialBingo

final class AuthTests: XCTestCase {

    func test_usernameFromAppleName_fullName() {
        var c = PersonNameComponents()
        c.givenName = "Alice"
        c.familyName = "Smith"
        XCTAssertEqual(AuthManager.usernameFrom(appleName: c), "alicesmith")
    }

    func test_usernameFromAppleName_givenNameOnly() {
        var c = PersonNameComponents()
        c.givenName = "Bob"
        XCTAssertEqual(AuthManager.usernameFrom(appleName: c), "bob")
    }

    func test_usernameFromAppleName_nilComponents() {
        let result = AuthManager.usernameFrom(appleName: nil)
        XCTAssertTrue(result.hasPrefix("user"))
        XCTAssertEqual(result.count, 8) // "user" + 4 digits
    }

    func test_usernameFromAppleName_specialChars() {
        var c = PersonNameComponents()
        c.givenName = "Jean-Pierre"
        c.familyName = "O'Brien"
        XCTAssertEqual(AuthManager.usernameFrom(appleName: c), "jeanpierreobrien")
    }

    func test_usernameFromAppleName_truncatesAt20() {
        var c = PersonNameComponents()
        c.givenName = "Alexandrina"
        c.familyName = "Bartholomew"
        let result = AuthManager.usernameFrom(appleName: c)
        XCTAssertLessThanOrEqual(result.count, 20)
    }
}
