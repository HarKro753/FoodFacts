import NetworkImage
//
//  ProductComparisonItem.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//
import SwiftUI

struct ProductComparisonItem: View {
    let originalProduct: Product
    let alternativeProduct: Product

    var body: some View {
        HStack(spacing: 12) {
            // Original Product (with X badge)
            ProductCard(
                product: originalProduct,
                badgeIcon: "xmark",
                badgeColor: .red
            )

            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 8)

            // Alternative Product (with checkmark badge)
            ProductCard(
                product: alternativeProduct,
                badgeIcon: "checkmark",
                badgeColor: .green
            )
        }
        .padding(.vertical, 12)
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
    }
}

// MARK: - Product Card Component

private struct ProductCard: View {
    let product: Product
    let badgeIcon: String
    let badgeColor: Color

    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            // Product Image with Badge
            ZStack(alignment: .topLeading) {
                Group {
                    if let imageUrl = product.imageUrl,
                        let url = URL(string: imageUrl)
                    {
                        NetworkImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(width: 80, height: 80)
                .padding(.bottom, 8)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Badge
                ZStack {
                    Circle()
                        .fill(badgeColor)
                        .frame(width: 24, height: 24)

                    Image(systemName: badgeIcon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: -32, y: 0)
            }

            // Product Name
            Text(product.name ?? "Unknown")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // Product Brand
            Text(product.brand ?? "Unknown Brand")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            // NutriScore with colored circle
            HStack(spacing: 4) {
                Circle()
                    .fill(product.ratingColor)
                    .frame(width: 10, height: 10)

                Text("\(product.nutriScore ?? 0)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    List {
        ProductComparisonItem(
            originalProduct: Product.sampleProducts[2],
            alternativeProduct: Product.sampleProducts[0]
        )
        .listRowInsets(
            EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        )

        ProductComparisonItem(
            originalProduct: Product.sampleProducts[1],
            alternativeProduct: Product.sampleProducts[0]
        )
        .listRowInsets(
            EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        )
    }
    .listStyle(.plain)
}
