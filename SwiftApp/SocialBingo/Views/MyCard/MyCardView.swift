import SwiftUI

struct MyCardView: View {
    @EnvironmentObject var storage: AppStorage
    @State private var showProfile = false
    @State private var sheetMode: ItemSheetMode? = nil

    private var plusOneCounts: [Int: Int] {
        getPlusOneCounts(for: storage.bingoItems)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header card
                    HStack(spacing: 12) {
                        Text(storage.currentUser.avatarEmoji)
                            .font(.system(size: 36))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(storage.currentUser.username)
                                .font(.title3.bold())
                            if !storage.currentUser.bio.isEmpty {
                                Text(storage.currentUser.bio)
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

                    // Bingo grid
                    BingoGridView(
                        items: storage.bingoItems,
                        plusOneCounts: plusOneCounts,
                        onCellTap: { position, item in
                            if let item {
                                sheetMode = .edit(item: item)
                            } else {
                                sheetMode = .create(position: position)
                            }
                        }
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.appBackground)
            .navigationTitle("My Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.system(size: 20))
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(item: sheetModeBinding) { mode in
                ItemSheetView(mode: mode.mode)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    // Adapt Optional<ItemSheetMode> to sheet(item:) — requires Identifiable
    private var sheetModeBinding: Binding<IdentifiableSheetMode?> {
        Binding(
            get: { sheetMode.map { IdentifiableSheetMode(mode: $0) } },
            set: { sheetMode = $0?.mode }
        )
    }
}

/// Thin Identifiable wrapper so ItemSheetMode can drive sheet(item:)
struct IdentifiableSheetMode: Identifiable {
    let id = UUID()
    let mode: ItemSheetMode
}
