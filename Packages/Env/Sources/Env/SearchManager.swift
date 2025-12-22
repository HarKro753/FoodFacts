//
//  SearchManager.swift
//  Env
//
//  Created by Harro Krog on 10.11.25.
//

import Combine
import Foundation
import SwiftUI
import Models
import GraphQl

public enum SearchState: Equatable {
    case idle
    case searching
    case searchResults
    case loadingMore
    case error(String)
}

@MainActor
@Observable
public class SearchManager: NetworkAwareFetching, PaginatedFetching {
    public var products: [Product] = []
    public var searchText = ""
    public var searchState: SearchState = .idle
    public var hasNextPage = false
    public var endCursor: String?
    public var isLoading: Bool = false
    public var isLoadingMore: Bool = false
    public var errorMessage: String?

    public let networkMonitor = NetworkMonitor.shared
    private var filterSync: FilterSyncService?

    public var filterStateId: String {
        filterSync?.filterStateId ?? ""
    }

    public var activeFilters: Set<ProductFilter> {
        filterSync?.activeFilters ?? []
    }

    public var categoryProducts: [Int: [Product]] = [:]
    public var loadingCategories: Set<Int> = []
    public var fetchedCategories: Set<Int> = []
    public var categories: [ProductCategoryData] = []
    public var completions: CompletionsData? = nil

    public var shouldShowCompletions: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
            && searchState != .searching && searchState != .searchResults
            && searchState != .loadingMore
    }

    private var searchTask: Task<Void, Never>?
    private var completionTask: Task<Void, Never>?

    public init() {
        categories = ProductCategoryData.categories.shuffled()

        filterSync = FilterSyncService { [weak self] in
            guard let self = self else { return }
            self.categoryProducts.removeAll()
            self.fetchedCategories.removeAll()
            self.loadingCategories.removeAll()
        }
    }

    // MARK: - Autocomplete

    public func fetchCompletions(for text: String) async {
        completionTask?.cancel()

        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            completions = nil
            return
        }

        completionTask = Task {
            do {
                let fetchedCompletions = try await GraphQLClient.shared
                    .fetchCompletions(prefix: text)

                guard !Task.isCancelled else { return }

                completions = fetchedCompletions
            } catch {
                guard !Task.isCancelled else { return }
                print(
                    "Error fetching completions: \(error.localizedDescription)"
                )
                completions = nil
            }
        }

        await completionTask?.value
    }

    public func clearCompletions() {
        completionTask?.cancel()
        completions = nil
        searchText = ""
    }

    // MARK: - Search

    public func loadMore() async {
        guard case .searchResults = searchState,
            hasNextPage,
            let cursor = endCursor,
            !searchText.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }

        searchState = .loadingMore

        let result = await fetchWithNetworkCheck {
            let (labelIds, nutrientConditions, sortAscending) = self.filterSync?.buildFilterParameters() ?? (nil, nil, nil)

            return try await GraphQLClient.shared.fetchProducts(
                after: cursor,
                labelIds: labelIds,
                sortAscending: sortAscending,
                searchQuery: self.searchText,
                nutrientConditions: nutrientConditions
            )
        }

        if let result = result {
            products.append(contentsOf: result.products)
            updatePagination(
                hasNextPage: result.pageInfo.hasNextPage,
                endCursor: result.pageInfo.endCursor
            )
            searchState = .searchResults
        } else {
            searchState = .error(errorMessage ?? "An error occurred")
        }
    }

    public func clearSearch() {
        searchText = ""
        products = []
        searchState = .idle
        hasNextPage = false
        endCursor = nil
    }

    public func resetToIdle() {
        searchTask?.cancel()
        completionTask?.cancel()
        searchText = ""
        products = []
        completions = nil
        searchState = .idle
        hasNextPage = false
        endCursor = nil
    }

    // MARK: - Filter Management

    public func toggleFilter(_ filter: ProductFilter) {
        FilterManager.shared.toggleFilter(filter)
    }

    public func clearFilters() {
        FilterManager.shared.clearFilters()
    }

    // MARK: - Category Products

    public func fetchProductsForCategory(_ category: ProductCategoryData) async {
        guard loadingCategories.insert(category.id).inserted else { return }

        defer {
            loadingCategories.remove(category.id)
        }

        guard !fetchedCategories.contains(category.id) else {
            return
        }

        guard networkMonitor.isConnected else {
            print("No network connection - skipping category \(category.name)")
            return
        }

        let result = await fetchWithNetworkCheck {
            let (labelIds, nutrientConditions, sortAscending) = self.filterSync?.buildFilterParameters() ?? (nil, nil, nil)

            return try await category.filter.fetchProducts(
                first: 10,
                labelIds: labelIds,
                nutrientConditions: nutrientConditions,
                sortAscending: sortAscending
            )
        }

        if let result = result {
            let validProducts = result.products.filter { product in
                product.name != nil && product.nutriScore != nil
            }

            let sortedProducts = validProducts.sorted {
                ($0.nutriScore ?? Int.min) > ($1.nutriScore ?? Int.min)
            }

            categoryProducts[category.id] = sortedProducts
            fetchedCategories.insert(category.id)

            if sortedProducts.isEmpty {
                print("No valid products found for category \(category.name)")
            } else {
                print(
                    "Successfully fetched \(sortedProducts.count) valid products for category \(category.name)"
                )
            }
        } else if networkMonitor.isConnected {
            categoryProducts[category.id] = []
            fetchedCategories.insert(category.id)
        }
    }

    public func isLoadingCategory(_ categoryId: Int) -> Bool {
        loadingCategories.contains(categoryId)
    }

    public func shouldShowCategory(_ categoryId: Int) -> Bool {
        if let products = categoryProducts[categoryId], !products.isEmpty {
            return true
        }

        if loadingCategories.contains(categoryId) {
            return true
        }

        if !fetchedCategories.contains(categoryId) {
            return true
        }

        return false
    }

}
