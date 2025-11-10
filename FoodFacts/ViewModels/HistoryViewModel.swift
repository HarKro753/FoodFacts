//
//  HistoryViewModel.swift
//  YukaMock
//
//  Created by Harro Krog on 09.11.25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isInitialLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasNextPage = false

    private var endCursor: String?
    private var hasLoadedInitially = false

    func fetchProducts() async {
        guard !hasLoadedInitially else { return }

        isInitialLoading = true
        errorMessage = nil

        do {
            let result = try await GraphQLClient.shared.fetchProducts()
            products = result.products
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            errorMessage = nil
            hasLoadedInitially = true
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
        errorMessage = nil

        do {
            let result = try await GraphQLClient.shared.fetchProducts(after: cursor)
            products.append(contentsOf: result.products)
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
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
        await fetchProducts()
    }
}
