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
    let id: String
    let name: String
    let filter: CategoryFilter

    static let categories: [ProductCategory] = [
        // Nutrient-based categories
        ProductCategory(
            id: "high-protein",
            name: "High Protein",
            filter: .nutrientMin(fieldName: "proteins100g", minValue: 10.0)
        ),
        ProductCategory(
            id: "low-calorie",
            name: "Less than 500 Cal",
            filter: .nutrientMax(fieldName: "energyKcal100g", maxValue: 500.0)
        ),
        ProductCategory(
            id: "vitamin-a",
            name: "Vitamin A High",
            filter: .nutrientMin(fieldName: "vitaminA100g", minValue: 50.0)
        ),
        ProductCategory(
            id: "vitamin-d",
            name: "Vitamin D High",
            filter: .nutrientMin(fieldName: "vitaminD100g", minValue: 5.0)
        ),
        // Label-based categories
        ProductCategory(
            id: "label-1",
            name: "Organic",
            filter: .label(id: 1)
        ),
        ProductCategory(
            id: "label-5",
            name: "No gluten",
            filter: .label(id: 5)
        ),
        ProductCategory(
            id: "label-11",
            name: "EU Organic",
            filter: .label(id: 11)
        ),
        ProductCategory(
            id: "label-3",
            name: "Vegetarian",
            filter: .label(id: 3)
        ),
        ProductCategory(
            id: "label-4",
            name: "Vegan",
            filter: .label(id: 4)
        ),
        ProductCategory(
            id: "label-6",
            name: "No GMOs",
            filter: .label(id: 6)
        ),
    ]
}

// Keep ProductLabel for backward compatibility with navigation
struct ProductLabel: Identifiable, Hashable {
    let id: String
    let name: String
    let filter: CategoryFilter
}

@MainActor
class SearchViewModel: ObservableObject {
    static let shared = SearchViewModel()

    // Search results
    @Published var products: [Product] = []
    @Published var searchText = ""
    @Published var isSearching = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasNextPage = false

    // Category products
    @Published var categoryProducts: [String: [Product]] = [:]
    @Published var isLoadingCategories = false

    private var endCursor: String?
    private var searchTask: Task<Void, Never>?
    private var isSearchCommitted = false

    private init() {}

    private var cancellables = Set<AnyCancellable>()

    func onSearchSubmit() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        isSearchCommitted = true
        await performSearch(query: searchText)
    }

    func performSearch(query: String) async {
        // Cancel any existing search task
        searchTask?.cancel()

        // Reset state
        endCursor = nil
        hasNextPage = false

        // Don't search if query is empty
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            products = []
            errorMessage = nil
            isSearching = false
            isSearchCommitted = false
            return
        }

        // Set loading state and clear products immediately before Task starts
        isSearching = true
        errorMessage = nil
        products = []

        searchTask = Task {

            do {
                let result = try await GraphQLClient.shared.fetchProducts(
                    after: nil,
                    sortAscending: true,
                    searchQuery: query
                )

                // Check if task was cancelled
                guard !Task.isCancelled else { return }

                products = result.products
                hasNextPage = result.pageInfo.hasNextPage
                endCursor = result.pageInfo.endCursor
                errorMessage = nil
            } catch {
                // Only update error if task wasn't cancelled
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
                products = []
                hasNextPage = false
                endCursor = nil
            }

            isSearching = false
        }

        await searchTask?.value
    }

    func loadMore() async {
        guard !isLoadingMore,
            hasNextPage,
            let cursor = endCursor,
            !searchText.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }

        isLoadingMore = true
        errorMessage = nil

        do {
            let result = try await GraphQLClient.shared.fetchProducts(
                after: cursor,
                sortAscending: true,
                searchQuery: searchText,
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

    func clearSearch() {
        searchText = ""
        products = []
        errorMessage = nil
        hasNextPage = false
        endCursor = nil
        isSearchCommitted = false
    }

    // MARK: - Category Products

    func fetchCategoryProducts() async {
        guard categoryProducts.isEmpty else { return }

        isLoadingCategories = true

        // Fetch products for each category concurrently
        await withTaskGroup(of: (String, [Product]).self) { group in
            for category in ProductCategory.categories {
                group.addTask {
                    do {
                        let result: ProductsResult

                        switch category.filter {
                        case .label(let id):
                            result = try await GraphQLClient.shared.fetchProducts(
                                first: 10,
                                labelId: id,
                                sortAscending: true
                            )

                        case .nutrientMin(let fieldName, let minValue):
                            result = try await GraphQLClient.shared.fetchProducts(
                                first: 10,
                                sortAscending: true,
                                nutrientFieldName: fieldName,
                                nutrientMinValue: minValue
                            )

                        case .nutrientMax(let fieldName, let maxValue):
                            result = try await GraphQLClient.shared.fetchProducts(
                                first: 10,
                                sortAscending: true,
                                nutrientFieldName: fieldName,
                                nutrientMaxValue: maxValue
                            )
                        }

                        print("Successfully fetched \(result.products.count) products for category \(category.name)")
                        return (category.id, result.products)
                    } catch {
                        // Return empty array on error to prevent blocking
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

    var shouldShowIdleState: Bool {
        return searchText.trimmingCharacters(in: .whitespaces).isEmpty
            && !isSearchCommitted
    }

    var shouldShowSearchResults: Bool {
        return isSearchCommitted
            && !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var shouldShowPlaceholder: Bool {
        return !searchText.trimmingCharacters(in: .whitespaces).isEmpty
            && !isSearchCommitted
    }
}
