//
//  ProductRankingViewModel.swift
//  YukaMock
//
//  Created by Harro Krog on 10.11.25.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class ProductRankingViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isInitialLoading = false
    @Published var errorMessage: String?

    private var hasLoadedInitially = false
    private let categoryId: Int

    init(categoryId: Int) {
        self.categoryId = categoryId
    }

    func fetchProducts() async {
        guard !hasLoadedInitially else { return }

        isInitialLoading = true
        errorMessage = nil

        do {
            let result = try await GraphQLClient.shared.fetchProducts(
                first: 20,
                categoryId: categoryId,
                countryId: 9,
                sortAscending: true
            )
            products = result.products
            errorMessage = nil
            hasLoadedInitially = true
        } catch {
            errorMessage = error.localizedDescription
            products = []
            hasLoadedInitially = true
        }

        isInitialLoading = false
    }

    func refresh() async {
        errorMessage = nil

        do {
            let result = try await GraphQLClient.shared.fetchProducts(
                first: 20,
                categoryId: categoryId,
                countryId: 9,
                sortAscending: true
            )
            products = result.products
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
