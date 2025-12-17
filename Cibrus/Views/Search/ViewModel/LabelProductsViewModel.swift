//
//  LabelProductsViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 17.11.25.
//

import Combine
import NetworkImage
import SwiftUI
import Models
import GraphQl

struct ProductLabel: Identifiable, Hashable {
    let id: Int
    let name: String
    let filter: CategoryFilter
}

@MainActor
class LabelProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasNextPage = false

    let filterManager = FilterManager.shared

    var activeFilters: Set<ProductFilter> {
        filterManager.activeFilters
    }

    private var endCursor: String?
    private var currentFilter: CategoryFilter?
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Observe filter changes and refetch products
        filterManager.$activeFilters
            .dropFirst() // Skip initial value
            .sink { [weak self] _ in
                guard let self = self, let filter = self.currentFilter else { return }
                Task {
                    await self.fetchProducts(for: filter)
                }
            }
            .store(in: &cancellables)
    }

    func fetchProducts(for filter: CategoryFilter) async {
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

    func loadMore() async {
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

    // MARK: - Filter Management

    func toggleFilter(_ filter: ProductFilter) {
        filterManager.toggleFilter(filter)
    }

    func clearFilters() {
        filterManager.clearFilters()
    }
}
