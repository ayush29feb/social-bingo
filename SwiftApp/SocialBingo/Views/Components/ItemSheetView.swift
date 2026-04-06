import SwiftUI

enum ItemSheetMode {
    case create(position: Int)
    case edit(item: BingoItem)
    case view(item: BingoItem, onPlusOne: () -> Void, isPlusOned: Bool)
}

struct ItemSheetView: View {
    let mode: ItemSheetMode
    @EnvironmentObject var storage: AppStorage
    @Environment(\.dismiss) private var dismiss

    @State private var emoji: String = ""
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var url: String = ""

    private var isViewMode: Bool {
        if case .view = mode { return true }
        return false
    }

    private var navigationTitle: String {
        switch mode {
        case .create:        return "New Item"
        case .edit:          return "Edit Item"
        case .view(let i, _, _): return i.title
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                if isViewMode {
                    viewModeContent
                } else {
                    editModeContent
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if !isViewMode {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", action: save)
                            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
        .onAppear { prefill() }
    }

    // MARK: - View-mode content (friend's item)

    @ViewBuilder
    private var viewModeContent: some View {
        if case .view(let item, let onPlusOne, let isPlusOned) = mode {
            Section {
                HStack(spacing: 12) {
                    Text(item.emoji).font(.system(size: 40))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title).font(.headline)
                        if !item.description.isEmpty {
                            Text(item.description)
                                .font(.subheadline)
                                .foregroundColor(.appMuted)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            if !item.url.isEmpty, let destination = URL(string: item.url) {
                Section("Link") {
                    Link(item.url, destination: destination)
                        .font(.subheadline)
                }
            }

            Section {
                Button(action: {
                    onPlusOne()
                    dismiss()
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: isPlusOned ? "hand.thumbsup.fill" : "hand.thumbsup")
                        Text(isPlusOned ? "You're in!" : "+1 — I want this too")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .foregroundColor(isPlusOned ? .appPlusOne : .appPrimary)
            }
        }
    }

    // MARK: - Edit/create mode content (own item)

    @ViewBuilder
    private var editModeContent: some View {
        Section("Icon") {
            TextField("Emoji", text: $emoji)
                .font(.system(size: 32))
                .multilineTextAlignment(.center)
        }

        Section("Details") {
            TextField("Title (required)", text: $title)
            TextField("Description (optional)", text: $description, axis: .vertical)
                .lineLimit(3...5)
            TextField("URL (optional)", text: $url)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }

        if case .edit(let item) = mode {
            Section {
                Button(role: .destructive) {
                    storage.deleteBingoItem(id: item.id)
                    dismiss()
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete Item")
                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func prefill() {
        switch mode {
        case .create:
            break  // state fields already default to ""
        case .edit(let item):
            emoji = item.emoji
            title = item.title
            description = item.description
            url = item.url
        case .view:
            break
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        let resolvedEmoji = emoji.trimmingCharacters(in: .whitespaces).isEmpty ? "⭐️" : emoji

        switch mode {
        case .create(let position):
            let item = storage.makeItem(
                position: position,
                emoji: resolvedEmoji,
                title: trimmedTitle,
                description: description,
                url: url
            )
            storage.saveBingoItem(item)
        case .edit(var item):
            item.emoji = resolvedEmoji
            item.title = trimmedTitle
            item.description = description
            item.url = url
            storage.saveBingoItem(item)
        case .view:
            break
        }
        dismiss()
    }
}

/// Thin Identifiable wrapper so ItemSheetMode can drive sheet(item:)
struct IdentifiableSheetMode: Identifiable {
    let id = UUID()
    let mode: ItemSheetMode
}
