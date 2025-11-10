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

struct ProductsData: Decodable {
    let nodes: [ProductNode]
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

struct ProductNode: Decodable {
    let code: Int
    let productName: String?
    let productBrand: String?
    let imageUrl: String?
    let normalizedNutriScore: Int?
    let positiveNutrientRatings: [NutrientRating]
    let negativeNutrientRatings: [NutrientRating]
}

// MARK: - GraphQL Client Extension

extension GraphQLClient {
    func fetchProducts(first: Int = 20, after: String? = nil, categoryId: Int? = nil, sortAscending: Bool? = nil) async throws -> ProductsResult {
        var paginationParams = "first: \(first)"
        if let after = after {
            paginationParams += ", after: \"\(after)\""
        }

        var filterParams = "completeness: 0.1, lastImageDatetime: \"2023-01-01\""
        if let categoryId = categoryId {
            filterParams += ", categoryId: \(categoryId)"
        }

        var orderParam = ""
        if sortAscending == true {
            orderParam = ", order: [{ nutriScore: ASC }]"
        }

        let queryString = """
            query Products {
            products(filter: { \(filterParams) }, \(paginationParams)\(orderParam)) {
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

    func searchProducts(query: String, first: Int = 20, after: String? = nil) async throws -> ProductsResult {
        var paginationParams = "first: \(first)"
        if let after = after {
            paginationParams += ", after: \"\(after)\""
        }

        let filterParams = "completeness: 0.1, lastImageDatetime: \"2023-01-01\""

        let queryString = """
            query SearchProducts {
            products(filter: { \(filterParams) }, where: { productName: { startsWith: "\(query)" } }, \(paginationParams)) {
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
}
