import SwiftUI
import Models

@available(iOS 18.0, *)
struct GoalSelectionContent: View {
    let headerTitle: String
    let items: [GoalItem]
    var isSingleSelection: Bool = false

    @State private var selectedItems: Set<GoalItem> = []

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(headerTitle)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 24)

            // Selection List
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(items, id: \.self) { item in
                        GoalRow(
                            item: item,
                            isSelected: selectedItems.contains(item)
                        ) {
                            handleSelection(for: item)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func handleSelection(for item: GoalItem) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if isSingleSelection {
            selectedItems = [item]
        } else {
            if selectedItems.contains(item) {
                selectedItems.remove(item)
            } else {
                selectedItems.insert(item)
            }
        }
    }
}

// MARK: - Goal Row
@available(iOS 18.0, *)
struct GoalRow: View {
    let item: GoalItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(item.title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.12 : 0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color.blue : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
