//
//  LabelProductsViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 17.11.25.
//

import Combine
import NetworkImage
import SwiftUI

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
            let result: ProductsResult

            switch filter {
            case .label(let id):
                result = try await GraphQLClient.shared.fetchProducts(
                    first: 20,
                    labelId: id
                )

            case .category(let id):
                result = try await GraphQLClient.shared.fetchProducts(
                    first: 10,
                    categoryId: id
                )

            case .nutrientMin(let fieldName, let minValue):
                result = try await GraphQLClient.shared.fetchProducts(
                    first: 20,
                    nutrientFieldName: fieldName,
                    nutrientMinValue: minValue
                )

            case .nutrientMax(let fieldName, let maxValue):
                result = try await GraphQLClient.shared.fetchProducts(
                    first: 20,
                    nutrientFieldName: fieldName,
                    nutrientMaxValue: maxValue
                )
            }

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
            let result: ProductsResult

            switch filter {
            case .label(let id):
                result = try await GraphQLClient.shared.fetchProducts(
                    first: 20,
                    after: cursor,
                    labelId: id
                )

            case .nutrientMin(let fieldName, let minValue):
                result = try await GraphQLClient.shared.fetchProducts(
                    first: 20,
                    after: cursor,
                    nutrientFieldName: fieldName,
                    nutrientMinValue: minValue
                )
            case .category(let id):
                result = try await GraphQLClient.shared.fetchProducts(
                    first: 10,
                    categoryId: id
                )

            case .nutrientMax(let fieldName, let maxValue):
                result = try await GraphQLClient.shared.fetchProducts(
                    first: 20,
                    after: cursor,
                    nutrientFieldName: fieldName,
                    nutrientMaxValue: maxValue
                )
            }

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
