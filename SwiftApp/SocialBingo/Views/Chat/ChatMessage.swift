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
