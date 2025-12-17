//
//  AlternativesView.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import SwiftUI
import NetworkImage
import Models

struct AlternativesView: View {
    @EnvironmentObject private var viewModel: AlternativesViewModel
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            contentView
                .navigationTitle("Alternativen")
                .navigationDestination(for: Product.self) { product in
                    ProductDetail(product: product)
                }
                .navigationDestination(for: ProductComparison.self) { comparison in
                    AlternativeProductsList(
                        originalProduct: comparison.originalProduct,
                        alternatives: comparison.alternativeProducts
                    )
                }
                .task {
                    await viewModel.fetchAlternatives()
                }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isInitialLoading {
            loadingView
        } else if let errorMessage = viewModel.errorMessage, viewModel.comparisons.isEmpty {
            errorView(message: errorMessage)
        } else if viewModel.comparisons.isEmpty {
            emptyStateView
        } else {
            comparisonsList
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading alternatives...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Error loading alternatives")
                .font(.headline)

            Text(message)
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
    }
    
    private var emptyStateView: some View {
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
    }
    
    private var comparisonsList: some View {
        List {
            ForEach(
                Array(viewModel.comparisons.enumerated()),
                id: \.element.id
            ) { index, comparison in
                comparisonRow(comparison: comparison, index: index)
            }

            if viewModel.isLoadingMore {
                loadingMoreView
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    @ViewBuilder
    private func comparisonRow(comparison: ProductComparison, index: Int) -> some View {
        if !comparison.alternativeProducts.isEmpty,
           let topAlternative = comparison.alternativeProducts.first {
            HStack(spacing: 0) {
                originalProductButton(comparison: comparison)
                divider
                alternativeProductButton(comparison: comparison, topAlternative: topAlternative)
            }
            .padding(.vertical, 12)
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            .listRowInsets(
                EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            )
            .listRowBackground(Color.clear)
            .onAppear {
                loadMoreIfNeeded(index: index)
            }
        }
    }
    
    private func originalProductButton(comparison: ProductComparison) -> some View {
        Button {
            navigationPath.append(comparison.originalProduct)
        } label: {
            ProductComparisonCard(
                product: comparison.originalProduct,
                badgeIcon: "xmark",
                badgeColor: .red
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 1)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
    }
    
    private func alternativeProductButton(comparison: ProductComparison, topAlternative: Product) -> some View {
        Button {
            navigationPath.append(comparison)
        } label: {
            HStack {
                ProductComparisonCard(
                    product: topAlternative,
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
    
    private var loadingMoreView: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding()
            Spacer()
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
    
    private func loadMoreIfNeeded(index: Int) {
        // Load more when reaching the 5th item from the end
        if index == viewModel.comparisons.count - 5 {
            Task {
                await viewModel.loadMore()
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

#Preview {
    AlternativesView()
        .environmentObject(AlternativesViewModel())
}
