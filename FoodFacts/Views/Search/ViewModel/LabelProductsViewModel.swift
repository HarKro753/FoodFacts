//
//  LabelProductsViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 17.11.25.
//

import Combine
import NetworkImage
import SwiftUI

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

    private var endCursor: String?
    private var currentFilter: CategoryFilter?

    func fetchProducts(for filter: CategoryFilter) async {
        guard !isLoading else { return }

        currentFilter = filter
        isLoading = true
        errorMessage = nil
        endCursor = nil
        hasNextPage = false

        do {
            let result = try await filter.fetchProducts(first: 20)

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
            let result = try await filter.fetchProducts(
                first: 20,
                after: cursor
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
}
