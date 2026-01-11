//
//  LabelProductsManager.swift
//  Env
//
//  Created by Harro Krog on 17.11.25.
//

import Combine
import Foundation
import SwiftUI
import Models
import GraphQl

public struct ProductLabel: Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let filter: CategoryFilter

    public init(id: Int, name: String, filter: CategoryFilter) {
        self.id = id
        self.name = name
        self.filter = filter
    }
}

@MainActor
@Observable
public class LabelProductsManager: NetworkAwareFetching, PaginatedFetching {
    public var products: [Product] = []
    private var isLoading = false
    private var isLoadingMore = false
    private var errorMessage: String?
    private var hasNextPage = false
    private var endCursor: String?

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
    private let filterManager = FilterManager.shared
    private var filterSync: FilterSyncService?

    public var activeFilters: Set<ProductFilter> {
        filterSync?.activeFilters ?? []
    }

    private var currentFilter: CategoryFilter?

    public init() {
        filterSync = FilterSyncService { [weak self] in
            guard let self = self, let filter = self.currentFilter else { return }
            await self.fetchProducts(for: filter)
        }
    }

    public func fetchProducts(for filter: CategoryFilter) async {
        guard !isLoading else { return }

        currentFilter = filter
        resetPagination()

        let result = await fetchWithNetworkCheck {
            let (labelIds, nutrientConditions, sortAscending) = self.filterSync?.buildFilterParameters() ?? (nil, nil, nil)

            return try await filter.fetchProducts(
                first: 20,
                labelIds: labelIds,
                nutrientConditions: nutrientConditions,
                sortAscending: sortAscending
            )
        }

        if let result = result {
            products = result.items
            updatePagination(
                hasNextPage: result.pageInfo.hasNextPage,
                endCursor: result.pageInfo.endCursor
            )
        } else {
            products = []
        }
    }

    public func loadMore() async {
        guard !getIsLoadingMore(),
            getHasNextPage(),
            let cursor = getEndCursor(),
            let filter = currentFilter
        else { return }

        startLoadingMore()

        let result = await fetchWithNetworkCheck {
            let (labelIds, nutrientConditions, sortAscending) = self.filterSync?.buildFilterParameters() ?? (nil, nil, nil)

            return try await filter.fetchProducts(
                first: 20,
                after: cursor,
                labelIds: labelIds,
                nutrientConditions: nutrientConditions,
                sortAscending: sortAscending
            )
        }

        if let result = result {
            products.append(contentsOf: result.items)
            updatePagination(
                hasNextPage: result.pageInfo.hasNextPage,
                endCursor: result.pageInfo.endCursor
            )
        }

        stopLoadingMore()
    }

    public func toggleFilter(_ filter: ProductFilter) {
        filterManager.toggleFilter(filter)
    }

    public func clearFilters() {
        filterManager.clearFilters()
    }
}


extension CategoryFilter {
    public func fetchProducts(
        first: Int = 20,
        after: String? = nil,
        labelIds: [Int]? = nil,
        nutrientConditions: [(String, Double?, Double?)]? = nil,
        sortAscending: Bool? = nil
    ) async throws -> PaginatedResult<Product> {
        switch self {
        case .label(let id):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelId: id,
                labelIds: labelIds,
                sortAscending: sortAscending,
                nutrientConditions: nutrientConditions
            )

        case .category(let id):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                categoryId: id,
                labelIds: labelIds,
                sortAscending: sortAscending,
                nutrientConditions: nutrientConditions
            )

        case .foodGroup(let id):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelIds: labelIds,
                foodGroup: id,
                sortAscending: sortAscending,
                nutrientConditions: nutrientConditions
            )

        case .nutrientMin(let fieldName, let minValue):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelIds: labelIds,
                sortAscending: sortAscending,
                nutrientFieldName: fieldName,
                nutrientMinValue: minValue,
                nutrientConditions: nutrientConditions
            )

        case .nutrientMax(let fieldName, let maxValue):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelIds: labelIds,
                sortAscending: sortAscending,
                nutrientFieldName: fieldName,
                nutrientMaxValue: maxValue,
                nutrientConditions: nutrientConditions
            )
        }
    }
}
