//
//  AlternativesViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Product Comparison Model

struct ProductComparison: Identifiable {
    let id = UUID()
    let historyId: Int
    let originalProduct: Product
    let alternativeProduct: Product?
    let scannedAt: String
}

// MARK: - Alternatives ViewModel

@MainActor
class AlternativesViewModel: ObservableObject {
    @Published var comparisons: [ProductComparison] = []
    @Published var isInitialLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasNextPage = false

    private var endCursor: String?
    private var hasLoadedInitially = false

    func fetchAlternatives() async {
        guard !hasLoadedInitially else { return }

        isInitialLoading = true
        errorMessage = nil

        do {
            // Fetch history items
            let historyResult = try await GraphQLClient.shared.fetchProductHistory(first: 20)

            // For each history item, fetch the original product and its first alternative
            var newComparisons: [ProductComparison] = []

            for historyItem in historyResult.historyItems {
                // Fetch original product
                let originalResult = try await GraphQLClient.shared.fetchProducts(
                    first: 1,
                    searchQuery: nil,
                    productCodeForAlternatives: nil
                )

                // Find the original product by code
                let originalProduct = originalResult.products.first { $0.id == historyItem.productCode }

                guard let original = originalProduct else { continue }

                // Fetch alternative product
                let alternativeResult = try await GraphQLClient.shared.fetchProducts(
                    first: 1,
                    productCodeForAlternatives: historyItem.productCode
                )

                let alternative = alternativeResult.products.first

                // Only add if we have an alternative
                if let alternative = alternative {
                    let comparison = ProductComparison(
                        historyId: historyItem.id,
                        originalProduct: original,
                        alternativeProduct: alternative,
                        scannedAt: historyItem.scannedAt
                    )
                    newComparisons.append(comparison)
                }
            }

            comparisons = newComparisons
            hasNextPage = historyResult.pageInfo.hasNextPage
            endCursor = historyResult.pageInfo.endCursor
            hasLoadedInitially = true
            // Clear error on successful fetch, even if no alternatives found
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            comparisons = []
            hasNextPage = false
            endCursor = nil
            hasLoadedInitially = true
        }

        isInitialLoading = false
    }

    func loadMore() async {
        guard !isLoadingMore, hasNextPage, let cursor = endCursor else { return }

        isLoadingMore = true

        do {
            // Fetch more history items
            let historyResult = try await GraphQLClient.shared.fetchProductHistory(
                first: 20,
                after: cursor
            )

            // For each new history item, fetch the original product and its first alternative
            var newComparisons: [ProductComparison] = []

            for historyItem in historyResult.historyItems {
                // Fetch original product
                let originalResult = try await GraphQLClient.shared.fetchProducts(
                    first: 1,
                    searchQuery: nil,
                    productCodeForAlternatives: nil
                )

                // Find the original product by code
                let originalProduct = originalResult.products.first { $0.id == historyItem.productCode }

                guard let original = originalProduct else { continue }

                // Fetch alternative product
                let alternativeResult = try await GraphQLClient.shared.fetchProducts(
                    first: 1,
                    productCodeForAlternatives: historyItem.productCode
                )

                let alternative = alternativeResult.products.first

                // Only add if we have an alternative
                if let alternative = alternative {
                    let comparison = ProductComparison(
                        historyId: historyItem.id,
                        originalProduct: original,
                        alternativeProduct: alternative,
                        scannedAt: historyItem.scannedAt
                    )
                    newComparisons.append(comparison)
                }
            }

            comparisons.append(contentsOf: newComparisons)
            hasNextPage = historyResult.pageInfo.hasNextPage
            endCursor = historyResult.pageInfo.endCursor
            // Clear error on successful fetch
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    func refresh() async {
        hasLoadedInitially = false
        endCursor = nil
        hasNextPage = false
        comparisons = []
        errorMessage = nil
        await fetchAlternatives()
    }
}
