//
//  ListRankItem.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//


import SwiftUI
import NetworkImage
import Models

struct ListRankItem: View {
    let rank: Int
    let product: Product

    var ratingColor: Color {
        guard let score = product.nutriScore else { return .gray }
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }

    var ratingText: String {
        guard let score = product.nutriScore else { return "N/A" }
        switch score {
        case 80...100: return "Gut"
        case 60..<80: return "Mittel"
        default: return "Schlecht"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Product Image
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
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.gray.opacity(0.1))
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 80, height: 120)
            .clipped()

            // Rank Number
            Text("\(rank)")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)

            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name ?? "Unknown Product")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(product.brand ?? "Unknown Brand")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                // Rating
                if let score = product.nutriScore {
                    HStack(alignment: .center, spacing: 8) {
                        Circle()
                            .fill(ratingColor)
                            .frame(width: 12, height: 12)

                        VStack(spacing: 2) {
                            Text("\(score)/100")
                                .font(.system(size: 15))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            Text(ratingText)
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
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

// MARK: - Placeholder

struct ListRankItemPlaceholder: View {
    let rank: Int

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Placeholder Image
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 120)
                .shimmering()

            // Placeholder Rank Number
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 24, height: 20)
                .shimmering()

            // Placeholder Product Info
            VStack(alignment: .leading, spacing: 4) {
                // Product name placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .shimmering()

                // Brand name placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 15)
                    .shimmering()

                Spacer()

                // Rating placeholder
                HStack(alignment: .center, spacing: 8) {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 12, height: 12)
                        .shimmering()

                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 15)
                            .shimmering()

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 50, height: 15)
                            .shimmering()
                    }
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

extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}
