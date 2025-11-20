import NetworkImage
//
//  ListRowItem.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//
import SwiftUI

struct ProductSearchProductItem: View {
    let product: Product

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

                if product.nutriScore != nil {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(product.ratingColor)
                            .frame(width: 12, height: 12)

                        Text("\(product.nutriScore ?? 0)")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }

            }
            .frame(height: 110, alignment: .top)
        }
        .padding(.vertical, 8)
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
    }
}

#Preview {
    NavigationStack {
        Spacer()
        List {
            NavigationLink(destination: Text("Hello")) {
                ProductSearchProductItem(product: Product.sampleProducts[1])
            }
            .listRowInsets(
                EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            )
            NavigationLink(destination: Text("Hello")) {
                ProductSearchProductItem(product: Product.sampleProducts[2])
            }
            .listRowInsets(
                EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            )
        }
        .listStyle(.plain)
        .frame(maxHeight: 400)
        Spacer()
    }
}

// MARK: Placeholder

struct ProductSearchItemPlaceholder: View {
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
        ProductSearchItemPlaceholder()
            .listRowInsets(
                EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            )
        ProductSearchItemPlaceholder()
            .listRowInsets(
                EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            )
        ProductSearchItemPlaceholder()
            .listRowInsets(
                EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            )
    }
    .listStyle(.plain)
}

