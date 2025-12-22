//
//  CategoryFilter+GraphQL.swift
//  Env
//
//  Created by Harro Krog on 18.11.25.
//

import GraphQl
import Models

extension CategoryFilter {
    public func fetchProducts(
        first: Int = 20,
        after: String? = nil,
        labelIds: [Int]? = nil,
        nutrientConditions: [(String, Double?, Double?)]? = nil,
        sortAscending: Bool? = nil
    ) async throws -> ProductsResult {
        switch self {
        case .label(let id):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelId: id,
                labelIds: labelIds,
                sortAscending: sortAscending,
                nutrientConditions: nutrientConditions
            )

        case .category(let id):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                categoryId: id,
                labelIds: labelIds,
                sortAscending: sortAscending,
                nutrientConditions: nutrientConditions
            )

        case .foodGroup(let id):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelIds: labelIds,
                foodGroup: id,
                sortAscending: sortAscending,
                nutrientConditions: nutrientConditions
            )

        case .nutrientMin(let fieldName, let minValue):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelIds: labelIds,
                sortAscending: sortAscending,
                nutrientFieldName: fieldName,
                nutrientMinValue: minValue,
                nutrientConditions: nutrientConditions
            )

        case .nutrientMax(let fieldName, let maxValue):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelIds: labelIds,
                sortAscending: sortAscending,
                nutrientFieldName: fieldName,
                nutrientMaxValue: maxValue,
                nutrientConditions: nutrientConditions
            )
        }
    }
}
