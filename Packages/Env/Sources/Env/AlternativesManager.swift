//
//  AlternativesManager.swift
//  Env
//
//  Created by Harro Krog on 11.11.25.
//

import Combine
import Foundation
import SwiftUI
import Models
import GraphQl

public struct ProductComparison: Identifiable, Hashable {
    public let id = UUID()
    public let historyId: Int
    public let originalProduct: Product
    public let alternativeProducts: [Product]
    public let scannedAt: String

    public init(historyId: Int, originalProduct: Product, alternativeProducts: [Product], scannedAt: String) {
        self.historyId = historyId
        self.originalProduct = originalProduct
        self.alternativeProducts = alternativeProducts
        self.scannedAt = scannedAt
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ProductComparison, rhs: ProductComparison) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
@Observable
public class AlternativesManager: NetworkAwareFetching, PaginatedFetching {
    public var comparisons: [ProductComparison] = []
    public var isInitialLoading = false
    private var isLoadingMore = false
    private var errorMessage: String?
    private var hasNextPage = false
    private var endCursor: String?
    private var isLoading: Bool = false

    private var hasLoadedInitially = false

    // MARK: - Protocol Conformance (ProductFetchingState)

    public func getErrorMessage() -> String? {
        return errorMessage
    }

    public func setErrorMessage(_ message: String?) {
        errorMessage = message
    }

    public func getIsLoading() -> Bool {
        return isLoading
    }

    public func setIsLoading(_ loading: Bool) {
        isLoading = loading
    }

    // MARK: - Protocol Conformance (PaginatedFetching)

    public func getHasNextPage() -> Bool {
        return hasNextPage
    }

    public func setHasNextPage(_ nextPage: Bool) {
        hasNextPage = nextPage
    }

    public func getEndCursor() -> String? {
        return endCursor
    }

    public func setEndCursor(_ cursor: String?) {
        endCursor = cursor
    }

    public func getIsLoadingMore() -> Bool {
        return isLoadingMore
    }

    public func setIsLoadingMore(_ loading: Bool) {
        isLoadingMore = loading
    }

    public init() {}

    public func fetchAlternatives() async {
        guard !hasLoadedInitially else { return }

        isInitialLoading = true

        let historyResult = await fetchWithNetworkCheck {
            try await GraphQLClient.shared.fetchProductHistory(first: 20)
        }

        if let historyResult = historyResult {
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
            updatePagination(
                hasNextPage: historyResult.pageInfo.hasNextPage,
                endCursor: historyResult.pageInfo.endCursor
            )
        } else {
            comparisons = []
            resetPagination()
        }

        hasLoadedInitially = true
        isInitialLoading = false
    }

    public func loadMore() async {
        guard !getIsLoadingMore(), getHasNextPage(), let cursor = getEndCursor() else {
            return
        }

        startLoadingMore()

        let historyResult = await fetchWithNetworkCheck {
            try await GraphQLClient.shared.fetchProductHistory(
                first: 20,
                after: cursor
            )
        }

        if let historyResult = historyResult {
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
            updatePagination(
                hasNextPage: historyResult.pageInfo.hasNextPage,
                endCursor: historyResult.pageInfo.endCursor
            )
        }

        stopLoadingMore()
    }

    public func refresh() async {
        clearError()

        let historyResult = await fetchWithNetworkCheck {
            try await GraphQLClient.shared.fetchProductHistory(first: 20)
        }

        if let historyResult = historyResult {
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
            updatePagination(
                hasNextPage: historyResult.pageInfo.hasNextPage,
                endCursor: historyResult.pageInfo.endCursor
            )
        }
    }
}
