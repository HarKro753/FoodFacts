//
//  ListRowItemPlaceholder.swift
//  FoodFacts
//
//  Skeleton loading placeholder for list items
//

import SwiftUI

struct ProductListItemPlaceholder: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Placeholder for product image
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 100, height: 100)
                .shimmer()

            VStack(alignment: .leading, spacing: 4) {
                // Product name placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)
                    .shimmer()

                // Brand placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 15)
                    .frame(maxWidth: 120)
                    .shimmer()

                Spacer()

                // Rating placeholder
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 12, height: 12)
                        .shimmer()

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 30, height: 14)
                        .shimmer()
                }

                // Time placeholder
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 12, height: 12)
                        .shimmer()

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 13)
                        .shimmer()
                }
            }
            .frame(height: 100, alignment: .top)
        }
        .padding(.vertical, 8)
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
    }
}

// Shimmer effect modifier
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        Color.white.opacity(0.3),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 300
                }
            }
    }
}

#Preview {
    List {
        ProductListItemPlaceholder()
            .listRowInsets(
                EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            )
        ProductListItemPlaceholder()
            .listRowInsets(
                EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            )
        ProductListItemPlaceholder()
            .listRowInsets(
                EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            )
    }
    .listStyle(.plain)
}
