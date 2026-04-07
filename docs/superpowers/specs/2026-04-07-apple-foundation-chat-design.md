# Apple Foundation Models Chat — Design Spec
Date: 2026-04-07

## Overview

Add a Chat tab to Social Bingo powered by Apple's on-device Foundation Models framework (iOS 26). The assistant knows the user's bingo card and all friends' cards, acting as a neutral bucket-list assistant. Chat is session-only (no persistence) — each visit starts fresh with current context.

---

## Platform & Stack

- **Framework:** `FoundationModels` (iOS 26+)
- **Model:** `SystemLanguageModel.default` (on-device, private, free)
- **Deployment target:** stays iOS 17 — chat tab is conditionally shown with `#available(iOS 26, *)`
- **State:** `@MainActor ObservableObject` (`ChatViewModel`)

---

## Architecture

### New files

| File | Responsibility |
|------|---------------|
| `SwiftApp/SocialBingo/Views/Chat/ChatMessage.swift` | `Identifiable` value type: `id`, `role` (user/assistant), `content: String`, `isStreaming: Bool` |
| `SwiftApp/SocialBingo/Views/Chat/ChatViewModel.swift` | Owns `LanguageModelSession`, message array, `sendMessage(text:)`, system prompt builder |
| `SwiftApp/SocialBingo/Views/Chat/ChatView.swift` | Chat tab UI: scrollable message list + text input + send button; streams tokens as they arrive |

### Modified files

| File | Change |
|------|--------|
| `SwiftApp/SocialBingo/ContentView.swift` | Add Chat tab with `bubble.left.and.bubble.right` SF Symbol, wrapped in `#available(iOS 26, *)` |

---

## System Prompt

Built once in `ChatViewModel.init()`, stays fixed for the session:

```
You are a helpful assistant inside Social Bingo, a bucket list app.

The user's name is {username} ({avatarEmoji}).
Their bingo card has {N} items:
- {emoji} {title} — {description}
...

Their friends and their cards:
{friendUsername} {friendEmoji}: {emoji} {title}, {emoji} {title}, ...
...

Answer concisely. Help the user think about their bucket list goals,
suggest new ideas, or find experiences they could share with friends.
```

- Items with no description omit the ` — {description}` part
- Friends' items are title-only (no descriptions) to keep prompt compact
- Uses `AppStorage.shared.currentUser`, `AppStorage.shared.bingoItems`, and `MockData.mockFriends` + their items

---

## Chat Flow

1. User opens Chat tab → `ChatViewModel` initializes, creates `LanguageModelSession` with system prompt
2. User types message → taps Send → `sendMessage(text:)` called
3. User message appended to `messages` immediately
4. Assistant message appended with `isStreaming: true`, `content: ""`
5. Tokens stream in via async for loop, appended to last message's content
6. `isStreaming` set to `false` when stream completes
7. Input field re-enabled

---

## UI

- **Message list:** `ScrollView` + `LazyVStack`, auto-scrolls to bottom on new content
- **User bubbles:** right-aligned, `appPrimary` background, white text
- **Assistant bubbles:** left-aligned, light gray background, `appText` color
- **Input area:** `TextField` + send `Button` in an `HStack` at the bottom, disabled while streaming
- **Unavailable state:** if `#available(iOS 26, *)` is false, show a message: "Chat requires iOS 26 or later"

---

## Error Handling

- If `LanguageModelSession` throws on init → show "Chat unavailable on this device"
- If `sendMessage` throws mid-stream → append "Sorry, something went wrong." to the assistant message, set `isStreaming: false`

---

## Out of Scope

- Chat history persistence
- Multiple conversations
- Model selection
- Friends' real Supabase data (uses MockData for now — real data comes in DB layer spec)
