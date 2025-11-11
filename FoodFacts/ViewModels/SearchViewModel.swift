//
//  SearchViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    static let shared = SearchViewModel()

    @Published var products: [Product] = []
    @Published var searchText = ""
    @Published var isSearching = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasNextPage = false

    private var endCursor: String?
    private var searchTask: Task<Void, Never>?

    private init() {
        // Debounce search text changes
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard let self = self else { return }
                Task {
                    await self.performSearch(query: newValue)
                }
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

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
            return
        }

        // Set loading state and clear products immediately before Task starts
        isSearching = true
        errorMessage = nil
        products = []

        searchTask = Task {

            do {
                let result = try await GraphQLClient.shared.fetchProducts(after: nil, searchQuery: query)

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
              !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isLoadingMore = true
        errorMessage = nil

        do {
            let result = try await GraphQLClient.shared.fetchProducts(
                after: cursor,
                searchQuery: searchText
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
    }
}
