//
//  ProductGraphQL.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import Foundation

// MARK: - Products Query Response Models

struct ProductsQueryResponse: Decodable {
    let products: ProductsData
}

struct ProductByCodeResponse: Decodable {
    let productByCode: ProductQueryNode?
}

struct ProductsData: Decodable {
    let nodes: [ProductQueryNode]
    let pageInfo: PageInfo
}

struct PageInfo: Decodable {
    let hasNextPage: Bool
    let hasPreviousPage: Bool
    let startCursor: String?
    let endCursor: String?
}

struct ProductsResult {
    let products: [Product]
    let pageInfo: PageInfo
}

struct ProductQueryNode: Decodable {
    let code: Int
    let productName: String?
    let productBrand: String?
    let imageUrl: String?
    let normalizedNutriScore: Int?
    let positiveNutrientRatings: [NutrientRating]
    let negativeNutrientRatings: [NutrientRating]
    let additivesRatings: AdditiveRating?
}

// MARK: - GraphQL Client Extension

extension GraphQLClient {
    func fetchProducts(
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
    ) async throws -> ProductsResult {
        var paginationParams = "first: \(first)"
        if let after = after {
            paginationParams += ", after: \"\(after)\""
        }

        var filterParams = "completeness: 0.7, lastImageDatetime: \"2025-01-01\", removeNoNutriScore: true, removeNoImage: true"
        if let categoryId = categoryId {
            filterParams += ", categoryId: \(categoryId)"
        }

        // Handle multiple label IDs
        if let labelIds = labelIds, !labelIds.isEmpty {
            // If multiple labels, we'll use the first one in filter and add others to where conditions
            filterParams += ", labelId: \(labelIds[0])"
        } else if let labelId = labelId {
            filterParams += ", labelId: \(labelId)"
        }

        if let countryId = countryId {
            filterParams += ", countryId: \(countryId)"
        }
        if let foodGroup = foodGroup {
            filterParams += ", foodGroup: \(foodGroup)"
        }
        if let productCode = productCodeForAlternatives {
            filterParams += ", productIdForAlternatives: \(productCode)"
        }


        var whereConditions: [String] = []

        if let searchQuery = searchQuery {
            whereConditions.append("productName: { startsWith: \"\(searchQuery)\" }")
        }

        // Handle multiple nutrient conditions
        if let conditions = nutrientConditions, !conditions.isEmpty {
            for condition in conditions {
                var nutrientFilter = ""
                if let minValue = condition.minValue {
                    nutrientFilter = "\(condition.fieldName): { gte: \(minValue) }"
                } else if let maxValue = condition.maxValue {
                    nutrientFilter = "\(condition.fieldName): { lte: \(maxValue) }"
                }

                if !nutrientFilter.isEmpty {
                    whereConditions.append(nutrientFilter)
                }
            }
        } else if let fieldName = nutrientFieldName {
            var nutrientFilter = ""
            if let minValue = nutrientMinValue {
                nutrientFilter = "\(fieldName): { gte: \(minValue) }"
            } else if let maxValue = nutrientMaxValue {
                nutrientFilter = "\(fieldName): { lte: \(maxValue) }"
            }

            if !nutrientFilter.isEmpty {
                whereConditions.append(nutrientFilter)
            }
        }

        var whereClause = ""
        if !whereConditions.isEmpty {
            whereClause = ", where: { \(whereConditions.joined(separator: ", ")) }"
        }

        var orderParam = ""
        if sortAscending == true {
            orderParam = ", order: [{ nutriScore: ASC }]"
        }

        let queryString = """
            query Products {
            products(filter: { \(filterParams) }\(whereClause), \(paginationParams)\(orderParam)) {
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

        let response: ProductsQueryResponse = try await execute(query: queryString)

        let products = response.products.nodes.map { node in
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

        return ProductsResult(
            products: products,
            pageInfo: response.products.pageInfo
        )
    }

    func fetchProductByCode(code: String) async throws -> Product? {
        let queryString = """
            query ProductByCode {
                productByCode(code: "\(code)") {
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
            """

        let response: ProductByCodeResponse = try await execute(query: queryString)

        guard let node = response.productByCode else {
            return nil
        }

        return Product(
            code: node.code,
            name: node.productName,
            brand: node.productBrand,
            imageUrl: node.imageUrl,
            nutriScore: node.normalizedNutriScore,
            positiveNutrientRatings: node.positiveNutrientRatings,
            negativeNutrientRatings: node.negativeNutrientRatings,
            additivesRatings: node.additivesRatings
        )
    }
}
