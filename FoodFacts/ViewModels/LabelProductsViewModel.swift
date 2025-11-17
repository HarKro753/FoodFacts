//
//  LabelProductsViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 17.11.25.
//


import SwiftUI
import NetworkImage
import Combine

@MainActor
class LabelProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasNextPage = false

    private var endCursor: String?

    func fetchProducts(for labelId: Int) async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        endCursor = nil
        hasNextPage = false

        do {
            let result = try await GraphQLClient.shared.fetchProducts(
                first: 20,
                labelId: labelId
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

    func loadMore(for labelId: Int) async {
        guard !isLoadingMore,
              hasNextPage,
              let cursor = endCursor else { return }

        isLoadingMore = true
        errorMessage = nil

        do {
            let result = try await GraphQLClient.shared.fetchProducts(
                first: 20,
                after: cursor,
                labelId: labelId
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
