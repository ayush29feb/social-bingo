# Apple Foundation Models Chat — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Chat tab to Social Bingo backed by Apple's on-device Foundation Models framework (iOS 26), with full bingo card + friends context injected as a system prompt.

**Architecture:** `ChatViewModel` owns the `LanguageModelSession` and builds the system prompt from `AppStorage` + `MockData`. `ChatView` is a standard SwiftUI message list with streaming token display. Chat tab is guarded by `#available(iOS 26, *)` in `ContentView`.

**Tech Stack:** `FoundationModels` framework (iOS 26), SwiftUI iOS 17 deployment target, `AppStorage` + `MockData` for context

---

## Foundation Models API Reference

The implementer MUST use this exact API — do not guess or use older APIs:

```swift
import FoundationModels

// Create session with system prompt
let session = LanguageModelSession(instructions: "system prompt here")

// Streaming response (returns AsyncSequence of String chunks)
let stream = session.streamResponse(to: "user message")
for try await partialText in stream {
    // partialText: String — accumulated text so far (not a delta)
}

// Availability check
if #available(iOS 26, *) {
    // Foundation Models available
}
```

If the build fails with these exact signatures, check Apple's Foundation Models WWDC25 session and adjust.

---

## File Map

| Action | Path | Responsibility |
|--------|------|---------------|
| Create | `SwiftApp/SocialBingo/Views/Chat/ChatMessage.swift` | `Identifiable` value type for a single chat message |
| Create | `SwiftApp/SocialBingo/Views/Chat/ChatViewModel.swift` | Session management, system prompt builder, `sendMessage` |
| Create | `SwiftApp/SocialBingo/Views/Chat/ChatView.swift` | Full chat tab UI — message list + input bar |
| Modify | `SwiftApp/SocialBingo/ContentView.swift` | Add Chat tab inside `#available(iOS 26, *)` guard |

---

### Task 1: ChatMessage.swift

**Files:**
- Create: `SwiftApp/SocialBingo/Views/Chat/ChatMessage.swift`

- [ ] **Step 1: Create the file**

```swift
import Foundation

enum ChatRole {
    case user
    case assistant
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: ChatRole
    var content: String
    var isStreaming: Bool = false
}
```

- [ ] **Step 2: Typecheck**

```bash
swiftc -typecheck SwiftApp/SocialBingo/Views/Chat/ChatMessage.swift 2>&1
```

Expected: no output (clean).

- [ ] **Step 3: Commit**

```bash
git add SwiftApp/SocialBingo/Views/Chat/ChatMessage.swift
git commit -m "feat: add ChatMessage model"
```

---

### Task 2: ChatViewModel.swift

**Files:**
- Create: `SwiftApp/SocialBingo/Views/Chat/ChatViewModel.swift`

The system prompt is built from:
- `AppStorage.shared.currentUser` — `username`, `avatarEmoji`
- `AppStorage.shared.bingoItems` — sorted by `position`, formatted as `{emoji} {title}` + optional ` — {description}`
- `mockUsers` and `mockFriendItems` from `MockData.swift` — friends listed as `{username} {avatarEmoji}: {emoji} {title}, ...`

- [ ] **Step 1: Create ChatViewModel.swift**

```swift
import Foundation
import SwiftUI

@available(iOS 26, *)
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isStreaming: Bool = false
    @Published var sessionError: String? = nil

    private var session: LanguageModelSession?

    init() {
        do {
            session = try LanguageModelSession(instructions: buildSystemPrompt())
        } catch {
            sessionError = "Chat unavailable on this device."
        }
    }

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isStreaming, session != nil else { return }

        inputText = ""
        messages.append(ChatMessage(role: .user, content: text))

        var assistantMessage = ChatMessage(role: .assistant, content: "", isStreaming: true)
        messages.append(assistantMessage)
        let assistantIndex = messages.count - 1
        isStreaming = true

        do {
            let stream = session!.streamResponse(to: text)
            for try await partialText in stream {
                messages[assistantIndex].content = partialText
            }
            messages[assistantIndex].isStreaming = false
        } catch {
            messages[assistantIndex].content = "Sorry, something went wrong."
            messages[assistantIndex].isStreaming = false
        }

        isStreaming = false
    }

    // MARK: - System prompt

    private func buildSystemPrompt() -> String {
        let user = AppStorage.shared.currentUser
        let items = AppStorage.shared.bingoItems.sorted { $0.position < $1.position }

        var prompt = """
        You are a helpful assistant inside Social Bingo, a bucket list app.

        The user's name is \(user.username) (\(user.avatarEmoji)).
        Their bingo card has \(items.count) items:
        """

        for item in items {
            if item.description.isEmpty {
                prompt += "\n- \(item.emoji) \(item.title)"
            } else {
                prompt += "\n- \(item.emoji) \(item.title) — \(item.description)"
            }
        }

        prompt += "\n\nTheir friends and their cards:"
        for friend in mockUsers {
            let friendItems = mockFriendItems[friend.id] ?? []
            let titles = friendItems.map { "\($0.emoji) \($0.title)" }.joined(separator: ", ")
            prompt += "\n\(friend.username) \(friend.avatarEmoji): \(titles)"
        }

        prompt += "\n\nAnswer concisely. Help the user think about their bucket list goals, suggest new ideas, or find experiences they could share with friends."

        return prompt
    }
}
```

Note: `LanguageModelSession(instructions:)` may throw — the `do/catch` in `init()` handles this. If the actual API is `init(model:instructions:)` or non-throwing, adjust accordingly.

- [ ] **Step 2: Commit**

```bash
git add SwiftApp/SocialBingo/Views/Chat/ChatViewModel.swift
git commit -m "feat: add ChatViewModel with system prompt and streaming"
```

---

### Task 3: ChatView.swift

**Files:**
- Create: `SwiftApp/SocialBingo/Views/Chat/ChatView.swift`

- [ ] **Step 1: Create ChatView.swift**

```swift
import SwiftUI

@available(iOS 26, *)
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let error = viewModel.sessionError {
                    ContentUnavailableView(error, systemImage: "exclamationmark.bubble")
                } else {
                    messageList
                    inputBar
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Message list

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.messages.isEmpty {
                        emptyState
                    }
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                if let last = viewModel.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: viewModel.messages.last?.content) { _, _ in
                if let last = viewModel.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("💬")
                .font(.system(size: 48))
            Text("Ask about your bucket list")
                .font(.headline)
            Text("Get ideas, find shared goals with friends, or just explore what's on your card.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, 32)
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Message", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
                .disabled(viewModel.isStreaming)

            Button {
                Task { await viewModel.sendMessage() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isStreaming ? Color.gray : Color.appPrimary)
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isStreaming)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }
}

// MARK: - MessageBubble

@available(iOS 26, *)
struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 48) }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 2) {
                Text(message.content.isEmpty && message.isStreaming ? "…" : message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.role == .user ? Color.appPrimary : Color(.systemGray5))
                    .foregroundStyle(message.role == .user ? .white : Color.appText)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            if message.role == .assistant { Spacer(minLength: 48) }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add SwiftApp/SocialBingo/Views/Chat/ChatView.swift
git commit -m "feat: add ChatView with streaming message bubbles"
```

---

### Task 4: Wire Chat tab into ContentView

**Files:**
- Modify: `SwiftApp/SocialBingo/ContentView.swift`

- [ ] **Step 1: Read the current ContentView.swift**

The current file is at `SwiftApp/SocialBingo/ContentView.swift`. It has a `mainTabView` computed property with 3 tabs.

- [ ] **Step 2: Replace ContentView.swift**

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

            if #available(iOS 26, *) {
                ChatView()
                    .tabItem {
                        Label("Chat", systemImage: "bubble.left.and.bubble.right")
                    }
            }
        }
        .tint(.appPrimary)
    }
}
```

- [ ] **Step 3: Build and run tests**

```bash
cd /path/to/worktree/SwiftApp && xcodebuild test -scheme SocialBingoTests -destination 'platform=iOS Simulator,name=iPhone 17' 2>&1 | grep -E "Test Suite|error:|passed|failed|Build succeeded|Build FAILED" | tail -20
```

Expected: all 17 tests pass, no build errors.

- [ ] **Step 4: Commit**

```bash
git add SwiftApp/SocialBingo/ContentView.swift
git commit -m "feat: add Chat tab to ContentView (iOS 26+)"
```

---

### Task 5: Final integration check

**Files:** Read-only verification

- [ ] **Step 1: Regenerate .xcodeproj**

```bash
cd SwiftApp && xcodegen generate 2>&1
```

Expected: "Generating project SocialBingo" with no errors.

- [ ] **Step 2: Run full test suite**

```bash
xcodebuild test -scheme SocialBingoTests -destination 'platform=iOS Simulator,name=iPhone 17' 2>&1 | grep -E "Test Suite|error:|passed|failed|Build succeeded|Build FAILED" | tail -20
```

Expected: 17 tests pass.

- [ ] **Step 3: Verify git log**

```bash
git log --oneline -8
```

Expected: 5 new commits visible on the branch.

- [ ] **Step 4: Push**

```bash
git push 2>&1
```

- [ ] **Step 5: Commit plan doc from main worktree**

The plan doc lives in the main worktree. Copy and commit it in the feature worktree:

```bash
cp /Users/ayush29feb/Developement/social-bingo/docs/superpowers/plans/2026-04-07-apple-foundation-chat.md \
   <worktree_path>/docs/superpowers/plans/

cp /Users/ayush29feb/Developement/social-bingo/docs/superpowers/specs/2026-04-07-apple-foundation-chat-design.md \
   <worktree_path>/docs/superpowers/specs/

git add docs/superpowers/plans/2026-04-07-apple-foundation-chat.md \
        docs/superpowers/specs/2026-04-07-apple-foundation-chat-design.md
git commit -m "docs: add Foundation Models chat spec and plan"
git push 2>&1
```
