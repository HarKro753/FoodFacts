//
//  AlternativesViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Product Comparison Model

struct ProductComparison: Identifiable, Hashable {
    let id = UUID()
    let historyId: Int
    let originalProduct: Product
    let alternativeProducts: [Product]
    let scannedAt: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ProductComparison, rhs: ProductComparison) -> Bool {
        lhs.id == rhs.id
    }
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
            let historyResult = try await GraphQLClient.shared
                .fetchProductHistory(first: 20)

            var newComparisons: [ProductComparison] = []

            for historyItem in historyResult.historyItems {
                guard let original = historyItem.product else { continue }

                var alternatives: [Product] = []
                do {
                    let alternativeResult = try await GraphQLClient.shared
                        .fetchProducts(
                            first: 10,
                            productCodeForAlternatives: historyItem.productCode
                        )
                    alternatives = alternativeResult.products
                } catch {
                    print(
                        "Failed to fetch alternative for \(historyItem.productCode): \(error)"
                    )
                }

                let comparison = ProductComparison(
                    historyId: historyItem.id,
                    originalProduct: original,
                    alternativeProducts: alternatives,
                    scannedAt: historyItem.scannedAt
                )
                newComparisons.append(comparison)
            }

            comparisons = newComparisons
            hasNextPage = historyResult.pageInfo.hasNextPage
            endCursor = historyResult.pageInfo.endCursor
            hasLoadedInitially = true
            errorMessage = nil
        } catch {
            if error is CancellationError {
                return
            }
            errorMessage = error.localizedDescription
            comparisons = []
            hasNextPage = false
            endCursor = nil
            hasLoadedInitially = true
        }

        isInitialLoading = false
    }

    func loadMore() async {
        guard !isLoadingMore, hasNextPage, let cursor = endCursor else {
            return
        }

        isLoadingMore = true

        do {
            let historyResult = try await GraphQLClient.shared
                .fetchProductHistory(
                    first: 20,
                    after: cursor
                )

            var newComparisons: [ProductComparison] = []

            for historyItem in historyResult.historyItems {
                guard let original = historyItem.product else { continue }

                var alternatives: [Product] = []
                do {
                    let alternativeResult = try await GraphQLClient.shared
                        .fetchProducts(
                            first: 10,
                            countryId: 2,
                            productCodeForAlternatives: historyItem.productCode
                        )
                    alternatives = alternativeResult.products
                } catch {
                    print(
                        "Failed to fetch alternative for \(historyItem.productCode): \(error)"
                    )
                }

                let comparison = ProductComparison(
                    historyId: historyItem.id,
                    originalProduct: original,
                    alternativeProducts: alternatives,
                    scannedAt: historyItem.scannedAt
                )
                newComparisons.append(comparison)
            }

            comparisons.append(contentsOf: newComparisons)
            hasNextPage = historyResult.pageInfo.hasNextPage
            endCursor = historyResult.pageInfo.endCursor
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    func refresh() async {
        errorMessage = nil

        do {
            let historyResult = try await GraphQLClient.shared
                .fetchProductHistory(first: 20)

            var newComparisons: [ProductComparison] = []

            for historyItem in historyResult.historyItems {
                guard let original = historyItem.product else { continue }

                var alternatives: [Product] = []
                do {
                    let alternativeResult = try await GraphQLClient.shared
                        .fetchProducts(
                            first: 10,
                            productCodeForAlternatives: historyItem.productCode
                        )
                    alternatives = alternativeResult.products
                } catch {
                    print(
                        "Failed to fetch alternative for \(historyItem.productCode): \(error)"
                    )
                }

                let comparison = ProductComparison(
                    historyId: historyItem.id,
                    originalProduct: original,
                    alternativeProducts: alternatives,
                    scannedAt: historyItem.scannedAt
                )
                newComparisons.append(comparison)
            }

            comparisons = newComparisons
            hasNextPage = historyResult.pageInfo.hasNextPage
            endCursor = historyResult.pageInfo.endCursor
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
