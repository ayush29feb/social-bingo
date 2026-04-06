import SwiftUI

struct FriendCardView: View {
    let user: User
    @EnvironmentObject var storage: AppStorage

    /// Session-only plus-one state (not persisted in prototype)
    @State private var plusOnedItemIds: Set<String> = []
    @State private var sheetItem: IdentifiableSheetMode? = nil

    private var friendItems: [BingoItem] { getFriendItems(for: user.id) }

    /// Count badge for a given grid position (session plus-ones only for now)
    private func plusOneCountFor(position: Int) -> Int {
        guard let item = friendItems.first(where: { $0.position == position }) else { return 0 }
        return plusOnedItemIds.contains(item.id) ? 1 : 0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                HStack(spacing: 12) {
                    Text(user.avatarEmoji)
                        .font(.system(size: 36))
                        .frame(width: 52, height: 52)
                        .background(Color.appPrimaryLight)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.username)
                            .font(.title3.bold())
                        if !user.bio.isEmpty {
                            Text(user.bio)
                                .font(.subheadline)
                                .foregroundColor(.appMuted)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                .padding(.horizontal)

                // Read-only grid
                BingoGridView(
                    items: friendItems,
                    plusOneCounts: Dictionary(
                        uniqueKeysWithValues: (0..<25).compactMap { pos -> (Int, Int)? in
                            let count = plusOneCountFor(position: pos)
                            return count > 0 ? (pos, count) : nil
                        }
                    ),
                    onCellTap: { _, item in
                        guard let item else { return }
                        let alreadyPlusOned = plusOnedItemIds.contains(item.id)
                        sheetItem = IdentifiableSheetMode(
                            mode: .view(
                                item: item,
                                onPlusOne: {
                                    // Capture alreadyPlusOned before state change to avoid stale closure
                                    if alreadyPlusOned {
                                        plusOnedItemIds.remove(item.id)
                                    } else {
                                        plusOnedItemIds.insert(item.id)
                                    }
                                },
                                isPlusOned: alreadyPlusOned
                            )
                        )
                    }
                )
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.appBackground)
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $sheetItem) { item in
            ItemSheetView(mode: item.mode)
                .presentationDetents([.medium, .large])
        }
    }
}
