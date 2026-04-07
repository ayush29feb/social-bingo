import Foundation
import SwiftUI
import FoundationModels

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
        guard !text.isEmpty, !isStreaming, let session else { return }

        inputText = ""
        messages.append(ChatMessage(role: .user, content: text))

        messages.append(ChatMessage(role: .assistant, content: "", isStreaming: true))
        let assistantIndex = messages.count - 1
        isStreaming = true

        do {
            let stream = session.streamResponse(to: text)
            for try await partialText in stream {
                // Foundation Models stream yields cumulative text, not deltas — assignment is correct
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
