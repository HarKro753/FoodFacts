//
//  SearchViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Label Model
struct ProductLabel: Identifiable, Hashable {
    let id: Int
    let name: String
    let count: Int

    static let labels: [ProductLabel] = [
        ProductLabel(id: 1, name: "Organic", count: 273846),
        ProductLabel(id: 5, name: "No gluten", count: 213183),
        ProductLabel(id: 11, name: "EU Organic", count: 184494),
        ProductLabel(id: 3, name: "Vegetarian", count: 149986),
        ProductLabel(id: 23, name: "Green Dot", count: 148974),
        ProductLabel(id: 4, name: "Vegan", count: 130263),
        ProductLabel(id: 52, name: "Nutriscore", count: 116173),
        ProductLabel(id: 6, name: "No GMOs", count: 81243),
        ProductLabel(id: 13, name: "AB Agriculture Biologique", count: 79624),
        ProductLabel(id: 17, name: "No preservatives", count: 77222),
        ProductLabel(id: 7, name: "Non GMO project", count: 69542),
        ProductLabel(id: 25, name: "Made in France", count: 49322),
        ProductLabel(id: 15, name: "No colorings", count: 47286),
        ProductLabel(id: 20, name: "No added sugar", count: 41819),
        ProductLabel(id: 21, name: "No lactose", count: 38294),
        ProductLabel(id: 50, name: "EU Agriculture", count: 36989),
    ]
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

    // Label products
    @Published var labelProducts: [Int: [Product]] = [:]
    @Published var isLoadingLabels = false

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

    // MARK: - Label Products

    func fetchLabelProducts() async {
        guard labelProducts.isEmpty else { return }

        isLoadingLabels = true

        // Fetch products for each label concurrently
        await withTaskGroup(of: (Int, [Product]).self) { group in
            for label in ProductLabel.labels {
                group.addTask {
                    do {
                        let result = try await GraphQLClient.shared
                            .fetchProducts(
                                first: 10,
                                labelId: label.id,
                                sortAscending: true
                            )
                        return (label.id, result.products)
                    } catch {
                        // Return empty array on error to prevent blocking
                        print(
                            "Error fetching products for label \(label.name): \(error)"
                        )
                        return (label.id, [])
                    }
                }
            }

            for await (labelId, products) in group {
                labelProducts[labelId] = products
            }
        }

        isLoadingLabels = false
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
