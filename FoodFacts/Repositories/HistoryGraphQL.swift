//
//  HistoryGraphQL.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import Foundation

// MARK: - User Headers (Hardcoded)

struct UserHeaders {
    static let userId = "2"
    static let username = "bob_jones"

    static var authHeaders: [String: String] {
        [
            "x-user-id": userId,
            "x-username": username,
        ]
    }
}

// MARK: - Product History Models
struct ProductHistoryNode: Decodable {
    let id: Int
    let productCode: Int
    let scannedAt: String
    let product: ProductNode?
}

struct ProductNode: Decodable {
    let code: Int
    let productName: String?
    let productBrand: String?
    let imageUrl: String?
    let normalizedNutriScore: Int?
    let positiveNutrientRatings: [NutrientRatingNode]
    let negativeNutrientRatings: [NutrientRatingNode]
}

struct NutrientRatingNode: Decodable {
    let nutrientType: String
    let name: String
    let value: Double
    let unit: String
    let rating: String
    let text: String
    let ratingSections: [RatingSectionNode]
}

struct RatingSectionNode: Decodable {
    let rating: String
    let minValue: Double
    let maxValue: Double
    let description: String
}

struct ProductHistoryData: Decodable {
    let nodes: [ProductHistoryNode]
    let pageInfo: PageInfo
}

struct ProductHistoryQueryResponse: Decodable {
    let myProductHistory: ProductHistoryData
}

struct ProductHistoryResult {
    let historyItems: [ProductHistory]
    let pageInfo: PageInfo
}

// MARK: - History Mutation Response Models

struct AddProductHistoryItemResponse: Decodable {
    let addProductHistoryItem: AddProductHistoryItemPayload
}

struct AddProductHistoryItemPayload: Decodable {
    let id: Int
    let productCode: Int
    let scannedAt: String
}

struct RemoveProductHistoryItemResponse: Decodable {
    let removeProductHistoryItem: RemoveProductHistoryItemPayload
}

struct RemoveProductHistoryItemPayload: Decodable {
    let success: Bool
    let message: String
}

// MARK: - GraphQL Client Extension

extension GraphQLClient {

    // MARK: - History Queries

    func fetchProductHistory(
        first: Int = 20,
        after: String? = nil
    ) async throws -> ProductHistoryResult {
        var paginationParams = "first: \(first)"
        if let after = after {
            paginationParams += ", after: \"\(after)\""
        }

        let queryString = """
            query MyProductHistory {
                myProductHistory(\(paginationParams)) {
                    nodes {
                        id
                        productCode
                        scannedAt
                        product {
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

        let response: ProductHistoryQueryResponse = try await execute(
            query: queryString,
            headers: UserHeaders.authHeaders
        )

        let historyItems = response.myProductHistory.nodes.map { node in
            ProductHistory(
                id: node.id,
                productCode: node.productCode,
                scannedAt: node.scannedAt,
                product: node.product.map { productNode in
                    Product(
                        code: productNode.code,
                        name: productNode.productName,
                        brand: productNode.productBrand,
                        imageUrl: productNode.imageUrl,
                        nutriScore: productNode.normalizedNutriScore,
                        positiveNutrientRatings: productNode.positiveNutrientRatings.map { rating in
                            NutrientRating(
                                nutrientType: rating.nutrientType,
                                name: rating.name,
                                value: rating.value,
                                unit: rating.unit,
                                rating: rating.rating,
                                text: rating.text,
                                ratingSections: rating.ratingSections.map { section in
                                    RatingSection(
                                        rating: section.rating,
                                        minValue: section.minValue,
                                        maxValue: section.maxValue,
                                        description: section.description
                                    )
                                }
                            )
                        },
                        negativeNutrientRatings: productNode.negativeNutrientRatings.map { rating in
                            NutrientRating(
                                nutrientType: rating.nutrientType,
                                name: rating.name,
                                value: rating.value,
                                unit: rating.unit,
                                rating: rating.rating,
                                text: rating.text,
                                ratingSections: rating.ratingSections.map { section in
                                    RatingSection(
                                        rating: section.rating,
                                        minValue: section.minValue,
                                        maxValue: section.maxValue,
                                        description: section.description
                                    )
                                }
                            )
                        }
                    )
                }
            )
        }

        return ProductHistoryResult(
            historyItems: historyItems,
            pageInfo: response.myProductHistory.pageInfo
        )
    }

    // MARK: - History Mutations

    func addProductHistoryItem(productCode: Int) async throws
        -> AddProductHistoryItemPayload
    {
        let mutationString = """
            mutation AddProductHistoryItem {
                addProductHistoryItem(input: { productCode: \(productCode) }) {
                    id
                    productCode
                    scannedAt
                }
            }
            """

        let response: AddProductHistoryItemResponse = try await execute(
            query: mutationString,
            headers: UserHeaders.authHeaders
        )

        return response.addProductHistoryItem
    }

    func removeProductHistoryItem(historyId: Int) async throws
        -> RemoveProductHistoryItemPayload
    {
        let mutationString = """
            mutation RemoveProductHistoryItem {
                removeProductHistoryItem(input: { historyId: \(historyId) }) {
                    success
                    message
                }
            }
            """

        let response: RemoveProductHistoryItemResponse = try await execute(
            query: mutationString,
            headers: UserHeaders.authHeaders
        )

        return response.removeProductHistoryItem
    }
}
