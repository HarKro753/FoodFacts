//
//  SearchViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import Combine
import Foundation
import SwiftUI

enum SearchState: Equatable {
    case idle
    case searching
    case searchResults
    case loadingMore
    case error(String)
}

@MainActor
class SearchViewModel: ObservableObject {
    static let shared = SearchViewModel()

    @Published var products: [Product] = []
    @Published var searchText = ""
    @Published var searchState: SearchState = .idle
    @Published var hasNextPage = false

    let filterManager = FilterManager.shared

    @Published var filterStateId: String = ""

    var activeFilters: Set<ProductFilter> {
        filterManager.activeFilters
    }

    @Published var categoryProducts: [Int: [Product]] = [:]
    @Published var loadingCategories: Set<Int> = []
    @Published var fetchedCategories: Set<Int> = []
    @Published var categories: [ProductCategoryData] = []
    @Published var completions: CompletionsData? = nil

    var shouldShowCompletions: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
            && searchState != .searching && searchState != .searchResults
            && searchState != .loadingMore
    }

    private var endCursor: String?
    private var searchTask: Task<Void, Never>?
    private var completionTask: Task<Void, Never>?

    init() {
        categories = ProductCategoryData.categories.shuffled()
        filterStateId = filterManager.filterStateId

        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self else { return }

                let trimmedText = text.trimmingCharacters(in: .whitespaces)

                if trimmedText.isEmpty {
                    self.completions = nil
                    if self.searchState != .idle
                        && self.searchState != .searchResults
                        && self.searchState != .loadingMore
                    {
                        self.searchState = .idle
                    }
                } else {
                    if self.searchState == .idle {
                        Task {
                            await self.fetchCompletions(for: trimmedText)
                        }
                    }
                }
            }
            .store(in: &cancellables)

        filterManager.$activeFilters
            .sink { [weak self] _ in
                guard let self = self else { return }

                // Update filterStateId to trigger task refreshes in ExploreView
                self.filterStateId = self.filterManager.filterStateId

                // Clear cached category products so they refetch with new filters
                self.categoryProducts.removeAll()
                self.fetchedCategories.removeAll()
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Autocomplete

    func fetchCompletions(for text: String) async {
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

    func clearCompletions() {
        completionTask?.cancel()
        completions = nil
        searchText = ""
    }

    // MARK: - Search

    func onSearchSubmit() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        await performSearch(query: searchText)
    }

    private func performSearch(query: String) async {
        searchTask?.cancel()
        completionTask?.cancel()

        endCursor = nil
        hasNextPage = false
        completions = nil

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            products = []
            searchState = .idle
            return
        }

        searchState = .searching
        products = []

        searchTask = Task {

            do {
                let filterParams = filterManager.buildFilterParameters()

                let result = try await GraphQLClient.shared.fetchProducts(
                    after: nil,
                    labelIds: filterParams.labelIds,
                    sortAscending: filterParams.sortAscending,
                    searchQuery: query,
                    nutrientConditions: filterParams.nutrientConditions
                )

                guard !Task.isCancelled else { return }

                products = result.products
                hasNextPage = result.pageInfo.hasNextPage
                endCursor = result.pageInfo.endCursor
                searchState = .searchResults
            } catch {
                guard !Task.isCancelled else { return }
                searchState = .error(error.localizedDescription)
                products = []
                hasNextPage = false
                endCursor = nil
            }
        }

        await searchTask?.value
    }

    func loadMore() async {
        guard case .searchResults = searchState,
            hasNextPage,
            let cursor = endCursor,
            !searchText.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }

        searchState = .loadingMore

        do {
            let filterParams = filterManager.buildFilterParameters()

            let result = try await GraphQLClient.shared.fetchProducts(
                after: cursor,
                labelIds: filterParams.labelIds,
                sortAscending: filterParams.sortAscending,
                searchQuery: searchText,
                nutrientConditions: filterParams.nutrientConditions
            )
            products.append(contentsOf: result.products)
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            searchState = .searchResults
        } catch {
            searchState = .error(error.localizedDescription)
        }
    }

    func clearSearch() {
        searchText = ""
        products = []
        searchState = .idle
        hasNextPage = false
        endCursor = nil
    }

    func resetToIdle() {
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

    func toggleFilter(_ filter: ProductFilter) {
        filterManager.toggleFilter(filter)
    }

    func clearFilters() {
        filterManager.clearFilters()
    }

    // MARK: - Category Products

    func fetchProductsForCategory(_ category: ProductCategoryData) async {
        guard !fetchedCategories.contains(category.id),
            !loadingCategories.contains(category.id)
        else { return }

        loadingCategories.insert(category.id)

        do {
            let filterParams = filterManager.buildFilterParameters()

            let result = try await category.filter.fetchProducts(
                first: 10,
                labelIds: filterParams.labelIds,
                nutrientConditions: filterParams.nutrientConditions,
                sortAscending: filterParams.sortAscending
            )
            categoryProducts[category.id] = result.products
            fetchedCategories.insert(category.id)

            if result.products.isEmpty {
                print("No products found for category \(category.name)")
            } else {
                print(
                    "Successfully fetched \(result.products.count) products for category \(category.name)"
                )
            }
        } catch {
            print(
                "Error fetching products for category \(category.name): \(error.localizedDescription)"
            )
            if let decodingError = error as? DecodingError {
                print("Decoding error details: \(decodingError)")
            }
            categoryProducts[category.id] = []
            fetchedCategories.insert(category.id)
        }

        loadingCategories.remove(category.id)
    }

    func isLoadingCategory(_ categoryId: Int) -> Bool {
        loadingCategories.contains(categoryId)
    }

    func shouldShowCategory(_ categoryId: Int) -> Bool {
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
