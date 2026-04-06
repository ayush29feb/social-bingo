import SwiftUI

struct BingoGridView: View {
    let items: [BingoItem]
    let plusOneCounts: [Int: Int]          // position → count
    let onCellTap: (Int, BingoItem?) -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 4),
        count: 5
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<25, id: \.self) { position in
                let item = items.first { $0.position == position }
                BingoCellView(
                    item: item,
                    plusOneCount: plusOneCounts[position] ?? 0,
                    onTap: { onCellTap(position, item) }
                )
            }
        }
        .padding(4)
        .background(Color.appBackground)
    }
}

#Preview {
    BingoGridView(
        items: Array(seedBingoItems.prefix(10)),
        plusOneCounts: [0: 2, 1: 1, 3: 3],
        onCellTap: { _, _ in }
    )
    .padding()
}
