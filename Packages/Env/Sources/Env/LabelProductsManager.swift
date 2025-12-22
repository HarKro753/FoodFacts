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
    public var isLoading = false
    public var isLoadingMore = false
    public var errorMessage: String?
    public var hasNextPage = false
    public var endCursor: String?

    public let networkMonitor = NetworkMonitor.shared
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
            products = result.products
            updatePagination(
                hasNextPage: result.pageInfo.hasNextPage,
                endCursor: result.pageInfo.endCursor
            )
        } else {
            products = []
        }
    }

    public func loadMore() async {
        guard !isLoadingMore,
            hasNextPage,
            let cursor = endCursor,
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
            products.append(contentsOf: result.products)
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
