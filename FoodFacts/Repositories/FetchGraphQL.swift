//
//  FetchGraphQL.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import Foundation

// MARK: - GraphQL Request/Response

struct GraphQLRequest: Encodable {
    let query: String
    let variables: [String: String]?
}

struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLError]?
}

struct GraphQLError: Decodable {
    let message: String
}

// MARK: - Products Query Response Models

struct ProductsQueryResponse: Decodable {
    let products: ProductsData
}

struct ProductsData: Decodable {
    let nodes: [ProductNode]
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

// MARK: - GraphQL Client

class GraphQLClient {
    static let shared = GraphQLClient()
    private let apiURL: URL

    private init() {
        // TODO: Replace with your actual GraphQL endpoint
        self.apiURL = URL(string: "http://localhost:3004/graphql")!
    }

    func fetchProducts() async throws -> [Product] {
        // Read the GraphQL query from the file
        let queryString = """
            query Products {
            products(filter: { completeness: 0.9, lastImageDatetime: "2025-01-01" }) {
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
            }
            }
            """

        // Create the request
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GraphQLRequest(query: queryString, variables: nil)
        request.httpBody = try JSONEncoder().encode(body)

        // Fetch data
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw GraphQLClientError.invalidResponse
        }

        let graphQLResponse = try JSONDecoder().decode(
            GraphQLResponse<ProductsQueryResponse>.self,
            from: data
        )

        if let errors = graphQLResponse.errors {
            throw GraphQLClientError.graphQLErrors(errors.map { $0.message })
        }

        guard let productsData = graphQLResponse.data else {
            throw GraphQLClientError.noData
        }

        // Convert ProductNode to Product
        return productsData.products.nodes.map { node in
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
    }
}

enum GraphQLClientError: LocalizedError {
    case queryNotFound
    case invalidResponse
    case noData
    case graphQLErrors([String])

    var errorDescription: String? {
        switch self {
        case .queryNotFound:
            return "GraphQL query file not found"
        case .invalidResponse:
            return "Invalid server response"
        case .noData:
            return "No data received from server"
        case .graphQLErrors(let errors):
            return "GraphQL errors: \(errors.joined(separator: ", "))"
        }
    }
}
