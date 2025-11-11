//
//  FavoritesViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isInitialLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasNextPage = false

    private var endCursor: String?
    private var hasLoadedInitially = false

    func fetchFavorites() async {
        guard !hasLoadedInitially else { return }

        isInitialLoading = true
        errorMessage = nil

        do {
            let result = try await GraphQLClient.shared.fetchFavoriteProducts()
            products = result.products
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            hasLoadedInitially = true
            // Clear error on successful fetch, even if empty
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            products = []
            hasNextPage = false
            endCursor = nil
            hasLoadedInitially = true
        }

        isInitialLoading = false
    }

    func loadMore() async {
        guard !isLoadingMore, hasNextPage, let cursor = endCursor else { return }

        isLoadingMore = true

        do {
            let result = try await GraphQLClient.shared.fetchFavoriteProducts(after: cursor)
            products.append(contentsOf: result.products)
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            // Clear error on successful fetch
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    func refresh() async {
        hasLoadedInitially = false
        endCursor = nil
        hasNextPage = false
        products = []
        errorMessage = nil
        await fetchFavorites()
    }

    func addFavorite(productCode: Int) async {
        do {
            let result = try await GraphQLClient.shared.addFavoriteProduct(productCode: productCode)
            if result.success {
                await refresh()
            } else {
                errorMessage = result.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeFavorite(productCode: Int) async {
        do {
            let result = try await GraphQLClient.shared.removeFavoriteProduct(productCode: productCode)
            if result.success {
                products.removeAll { $0.id == productCode }
            } else {
                errorMessage = result.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func isProductFavorited(productCode: Int) async -> Bool {
        do {
            return try await GraphQLClient.shared.isProductFavoritedByMe(productCode: productCode)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
