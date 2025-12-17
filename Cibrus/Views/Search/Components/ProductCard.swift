//
//  LabelProductCard.swift
//  FoodFacts
//
//  Created by Harro Krog on 17.11.25.
//


import SwiftUI
import NetworkImage
import Combine
import Models

struct ProductCard: View {
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
            .frame(width: 120, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name ?? "Unknown")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

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
            .frame(width: 120, alignment: .leading)
        }
        .frame(width: 120)
    }
}

// MARK: - Placeholder

struct LabelProductCardPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 120, height: 140)
                .shimmer()

            // Product Info placeholder
            VStack(alignment: .leading, spacing: 4) {
                // Product name placeholder (2 lines)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 14)
                    .shimmer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 14)
                    .shimmer()

                // Brand placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 70, height: 12)
                    .padding(.top, 2)
                    .shimmer()

                // Rating placeholder
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 8, height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 12)
                }
                .padding(.top, 2)
                .shimmer()
            }
            .frame(width: 120, alignment: .leading)
        }
        .frame(width: 120)
    }
}

// MARK: - Shimmer Effect

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
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
