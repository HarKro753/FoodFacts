//
//  FavoritesGraphQL.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import Foundation
import Models

// MARK: - Public Payload Model

public struct FavoriteProductPayload: Decodable {
    public let success: Bool
    public let message: String
}

// MARK: - GraphQL Client Extension

@available(iOS 15.0, *)
extension GraphQLClient {
    public func fetchFavoriteProducts(
        first: Int = 20,
        after: String? = nil
    ) async throws -> PaginatedResult<Product> {
        MockGraphQLStore.shared.fetchFavoriteProducts(first: first, after: after)
    }

    public func isProductFavoritedByMe(productCode: Int) async throws -> Bool {
        MockGraphQLStore.shared.isProductFavoritedByMe(productCode: productCode)
    }

    public func addFavoriteProduct(productCode: Int) async throws -> FavoriteProductPayload {
        MockGraphQLStore.shared.addFavoriteProduct(productCode: productCode)
    }

    public func removeFavoriteProduct(productCode: Int) async throws -> FavoriteProductPayload {
        MockGraphQLStore.shared.removeFavoriteProduct(productCode: productCode)
    }
}
