//
//  ProductGraphQL.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import Foundation
import Models

// MARK: - GraphQL Client Extension

@available(iOS 15.0, *)
extension GraphQLClient {
    public func fetchProducts(
        first: Int = 20,
        after: String? = nil,
        categoryId: Int? = nil,
        labelId: Int? = nil,
        labelIds: [Int]? = nil,
        countryId: Int? = nil,
        foodGroup: Int? = nil,
        sortAscending: Bool? = nil,
        searchQuery: String? = nil,
        productCodeForAlternatives: Int? = nil,
        nutrientFieldName: String? = nil,
        nutrientMinValue: Double? = nil,
        nutrientMaxValue: Double? = nil,
        nutrientConditions: [(fieldName: String, minValue: Double?, maxValue: Double?)]? = nil
    ) async throws -> PaginatedResult<Product> {
        MockGraphQLStore.shared.fetchProducts(
            first: first,
            after: after,
            categoryId: categoryId,
            labelId: labelId,
            labelIds: labelIds,
            countryId: countryId,
            foodGroup: foodGroup,
            sortAscending: sortAscending,
            searchQuery: searchQuery,
            productCodeForAlternatives: productCodeForAlternatives,
            nutrientFieldName: nutrientFieldName,
            nutrientMinValue: nutrientMinValue,
            nutrientMaxValue: nutrientMaxValue,
            nutrientConditions: nutrientConditions
        )
    }

    public func fetchProductByCode(code: String) async throws -> Product? {
        MockGraphQLStore.shared.fetchProductByCode(code)
    }

    public func fetchRandomProduct() async throws -> Product? {
        MockGraphQLStore.shared.fetchRandomProduct()
    }
}
