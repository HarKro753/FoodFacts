//
//  AlternativesView.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import SwiftUI
import NetworkImage

struct AlternativesView: View {
    @EnvironmentObject private var viewModel: AlternativesViewModel
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.isInitialLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading alternatives...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else if let errorMessage = viewModel.errorMessage,
                    viewModel.comparisons.isEmpty
                {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(.orange)

                        Text("Error loading alternatives")
                            .font(.headline)

                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Try Again") {
                            Task {
                                await viewModel.fetchAlternatives()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else if viewModel.comparisons.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        Text("No alternatives yet")
                            .font(.headline)

                        Text("Scan some products to see healthier alternatives")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(
                            Array(viewModel.comparisons.enumerated()),
                            id: \.element.id
                        ) { index, comparison in
                            if let alternative = comparison.alternativeProduct {
                                HStack(spacing: 0) {
                                    // Original Product (with X badge) - No chevron
                                    Button {
                                        navigationPath.append(comparison.originalProduct)
                                    } label: {
                                        ProductCard(
                                            product: comparison.originalProduct,
                                            badgeIcon: "xmark",
                                            badgeColor: .red
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .frame(maxWidth: .infinity)

                                    // Divider
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 1)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)

                                    // Alternative Product (with checkmark badge) - With chevron
                                    Button {
                                        navigationPath.append(alternative)
                                    } label: {
                                        HStack {
                                            ProductCard(
                                                product: alternative,
                                                badgeIcon: "checkmark",
                                                badgeColor: .green
                                            )

                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundStyle(.gray)
                                                .padding(.trailing, 8)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.vertical, 12)
                                .alignmentGuide(.listRowSeparatorLeading) { _ in
                                    0
                                }
                                .listRowInsets(
                                    EdgeInsets(
                                        top: 8,
                                        leading: 16,
                                        bottom: 8,
                                        trailing: 16
                                    )
                                )
                                .listRowBackground(Color.clear)
                                .onAppear {
                                    // Load more when reaching the 5th item from the end
                                    if index == viewModel.comparisons.count - 5 {
                                        Task {
                                            await viewModel.loadMore()
                                        }
                                    }
                                }
                            }
                        }

                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Alternativen")
            .navigationDestination(for: Product.self) { product in
                ProductDetail(product: product)
            }
            .task {
                await viewModel.fetchAlternatives()
            }
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
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

#Preview {
    AlternativesView()
        .environmentObject(AlternativesViewModel())
}
