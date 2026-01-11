//
//  HistoryGraphQL.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import Foundation
import Models

// MARK: - User Headers (Hardcoded)

public struct UserHeaders {
    public static let userId = "2"
    public static let username = "bob_jones"

    public static var authHeaders: [String: String] {
        [
            "x-user-id": userId,
            "x-username": username,
        ]
    }
}

// MARK: - Public Payload Models

@available(iOS 15.0, *)
public struct AddProductHistoryItemPayload: Decodable {
    public let id: Int
    public let productCode: Int
    public let scannedAt: String
}

@available(iOS 15.0, *)
public struct RemoveProductHistoryItemPayload: Decodable {
    public let success: Bool
    public let message: String
}

// MARK: - GraphQL Client Extension

@available(iOS 15.0, *)
extension GraphQLClient {
    private struct ProductHistoryQueryResponse: Decodable {
        struct MyProductHistory: Decodable {
            struct Node: Decodable {
                struct Product: Decodable {
                    struct NutrientRating: Decodable {
                        struct RatingSection: Decodable {
                            let rating: String
                            let minValue: Double
                            let maxValue: Double
                            let description: String
                        }
                        let nutrientType: String
                        let name: String
                        let value: Double
                        let unit: String
                        let rating: String
                        let text: String
                        let ratingSections: [RatingSection]?
                    }
                    struct AdditiveRating: Decodable {
                        struct Additive: Decodable {
                            struct AdditiveType: Decodable {
                                let id: Int
                                let name: String
                                let description: String?
                            }
                            struct AdditiveHealthRiskRelation: Decodable {
                                struct HealthRisk: Decodable {
                                    let id: Int
                                    let name: String
                                }
                                let additiveId: Int
                                let healthRiskId: Int
                                let healthRisk: HealthRisk
                            }
                            let id: Int
                            let name: String
                            let description: String?
                            let risk: String?
                            let additiveTypeId: Int?
                            let additiveType: AdditiveType?
                            let additiveHealthRisks: [AdditiveHealthRiskRelation]?
                        }
                        let rating: String
                        let description: String
                        let numberOfAdditives: Int
                        let additives: [Additive]
                    }
                    let code: Int
                    let productName: String?
                    let productBrand: String?
                    let imageUrl: String?
                    let normalizedNutriScore: Int?
                    let positiveNutrientRatings: [NutrientRating]
                    let negativeNutrientRatings: [NutrientRating]
                    let additivesRatings: AdditiveRating?
                }
                let id: Int
                let productCode: Int
                let scannedAt: String
                let product: Product?
            }
            let nodes: [Node]
            let pageInfo: PageInfo
        }
        let myProductHistory: MyProductHistory
    }

    private struct AddProductHistoryItemResponse: Decodable {
        let addProductHistoryItem: AddProductHistoryItemPayload
    }

    private struct RemoveProductHistoryItemResponse: Decodable {
        let removeProductHistoryItem: RemoveProductHistoryItemPayload
    }

    // MARK: - Mapping Helpers

    private func mapNutrientRating(_ rating: ProductHistoryQueryResponse.MyProductHistory.Node.Product.NutrientRating) -> NutrientRating {
        NutrientRating(
            nutrientType: rating.nutrientType,
            name: rating.name,
            value: rating.value,
            unit: rating.unit,
            rating: rating.rating,
            text: rating.text,
            ratingSections: rating.ratingSections?.map { section in
                RatingSection(
                    rating: section.rating,
                    minValue: section.minValue,
                    maxValue: section.maxValue,
                    description: section.description
                )
            }
        )
    }

    private func mapAdditive(_ additive: ProductHistoryQueryResponse.MyProductHistory.Node.Product.AdditiveRating.Additive) -> Additive {
        Additive(
            id: additive.id,
            name: additive.name,
            description: additive.description,
            risk: additive.risk,
            additiveTypeId: additive.additiveTypeId,
            additiveType: additive.additiveType.map { type in
                AdditiveType(
                    id: type.id,
                    name: type.name,
                    description: type.description
                )
            },
            additiveHealthRisks: additive.additiveHealthRisks?.map { relation in
                AdditiveHealthRiskRelation(
                    additiveId: relation.additiveId,
                    healthRiskId: relation.healthRiskId,
                    healthRisk: HealthRisk(
                        id: relation.healthRisk.id,
                        name: relation.healthRisk.name
                    )
                )
            }
        )
    }

    private func mapAdditiveRating(_ additivesRating: ProductHistoryQueryResponse.MyProductHistory.Node.Product.AdditiveRating) -> AdditiveRating {
        AdditiveRating(
            rating: additivesRating.rating,
            description: additivesRating.description,
            numberOfAdditives: additivesRating.numberOfAdditives,
            additives: additivesRating.additives.map { mapAdditive($0) }
        )
    }

    private func mapProduct(_ productNode: ProductHistoryQueryResponse.MyProductHistory.Node.Product) -> Product {
        Product(
            code: productNode.code,
            name: productNode.productName,
            brand: productNode.productBrand,
            imageUrl: productNode.imageUrl,
            nutriScore: productNode.normalizedNutriScore,
            positiveNutrientRatings: productNode.positiveNutrientRatings.map { mapNutrientRating($0) },
            negativeNutrientRatings: productNode.negativeNutrientRatings.map { mapNutrientRating($0) },
            additivesRatings: productNode.additivesRatings.map { mapAdditiveRating($0) }
        )
    }

    // MARK: - History Queries

    public func fetchProductHistory(
        first: Int = 20,
        after: String? = nil
    ) async throws -> PaginatedResult<ProductHistory> {
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
                            additivesRatings {
                                rating
                                description
                                numberOfAdditives
                                additives {
                                    id
                                    name
                                    description
                                    risk
                                    additiveTypeId
                                    additiveType {
                                        id
                                        name
                                        description
                                    }
                                    additiveHealthRisks {
                                        additiveId
                                        healthRiskId
                                        healthRisk {
                                            id
                                            name
                                        }
                                    }
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
                product: node.product.map { mapProduct($0) }
            )
        }

        return PaginatedResult(
            items: historyItems,
            pageInfo: response.myProductHistory.pageInfo
        )
    }

    // MARK: - History Mutations

    public func addProductHistoryItem(productCode: Int) async throws
        -> AddProductHistoryItemPayload
    {
        let mutationString = """
            mutation AddProductHistoryItem {
                addProductHistoryItem(input: { productCode: \(productCode) }) {
                    id
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
            """

        let response: AddProductHistoryItemResponse = try await execute(
            query: mutationString,
            headers: UserHeaders.authHeaders
        )

        return response.addProductHistoryItem
    }

    public func removeProductHistoryItem(historyId: Int) async throws
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
