//
//  GraphQLBase.swift
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

// MARK: - GraphQL Client

class GraphQLClient {
    static let shared = GraphQLClient()
    let apiURL: URL

    private init() {
        self.apiURL = URL(string: "http://localhost:3004/graphql")!
    }

    func execute<T: Decodable>(query: String, variables: [String: String]? = nil) async throws -> T {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GraphQLRequest(query: query, variables: variables)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw GraphQLClientError.invalidResponse
        }

        let graphQLResponse = try JSONDecoder().decode(
            GraphQLResponse<T>.self,
            from: data
        )

        if let errors = graphQLResponse.errors {
            throw GraphQLClientError.graphQLErrors(errors.map { $0.message })
        }

        guard let data = graphQLResponse.data else {
            throw GraphQLClientError.noData
        }

        return data
    }
}

// MARK: - GraphQL Client Error

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
