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
    private var products: [Product] = []
    public var searchText = ""  // Must remain public var for @Bindable in SwiftUI
    private var searchState: SearchState = .idle
    private var hasNextPage = false
    private var endCursor: String?
    private var isLoading: Bool = false
    private var isLoadingMore: Bool = false
    private var errorMessage: String?

    // Public getter/setter methods for products
    public func getProducts() -> [Product] {
        return products
    }

    public func setProducts(_ products: [Product]) {
        self.products = products
    }

    // Public getter/setter methods for searchState
    public func getSearchState() -> SearchState {
        return searchState
    }

    public func setSearchState(_ state: SearchState) {
        self.searchState = state
    }

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

    private var filterSync: FilterSyncService?

    public func getFilterStateId() -> String {
        return filterSync?.filterStateId ?? ""
    }

    public func getActiveFilters() -> Set<ProductFilter> {
        return filterSync?.activeFilters ?? []
    }

    private var categoryProducts: [Int: [Product]] = [:]
    private var loadingCategories: Set<Int> = []
    private var fetchedCategories: Set<Int> = []
    private var categories: [ProductCategoryData] = []
    private var completions: CompletionsData? = nil

    // Public getter/setter methods for categoryProducts
    public func getCategoryProducts() -> [Int: [Product]] {
        return categoryProducts
    }

    public func setCategoryProducts(_ products: [Int: [Product]]) {
        self.categoryProducts = products
    }

    // Public getter/setter methods for loadingCategories
    public func getLoadingCategories() -> Set<Int> {
        return loadingCategories
    }

    public func setLoadingCategories(_ categories: Set<Int>) {
        self.loadingCategories = categories
    }

    // Public getter/setter methods for fetchedCategories
    public func getFetchedCategories() -> Set<Int> {
        return fetchedCategories
    }

    public func setFetchedCategories(_ categories: Set<Int>) {
        self.fetchedCategories = categories
    }

    // Public getter/setter methods for categories
    public func getCategories() -> [ProductCategoryData] {
        return categories
    }

    public func setCategories(_ categories: [ProductCategoryData]) {
        self.categories = categories
    }

    // Public getter/setter methods for completions
    public func getCompletions() -> CompletionsData? {
        return completions
    }

    public func setCompletions(_ completions: CompletionsData?) {
        self.completions = completions
    }

    public func getShouldShowCompletions() -> Bool {
        return !searchText.trimmingCharacters(in: .whitespaces).isEmpty
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
            getHasNextPage(),
            let cursor = getEndCursor(),
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
            products.append(contentsOf: result.items)
            updatePagination(
                hasNextPage: result.pageInfo.hasNextPage,
                endCursor: result.pageInfo.endCursor
            )
            searchState = .searchResults
        } else {
            searchState = .error(getErrorMessage() ?? "An error occurred")
        }
    }

    public func clearSearch() {
        searchText = ""
        products = []
        searchState = .idle
        setHasNextPage(false)
        setEndCursor(nil)
    }

    public func resetToIdle() {
        searchTask?.cancel()
        completionTask?.cancel()
        searchText = ""
        products = []
        completions = nil
        searchState = .idle
        setHasNextPage(false)
        setEndCursor(nil)
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

        guard NetworkMonitor.shared.getIsConnected() else {
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
            let validProducts = result.items.filter { product in
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
        } else if NetworkMonitor.shared.getIsConnected() {
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
