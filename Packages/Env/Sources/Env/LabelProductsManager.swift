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
public class LabelProductsManager {
    public var products: [Product] = []
    public var isLoading = false
    public var isLoadingMore = false
    public var errorMessage: String?
    public var hasNextPage = false

    public let filterManager = FilterManager.shared

    public var activeFilters: Set<ProductFilter> {
        filterManager.activeFilters
    }

    private var endCursor: String?
    private var currentFilter: CategoryFilter?
    private var cancellables = Set<AnyCancellable>()

    public init() {
        filterManager.$activeFilters
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self, let filter = self.currentFilter else { return }
                Task {
                    await self.fetchProducts(for: filter)
                }
            }
            .store(in: &cancellables)
    }

    public func fetchProducts(for filter: CategoryFilter) async {
        guard !isLoading else { return }

        currentFilter = filter
        isLoading = true
        errorMessage = nil
        endCursor = nil
        hasNextPage = false

        do {
            let filterParams = filterManager.buildFilterParameters()

            let result = try await filter.fetchProducts(
                first: 20,
                labelIds: filterParams.labelIds,
                nutrientConditions: filterParams.nutrientConditions,
                sortAscending: filterParams.sortAscending
            )

            products = result.products
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            products = []
        }

        isLoading = false
    }

    public func loadMore() async {
        guard !isLoadingMore,
            hasNextPage,
            let cursor = endCursor,
            let filter = currentFilter
        else { return }

        isLoadingMore = true
        errorMessage = nil

        do {
            let filterParams = filterManager.buildFilterParameters()

            let result = try await filter.fetchProducts(
                first: 20,
                after: cursor,
                labelIds: filterParams.labelIds,
                nutrientConditions: filterParams.nutrientConditions,
                sortAscending: filterParams.sortAscending
            )

            products.append(contentsOf: result.products)
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    public func toggleFilter(_ filter: ProductFilter) {
        filterManager.toggleFilter(filter)
    }

    public func clearFilters() {
        filterManager.clearFilters()
    }
}
