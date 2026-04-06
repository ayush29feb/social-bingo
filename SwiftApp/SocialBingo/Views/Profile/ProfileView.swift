import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var storage: AppStorage
    @Environment(\.dismiss) private var dismiss

    @State private var avatarEmoji: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Avatar") {
                    TextField("Emoji", text: $avatarEmoji)
                        .font(.system(size: 40))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                Section("Profile") {
                    TextField("Username", text: $username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Bio (optional)", text: $bio, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            avatarEmoji = storage.currentUser.avatarEmoji
            username    = storage.currentUser.username
            bio         = storage.currentUser.bio
        }
    }

    private func save() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        guard !trimmedUsername.isEmpty else { return }
        let resolvedEmoji = avatarEmoji.trimmingCharacters(in: .whitespaces).isEmpty
            ? "🎯"
            : avatarEmoji

        storage.currentUser.avatarEmoji = resolvedEmoji
        storage.currentUser.username    = trimmedUsername
        storage.currentUser.bio         = bio
        storage.saveUser()
        dismiss()
    }
}
