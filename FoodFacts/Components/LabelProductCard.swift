//
//  LabelProductCard.swift
//  FoodFacts
//
//  Created by Harro Krog on 17.11.25.
//


import SwiftUI
import NetworkImage
import Combine

struct LabelProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))

                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name ?? "Unknown")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .frame(height: 36, alignment: .top)

                Text(product.brand ?? "Unknown Brand")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // Rating
                if product.nutriScore != nil {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(product.ratingColor)
                            .frame(width: 8, height: 8)

                        Text("\(product.nutriScore!)/100")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 2)
                }
            }
            .frame(width: 120)
        }
        .frame(width: 120)
    }
}
