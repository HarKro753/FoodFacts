//
//  FavoritesGraphQL.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import Foundation
import Models

// MARK: - Favorite Products Models

@available(iOS 15.0, *)
public struct FavoriteProductNode: Decodable {
    public let code: Int
    public let productName: String?
    public let productBrand: String?
    public let imageUrl: String?
    public let normalizedNutriScore: Int?
    public let positiveNutrientRatings: [NutrientRating]
    public let negativeNutrientRatings: [NutrientRating]
}

@available(iOS 15.0, *)
public struct FavoriteProductsData: Decodable {
    public let nodes: [FavoriteProductNode]
    public let pageInfo: PageInfo
}

@available(iOS 15.0, *)
public struct FavoriteProductsQueryResponse: Decodable {
    public let myFavoriteProducts: FavoriteProductsData
}

@available(iOS 15.0, *)
public struct FavoriteProductsResult {
    public let products: [Product]
    public let pageInfo: PageInfo

    public init(products: [Product], pageInfo: PageInfo) {
        self.products = products
        self.pageInfo = pageInfo
    }
}

// MARK: - Is Product Favorited Models

public struct IsProductFavoritedResponse: Decodable {
    public let isProductFavoritedByMe: Bool
}

// MARK: - Favorite Mutation Response Models

public struct FavoriteProductResponse: Decodable {
    public let payload: FavoriteProductPayload

    enum CodingKeys: String, CodingKey {
        case payload = "addFavoriteProduct"
    }
}

public struct RemoveFavoriteProductResponse: Decodable {
    public let payload: FavoriteProductPayload

    enum CodingKeys: String, CodingKey {
        case payload = "removeFavoriteProduct"
    }
}

public struct FavoriteProductPayload: Decodable {
    public let success: Bool
    public let message: String
}

// MARK: - GraphQL Client Extension

@available(iOS 15.0, *)
extension GraphQLClient {

    // MARK: - Favorite Queries

    public func fetchFavoriteProducts(
        first: Int = 20,
        after: String? = nil
    ) async throws -> FavoriteProductsResult {
        var paginationParams = "first: \(first)"
        if let after = after {
            paginationParams += ", after: \"\(after)\""
        }

        let queryString = """
            query MyFavoriteProducts {
                myFavoriteProducts(\(paginationParams)) {
                    nodes {
                        code
                        productName
                        productBrand
                        imageUrl
                        normalizedNutriScore
                        positiveNutrientRatings {
                            nutrientType
                            name
                            value
                            unit
                            rating
                            text
                            ratingSections {
                                rating
                                minValue
                                maxValue
                                description
                            }
                        }
                        negativeNutrientRatings {
                            nutrientType
                            name
                            value
                            unit
                            rating
                            text
                            ratingSections {
                                rating
                                minValue
                                maxValue
                                description
                            }
                        }
                    }
                    pageInfo {
                        hasNextPage
                        hasPreviousPage
                        startCursor
                        endCursor
                    }
                }
            }
            """

        let response: FavoriteProductsQueryResponse = try await execute(
            query: queryString,
            headers: UserHeaders.authHeaders
        )

        let products = response.myFavoriteProducts.nodes.map { node in
            Product(
                code: node.code,
                name: node.productName,
                brand: node.productBrand,
                imageUrl: node.imageUrl,
                nutriScore: node.normalizedNutriScore,
                positiveNutrientRatings: node.positiveNutrientRatings,
                negativeNutrientRatings: node.negativeNutrientRatings
            )
        }

        return FavoriteProductsResult(
            products: products,
            pageInfo: response.myFavoriteProducts.pageInfo
        )
    }

    public func isProductFavoritedByMe(productCode: Int) async throws -> Bool {
        let queryString = """
            query IsProductFavorited {
                isProductFavoritedByMe(productCode: \(productCode))
            }
            """

        let response: IsProductFavoritedResponse = try await execute(
            query: queryString,
            headers: UserHeaders.authHeaders
        )

        return response.isProductFavoritedByMe
    }

    // MARK: - Favorite Mutations

    public func addFavoriteProduct(productCode: Int) async throws
        -> FavoriteProductPayload
    {
        let mutationString = """
            mutation AddFavoriteProduct {
                addFavoriteProduct(input: { productCode: \(productCode) }) {
                    success
                    message
                }
            }
            """

        let response: FavoriteProductResponse = try await execute(
            query: mutationString,
            headers: UserHeaders.authHeaders
        )

        return response.payload
    }

    public func removeFavoriteProduct(productCode: Int) async throws
        -> FavoriteProductPayload
    {
        let mutationString = """
            mutation RemoveFavoriteProduct {
                removeFavoriteProduct(input: { productCode: \(productCode) }) {
                    success
                    message
                }
            }
            """

        let response: RemoveFavoriteProductResponse = try await execute(
            query: mutationString,
            headers: UserHeaders.authHeaders
        )

        return response.payload
    }
}
