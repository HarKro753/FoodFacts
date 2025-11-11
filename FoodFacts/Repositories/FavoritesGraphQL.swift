//
//  FavoritesGraphQL.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import Foundation

// MARK: - Favorite Products Models

struct FavoriteProductNode: Decodable {
    let code: Int
    let productName: String?
    let productBrand: String?
    let imageUrl: String?
    let normalizedNutriScore: Int?
    let positiveNutrientRatings: [NutrientRating]
    let negativeNutrientRatings: [NutrientRating]
}

struct FavoriteProductsData: Decodable {
    let nodes: [FavoriteProductNode]
    let pageInfo: PageInfo
}

struct FavoriteProductsQueryResponse: Decodable {
    let myFavoriteProducts: FavoriteProductsData
}

struct FavoriteProductsResult {
    let products: [Product]
    let pageInfo: PageInfo
}

// MARK: - Is Product Favorited Models

struct IsProductFavoritedResponse: Decodable {
    let isProductFavoritedByMe: Bool
}

// MARK: - Favorite Mutation Response Models

struct FavoriteProductResponse: Decodable {
    let payload: FavoriteProductPayload

    enum CodingKeys: String, CodingKey {
        case payload = "addFavoriteProduct"
    }
}

struct RemoveFavoriteProductResponse: Decodable {
    let payload: FavoriteProductPayload

    enum CodingKeys: String, CodingKey {
        case payload = "removeFavoriteProduct"
    }
}

struct FavoriteProductPayload: Decodable {
    let success: Bool
    let message: String
}

// MARK: - GraphQL Client Extension

extension GraphQLClient {

    // MARK: - Favorite Queries

    func fetchFavoriteProducts(
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

    func isProductFavoritedByMe(productCode: Int) async throws -> Bool {
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

    func addFavoriteProduct(productCode: Int) async throws
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

    func removeFavoriteProduct(productCode: Int) async throws
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
