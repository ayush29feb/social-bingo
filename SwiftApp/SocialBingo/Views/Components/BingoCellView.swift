import SwiftUI

struct BingoCellView: View {
    let item: BingoItem?
    let plusOneCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(item != nil ? Color.white : Color.appPrimaryLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )

                if let item {
                    VStack(spacing: 2) {
                        Text(item.emoji)
                            .font(.system(size: 22))
                        Text(item.title)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.appText)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 2)
                    }
                    .padding(4)

                    if plusOneCount > 0 {
                        Text("+\(plusOneCount)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.appPlusOne)
                            .clipShape(Capsule())
                            .offset(x: 4, y: -4)
                    }
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .buttonStyle(.plain)
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    HStack {
        BingoCellView(
            item: BingoItem(id: "x", userId: "u", position: 0, emoji: "🗼",
                            title: "Visit Paris", description: "", url: "",
                            createdAt: "2024-01-01T00:00:00Z"),
            plusOneCount: 3,
            onTap: {}
        )
        .frame(width: 70, height: 70)

        BingoCellView(item: nil, plusOneCount: 0, onTap: {})
            .frame(width: 70, height: 70)
    }
    .padding()
}
