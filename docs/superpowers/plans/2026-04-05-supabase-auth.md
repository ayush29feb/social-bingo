# Supabase Auth Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Apple Sign-In backed by Supabase Auth — new users start with a blank card, returning users land straight on their tab bar.

**Architecture:** `AuthManager` (ObservableObject) wraps the Supabase client, owns session state, drives the Apple credential exchange, and creates the Supabase `users` row on first sign-in. `ContentView` routes to `SignInView` or `TabView` based on session presence.

**Tech Stack:** supabase-swift v2 (SPM), AuthenticationServices (Apple Sign-In), SwiftUI iOS 17, XcodeGen

---

## Supabase Setup (manual — user does this before building)

Before running the app, the developer must:

1. Create a Supabase project at supabase.com
2. In **Authentication → Providers**, enable Apple Sign-In and follow the setup guide (requires Apple Developer account — Service ID + key)
3. Copy **Project URL** and **anon public key** from **Settings → API**
4. Run the SQL in `docs/supabase/migrations/001_users.sql` in the **SQL Editor**
5. Fill in `SupabaseConfig.swift` with the URL and anon key

---

### Task 1: Supabase SQL migration file

**Files:**
- Create: `docs/supabase/migrations/001_users.sql`

- [ ] **Step 1: Create migration directory and file**

```sql
-- 001_users.sql
-- Run this in Supabase SQL Editor before launching the app.

create table if not exists users (
  id            uuid primary key references auth.users(id) on delete cascade,
  username      text not null unique,
  avatar_emoji  text not null default '😊',
  bio           text not null default '',
  created_at    timestamptz not null default now()
);

alter table users enable row level security;

create policy "Anyone can read profiles"
  on users for select using (true);

create policy "Own profile insert"
  on users for insert with check (auth.uid() = id);

create policy "Own profile update"
  on users for update using (auth.uid() = id);
```

- [ ] **Step 2: Commit**

```bash
git add docs/supabase/migrations/001_users.sql
git commit -m "feat: add Supabase users table migration"
```

---

### Task 2: Add supabase-swift SPM dependency

**Files:**
- Modify: `SwiftApp/project.yml`

- [ ] **Step 1: Add package and dependency to project.yml**

The final `project.yml` should look like this (full file):

```yaml
name: SocialBingo
options:
  deploymentTarget:
    iOS: "17.0"
  xcodeVersion: "16"
  createIntermediateGroups: true

packages:
  Supabase:
    url: https://github.com/supabase/supabase-swift
    from: 2.0.0

targets:
  SocialBingo:
    type: application
    platform: iOS
    sources:
      - path: SocialBingo
    info:
      path: SocialBingo/Info.plist
      properties:
        CFBundleName: Social Bingo
        UILaunchStoryboardName: ""
        UISupportedInterfaceOrientations:
          - UIInterfaceOrientationPortrait
    dependencies:
      - package: Supabase
        product: Supabase
    settings:
      base:
        SWIFT_VERSION: 5.9
        PRODUCT_BUNDLE_IDENTIFIER: com.example.SocialBingo
        DEVELOPMENT_TEAM: ""

  SocialBingoTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: SocialBingoTests
    dependencies:
      - target: SocialBingo
    settings:
      base:
        SWIFT_VERSION: 5.9
        PRODUCT_BUNDLE_IDENTIFIER: com.example.SocialBingoTests

schemes:
  SocialBingo:
    build:
      targets:
        SocialBingo: all
    run:
      config: Debug
    test:
      config: Debug
      targets:
        - SocialBingoTests
  SocialBingoTests:
    build:
      targets:
        SocialBingoTests: [test]
    test:
      config: Debug
      targets:
        - SocialBingoTests
```

- [ ] **Step 2: Regenerate .xcodeproj**

Run from `SwiftApp/` directory:
```bash
xcodegen generate
```

Expected: prints "Generating plists..." and "Generating project..." with no errors.

- [ ] **Step 3: Verify package resolves**

```bash
xcodebuild -resolvePackageDependencies -project SwiftApp/SocialBingo.xcodeproj -scheme SocialBingo 2>&1 | tail -5
```

Expected: exits 0, no "error:" lines.

- [ ] **Step 4: Commit**

```bash
git add SwiftApp/project.yml SwiftApp/SocialBingo.xcodeproj
git commit -m "feat: add supabase-swift SPM dependency"
```

---

### Task 3: SupabaseConfig.swift

**Files:**
- Create: `SwiftApp/SocialBingo/Config/SupabaseConfig.swift`

Note: `SwiftApp/SocialBingo/Constants/` already exists — put this in the `Config/` group (create it), consistent with the design spec.

- [ ] **Step 1: Create SupabaseConfig.swift**

```swift
import Supabase

enum SupabaseConfig {
    // Replace these with your project values from supabase.com → Settings → API
    static let url = "https://YOUR_PROJECT_REF.supabase.co"
    static let anonKey = "YOUR_ANON_KEY"
}

let supabase = SupabaseClient(
    supabaseURL: URL(string: SupabaseConfig.url)!,
    supabaseKey: SupabaseConfig.anonKey
)
```

- [ ] **Step 2: Verify it compiles**

```bash
swiftc -typecheck SwiftApp/SocialBingo/Config/SupabaseConfig.swift 2>&1
```

Expected: no output (clean).

- [ ] **Step 3: Commit**

```bash
git add SwiftApp/SocialBingo/Config/SupabaseConfig.swift
git commit -m "feat: add SupabaseConfig with placeholder credentials"
```

---

### Task 4: AuthManager.swift

**Files:**
- Create: `SwiftApp/SocialBingo/Auth/AuthManager.swift`

- [ ] **Step 1: Write the failing test first**

Add to `SwiftApp/SocialBingoTests/AuthTests.swift`:

```swift
import XCTest
@testable import SocialBingo

final class AuthTests: XCTestCase {

    func test_usernameFromAppleName_fullName() {
        let components = PersonNameComponents()
        var c = components
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
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
swiftc -typecheck SwiftApp/SocialBingoTests/AuthTests.swift 2>&1
```

Expected: error about `AuthManager` not existing yet — confirms test is wired correctly.

- [ ] **Step 3: Create AuthManager.swift**

```swift
import AuthenticationServices
import CryptoKit
import Foundation
import Supabase

@MainActor
final class AuthManager: NSObject, ObservableObject {
    static let shared = AuthManager()

    @Published var session: Session?
    @Published var isLoading = true

    private var currentNonce: String?

    override init() {
        super.init()
        Task { await restoreSession() }
    }

    // MARK: - Session restore

    private func restoreSession() async {
        session = try? await supabase.auth.session
        isLoading = false
    }

    // MARK: - Apple Sign-In

    func startAppleSignIn() {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }

    // MARK: - Username generation (internal for testability)

    static func usernameFrom(appleName: PersonNameComponents?) -> String {
        let raw = [appleName?.givenName, appleName?.familyName]
            .compactMap { $0 }
            .joined()
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
        let trimmed = String(raw.prefix(20))
        return trimmed.isEmpty ? "user\(Int.random(in: 1000...9999))" : trimmed
    }

    // MARK: - Private helpers

    private func randomNonceString(length: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    private func ensureUserProfile(userId: UUID, appleName: PersonNameComponents?) async {
        // Check if profile already exists
        let existing = try? await supabase
            .from("users")
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()

        // If we got a non-empty response, user already exists
        if let data = existing?.data, !data.isEmpty, data != Data("[]".utf8) {
            return
        }

        // New user — create profile
        let emojis = ["😊","🌊","🎸","🌿","🚀","🎯","🦊","🌙","⚡️","🎨"]
        let profile: [String: String] = [
            "id": userId.uuidString,
            "username": AuthManager.usernameFrom(appleName: appleName),
            "avatar_emoji": emojis.randomElement() ?? "😊",
            "bio": ""
        ]

        _ = try? await supabase
            .from("users")
            .insert(profile)
            .execute()

        // Clear any local prototype data and configure AppStorage
        let user = User(
            id: userId.uuidString,
            username: profile["username"] ?? "user",
            avatarEmoji: profile["avatar_emoji"] ?? "😊",
            bio: ""
        )
        if AppStorage.shared.currentUser.id == "current-user" {
            AppStorage.shared.resetForNewUser(user: user)
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce,
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else { return }

        Task {
            do {
                let session = try await supabase.auth.signInWithIdToken(
                    credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
                )
                await ensureUserProfile(userId: session.user.id, appleName: credential.fullName)
                self.session = session
            } catch {
                print("[AuthManager] Sign-in error: \(error)")
            }
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        print("[AuthManager] Apple Sign-In cancelled or failed: \(error)")
    }
}
```

- [ ] **Step 4: Run typecheck**

```bash
swiftc -typecheck \
  SwiftApp/SocialBingo/Auth/AuthManager.swift \
  SwiftApp/SocialBingo/Config/SupabaseConfig.swift \
  SwiftApp/SocialBingo/Data/AppStorage.swift \
  SwiftApp/SocialBingo/Models/Models.swift \
  2>&1
```

Expected: no errors (may warn about unresolved Supabase module without full build — that's OK at typecheck stage without SPM resolution).

- [ ] **Step 5: Commit**

```bash
git add SwiftApp/SocialBingo/Auth/AuthManager.swift SwiftApp/SocialBingoTests/AuthTests.swift
git commit -m "feat: add AuthManager with Apple Sign-In + username generation"
```

---

### Task 5: AppStorage.resetForNewUser

**Files:**
- Modify: `SwiftApp/SocialBingo/Data/AppStorage.swift`
- Modify: `SwiftApp/SocialBingoTests/StorageTests.swift`

- [ ] **Step 1: Write the failing test**

Add to `StorageTests.swift` inside the `StorageTests` class:

```swift
func test_resetForNewUser_clearsItems() {
    let suite = UserDefaults(suiteName: "test_reset")!
    let storage = AppStorage(defaults: suite)
    // Seed an item first
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

    // Reload from same suite to verify persistence
    let storage2 = AppStorage(defaults: suite)
    XCTAssertEqual(storage2.currentUser.id, "real-uuid-2")
    XCTAssertEqual(storage2.currentUser.username, "bob")
    suite.removePersistentDomain(forName: "test_reset_persist")
}
```

- [ ] **Step 2: Run typecheck to confirm test references missing method**

```bash
swiftc -typecheck SwiftApp/SocialBingoTests/StorageTests.swift 2>&1 | head -5
```

Expected: error mentioning `resetForNewUser`.

- [ ] **Step 3: Add resetForNewUser to AppStorage**

Add this method to `AppStorage.swift` after `deleteBingoItem`:

```swift
func resetForNewUser(user: User) {
    defaults.removeObject(forKey: userKey)
    defaults.removeObject(forKey: itemsKey)
    currentUser = user
    bingoItems = []
    saveUser()
}
```

- [ ] **Step 4: Typecheck both files**

```bash
swiftc -typecheck \
  SwiftApp/SocialBingo/Data/AppStorage.swift \
  SwiftApp/SocialBingo/Models/Models.swift \
  SwiftApp/SocialBingo/Data/MockData.swift \
  2>&1
```

Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add SwiftApp/SocialBingo/Data/AppStorage.swift SwiftApp/SocialBingoTests/StorageTests.swift
git commit -m "feat: add AppStorage.resetForNewUser for post-auth data clear"
```

---

### Task 6: SignInView.swift

**Files:**
- Create: `SwiftApp/SocialBingo/Auth/SignInView.swift`

- [ ] **Step 1: Create SignInView.swift**

```swift
import AuthenticationServices
import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Text("🎯")
                    .font(.system(size: 64))
                Text("Social Bingo")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.appPrimary)
                Text("Your bucket list, shared with friends.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            SignInWithAppleButton(
                .signIn,
                onRequest: { _ in },
                onCompletion: { _ in }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal, 40)
            .onTapGesture {
                authManager.startAppleSignIn()
            }

            Spacer()
                .frame(height: 32)
        }
        .padding()
    }
}
```

- [ ] **Step 2: Typecheck**

```bash
swiftc -typecheck SwiftApp/SocialBingo/Auth/SignInView.swift 2>&1
```

Expected: no errors (may warn about missing module without full build).

- [ ] **Step 3: Commit**

```bash
git add SwiftApp/SocialBingo/Auth/SignInView.swift
git commit -m "feat: add SignInView with Apple Sign-In button"
```

---

### Task 7: Wire AuthManager into app entry point and ContentView

**Files:**
- Modify: `SwiftApp/SocialBingo/SocialBingoApp.swift`
- Modify: `SwiftApp/SocialBingo/ContentView.swift`

- [ ] **Step 1: Update SocialBingoApp.swift**

Replace the entire file:

```swift
import SwiftUI

@main
struct SocialBingoApp: App {
    @StateObject private var storage = AppStorage.shared
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storage)
                .environmentObject(authManager)
        }
    }
}
```

- [ ] **Step 2: Update ContentView.swift**

Replace the entire file:

```swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var storage: AppStorage
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        Group {
            if authManager.isLoading {
                ProgressView()
            } else if authManager.session == nil {
                SignInView()
            } else {
                mainTabView
            }
        }
    }

    private var mainTabView: some View {
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
                .badge(getUnreadCount())
        }
        .tint(.appPrimary)
    }
}
```

- [ ] **Step 3: Typecheck both files**

```bash
swiftc -typecheck \
  SwiftApp/SocialBingo/SocialBingoApp.swift \
  SwiftApp/SocialBingo/ContentView.swift \
  2>&1
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add SwiftApp/SocialBingo/SocialBingoApp.swift SwiftApp/SocialBingo/ContentView.swift
git commit -m "feat: wire AuthManager into app — route to SignInView or TabView"
```

---

### Task 8: Final integration check

**Files:**
- Read: all new/modified Swift files

- [ ] **Step 1: Typecheck all new Auth files together**

```bash
swiftc -typecheck \
  SwiftApp/SocialBingo/Config/SupabaseConfig.swift \
  SwiftApp/SocialBingo/Auth/AuthManager.swift \
  SwiftApp/SocialBingo/Auth/SignInView.swift \
  SwiftApp/SocialBingo/ContentView.swift \
  SwiftApp/SocialBingo/SocialBingoApp.swift \
  SwiftApp/SocialBingo/Data/AppStorage.swift \
  SwiftApp/SocialBingo/Models/Models.swift \
  SwiftApp/SocialBingo/Data/MockData.swift \
  2>&1
```

Expected: no errors.

- [ ] **Step 2: Verify xcodegen still generates cleanly**

```bash
cd SwiftApp && xcodegen generate 2>&1
```

Expected: "Generating project SocialBingo" with no errors.

- [ ] **Step 3: Confirm all new files are tracked in git**

```bash
git status
```

Expected: clean working tree.

- [ ] **Step 4: Final commit if anything remains unstaged**

```bash
git add -A
git status
# Only commit if there are staged changes
```
