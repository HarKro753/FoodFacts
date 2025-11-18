//
//  SearchViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Category Models

enum CategoryFilter: Hashable {
    case label(id: Int)
    case nutrientMin(fieldName: String, minValue: Double)
    case nutrientMax(fieldName: String, maxValue: Double)
}

struct ProductCategory: Identifiable, Hashable {
    let id: Int
    let name: String
    let filter: CategoryFilter

    static let categories: [ProductCategory] = [
        // Nutrient-based categories
        ProductCategory(
            id: 0,
            name: "High Protein",
            filter: .nutrientMin(fieldName: "proteins100g", minValue: 10.0)
        ),
        ProductCategory(
            id: 1,
            name: "Less than 500 Cal",
            filter: .nutrientMax(fieldName: "energyKcal100g", maxValue: 500.0)
        ),
        ProductCategory(
            id: 2,
            name: "Vitamin A High",
            filter: .nutrientMin(fieldName: "vitaminA100g", minValue: 50.0)
        ),
        ProductCategory(
            id: 3,
            name: "Vitamin D High",
            filter: .nutrientMin(fieldName: "vitaminD100g", minValue: 5.0)
        ),
        // Label-based categories
        ProductCategory(
            id: 4,
            name: "Organic",
            filter: .label(id: 1)
        ),
        ProductCategory(
            id: 5,
            name: "No gluten",
            filter: .label(id: 5)
        ),
        ProductCategory(
            id: 6,
            name: "EU Organic",
            filter: .label(id: 11)
        ),
        ProductCategory(
            id: 7,
            name: "Vegetarian",
            filter: .label(id: 3)
        ),
        ProductCategory(
            id: 8,
            name: "Vegan",
            filter: .label(id: 4)
        ),
        ProductCategory(
            id: 9,
            name: "No GMOs",
            filter: .label(id: 6)
        ),
    ]
}

struct ProductLabel: Identifiable, Hashable {
    let id: String
    let name: String
    let filter: CategoryFilter
}

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

    // Search results
    @Published var products: [Product] = []
    @Published var searchText = ""
    @Published var searchState: SearchState = .idle
    @Published var hasNextPage = false

    // Category products
    @Published var categoryProducts: [Int: [Product]] = [:]
    @Published var isLoadingCategories = false

    private var endCursor: String?
    private var searchTask: Task<Void, Never>?

    init() {
        // Watch for search text changes to update state
        $searchText
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }

                let trimmedText = text.trimmingCharacters(in: .whitespaces)

                if trimmedText.isEmpty && self.searchState != .idle {
                    self.searchState = .idle
                }
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    func onSearchSubmit() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        await performSearch(query: searchText)
    }

    func performSearch(query: String) async {
        searchTask?.cancel()

        endCursor = nil
        hasNextPage = false

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            products = []
            searchState = .idle
            return
        }

        searchState = .searching
        products = []

        searchTask = Task {

            do {
                let result = try await GraphQLClient.shared.fetchProducts(
                    after: nil,
                    sortAscending: true,
                    searchQuery: query
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
            let result = try await GraphQLClient.shared.fetchProducts(
                after: cursor,
                sortAscending: true,
                searchQuery: searchText,
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

    // MARK: - Category Products

    func fetchCategoryProducts() async {
        guard categoryProducts.isEmpty else { return }

        isLoadingCategories = true

        // Fetch products for each category concurrently
        await withTaskGroup(of: (Int, [Product]).self) { group in
            for category in ProductCategory.categories {
                group.addTask {
                    do {
                        let result: ProductsResult

                        switch category.filter {
                        case .label(let id):
                            result = try await GraphQLClient.shared.fetchProducts(
                                first: 10,
                                labelId: id,
                            )

                        case .nutrientMin(let fieldName, let minValue):
                            result = try await GraphQLClient.shared.fetchProducts(
                                first: 10,
                                nutrientFieldName: fieldName,
                                nutrientMinValue: minValue
                            )

                        case .nutrientMax(let fieldName, let maxValue):
                            result = try await GraphQLClient.shared.fetchProducts(
                                first: 10,
                                nutrientFieldName: fieldName,
                                nutrientMaxValue: maxValue
                            )
                        }

                        print("Successfully fetched \(result.products.count) products for category \(category.name)")
                        return (category.id, result.products)
                    } catch {
                        print(
                            "Error fetching products for category \(category.name): \(error.localizedDescription)"
                        )
                        if let decodingError = error as? DecodingError {
                            print("Decoding error details: \(decodingError)")
                        }
                        return (category.id, [])
                    }
                }
            }

            for await (categoryId, products) in group {
                categoryProducts[categoryId] = products
            }
        }

        isLoadingCategories = false
    }

}
