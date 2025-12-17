//
//  ProductComparisonCard.swift
//  FoodFacts
//
//  Created by Harro Krog on 18.11.25.
//


import SwiftUI
import NetworkImage
import Models

struct ProductComparisonCard: View {
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
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.1))
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(width: 80, height: 120)
                .padding(.bottom, 8)
                .clipShape(RoundedRectangle(cornerRadius: 2))

                // Badge
                ZStack {
                    Circle()
                        .fill(badgeColor)
                        .frame(width: 24, height: 24)

                    Image(systemName: badgeIcon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: -26, y: 0)
            }

            // Product Name
            Text(product.name ?? "Unknown")
                .font(.system(size: 16))
                .foregroundStyle(.primary)
                .lineLimit(1)
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
                    .frame(width: 9, height: 9)

                Text(product.overallRatingText)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }
}
