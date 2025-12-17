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

// MARK: - Product History Models
@available(iOS 15.0, *)
public struct ProductHistoryNode: Decodable {
    public let id: Int
    public let productCode: Int
    public let scannedAt: String
    public let product: ProductNode?
}

@available(iOS 15.0, *)
public struct ProductNode: Decodable {
    public let code: Int
    public let productName: String?
    public let productBrand: String?
    public let imageUrl: String?
    public let normalizedNutriScore: Int?
    public let positiveNutrientRatings: [NutrientRatingNode]
    public let negativeNutrientRatings: [NutrientRatingNode]
    public let additivesRatings: AdditiveRatingNode?
}

@available(iOS 15.0, *)
public struct NutrientRatingNode: Decodable {
    public let nutrientType: String
    public let name: String
    public let value: Double
    public let unit: String
    public let rating: String
    public let text: String
    public let ratingSections: [RatingSectionNode]?
}

@available(iOS 15.0, *)
public struct RatingSectionNode: Decodable {
    public let rating: String
    public let minValue: Double
    public let maxValue: Double
    public let description: String
}

@available(iOS 15.0, *)
public struct AdditiveRatingNode: Decodable {
    public let rating: String
    public let description: String
    public let numberOfAdditives: Int
    public let additives: [AdditiveNode]
}

@available(iOS 15.0, *)
public struct AdditiveNode: Decodable {
    public let id: Int
    public let name: String
    public let description: String?
    public let risk: String?
    public let additiveTypeId: Int?
    public let additiveType: AdditiveTypeNode?
    public let additiveHealthRisks: [AdditiveHealthRiskRelationNode]?
}

@available(iOS 15.0, *)
public struct AdditiveTypeNode: Decodable {
    public let id: Int
    public let name: String
    public let description: String?
}

@available(iOS 15.0, *)
public struct AdditiveHealthRiskRelationNode: Decodable {
    public let additiveId: Int
    public let healthRiskId: Int
    public let healthRisk: HealthRiskNode
}

@available(iOS 15.0, *)
public struct HealthRiskNode: Decodable {
    public let id: Int
    public let name: String
}

@available(iOS 15.0, *)
public struct ProductHistoryData: Decodable {
    public let nodes: [ProductHistoryNode]
    public let pageInfo: PageInfo
}

@available(iOS 15.0, *)
public struct ProductHistoryQueryResponse: Decodable {
    public let myProductHistory: ProductHistoryData
}

@available(iOS 15.0, *)
public struct ProductHistoryResult {
    public let historyItems: [ProductHistory]
    public let pageInfo: PageInfo

    public init(historyItems: [ProductHistory], pageInfo: PageInfo) {
        self.historyItems = historyItems
        self.pageInfo = pageInfo
    }
}

// MARK: - History Mutation Response Models

@available(iOS 15.0, *)
public struct AddProductHistoryItemResponse: Decodable {
    public let addProductHistoryItem: AddProductHistoryItemPayload
}

@available(iOS 15.0, *)
public struct AddProductHistoryItemPayload: Decodable {
    public let id: Int
    public let productCode: Int
    public let scannedAt: String
}

@available(iOS 15.0, *)
public struct RemoveProductHistoryItemResponse: Decodable {
    public let removeProductHistoryItem: RemoveProductHistoryItemPayload
}

@available(iOS 15.0, *)
public struct RemoveProductHistoryItemPayload: Decodable {
    public let success: Bool
    public let message: String
}

// MARK: - GraphQL Client Extension

@available(iOS 15.0, *)
extension GraphQLClient {

    // MARK: - Mapping Helpers

    private func mapNutrientRating(_ rating: NutrientRatingNode) -> NutrientRating {
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

    private func mapAdditive(_ additive: AdditiveNode) -> Additive {
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

    private func mapAdditiveRating(_ additivesRating: AdditiveRatingNode) -> AdditiveRating {
        AdditiveRating(
            rating: additivesRating.rating,
            description: additivesRating.description,
            numberOfAdditives: additivesRating.numberOfAdditives,
            additives: additivesRating.additives.map { mapAdditive($0) }
        )
    }

    private func mapProduct(_ productNode: ProductNode) -> Product {
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

        return ProductHistoryResult(
            historyItems: historyItems,
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
