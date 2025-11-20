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

    @Published var activeFilters: Set<ProductFilter> = []

    var filterStateId: String {
        activeFilters.sorted(by: { $0.id < $1.id }).map { $0.id }.joined(
            separator: "-"
        )
    }

    @Published var categoryProducts: [Int: [Product]] = [:]
    @Published var loadingCategories: Set<Int> = []
    @Published var fetchedCategories: Set<Int> = []
    @Published var categories: [ProductCategoryData] = []

    // Autocomplete
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
        // Randomize categories on initialization
        categories = ProductCategoryData.categories.shuffled()

        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self else { return }

                let trimmedText = text.trimmingCharacters(in: .whitespaces)

                if trimmedText.isEmpty {
                    self.completions = nil
                    // Only reset to idle if we're not showing search results
                    if self.searchState != .idle
                        && self.searchState != .searchResults
                        && self.searchState != .loadingMore
                    {
                        self.searchState = .idle
                    }
                } else {
                    // Only fetch completions if we're in idle state
                    if self.searchState == .idle {
                        Task {
                            await self.fetchCompletions(for: trimmedText)
                        }
                    }
                }
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
                // If completions fail, set to nil
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

    ///
    ///
    ///
    func onSearchSubmit() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        await performSearch(query: searchText)
    }

    ///
    ///
    ///
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
                let filterParams = buildFilterParameters()

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
            let filterParams = buildFilterParameters()

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
        // Cancel any ongoing tasks
        searchTask?.cancel()
        completionTask?.cancel()

        // Clear all state
        searchText = ""
        products = []
        completions = nil
        searchState = .idle
        hasNextPage = false
        endCursor = nil
    }

    // MARK: - Filter Management

    func toggleFilter(_ filter: ProductFilter) {
        if activeFilters.contains(filter) {
            activeFilters.remove(filter)
        } else {
            activeFilters.insert(filter)
        }

        categoryProducts.removeAll()
        fetchedCategories.removeAll()

        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty
            || searchState == .searchResults
        {
            Task {
                await performSearch(query: searchText)
            }
        }
    }

    func clearFilters() {
        activeFilters.removeAll()

        categoryProducts.removeAll()
        fetchedCategories.removeAll()

        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty
            || searchState == .searchResults
        {
            Task {
                await performSearch(query: searchText)
            }
        }
    }

    private func buildFilterParameters() -> (
        labelIds: [Int]?, nutrientConditions: [(String, Double?, Double?)]?,
        sortAscending: Bool?
    ) {
        var labelIds: [Int] = []
        var nutrientConditions: [(String, Double?, Double?)] = []
        var sortAscending: Bool? = nil

        for filter in activeFilters {
            switch filter {
            case .vegan:
                labelIds.append(4)
            case .vegetarian:
                labelIds.append(3)
            case .lowCalorie:
                nutrientConditions.append(("energyKcal100g", nil, 200.0))
            case .highProtein:
                nutrientConditions.append(("proteins100g", 10.0, nil))
            case .highNutriScore:
                sortAscending = true
            }
        }

        return (
            labelIds: labelIds.isEmpty ? nil : labelIds,
            nutrientConditions: nutrientConditions.isEmpty
                ? nil : nutrientConditions,
            sortAscending: sortAscending
        )
    }

    // MARK: - Category Products

    func fetchProductsForCategory(_ category: ProductCategoryData) async {
        // Skip if already fetched or currently loading
        guard !fetchedCategories.contains(category.id),
            !loadingCategories.contains(category.id)
        else { return }

        loadingCategories.insert(category.id)

        do {
            let filterParams = buildFilterParameters()

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
