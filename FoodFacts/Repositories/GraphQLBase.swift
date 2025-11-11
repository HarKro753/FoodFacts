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

struct ErrorCheckResponse: Decodable {
    let errors: [GraphQLError]?
}

// MARK: - GraphQL Client

class GraphQLClient {
    static let shared = GraphQLClient()
    let apiURL: URL

    private init() {
        self.apiURL = URL(string: "http://192.168.178.114:3004/graphql")!
    }

    func execute<T: Decodable>(query: String, variables: [String: String]? = nil, headers: [String: String]? = nil) async throws -> T {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add custom headers if provided
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        let body = GraphQLRequest(query: query, variables: variables)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw GraphQLClientError.invalidResponse
        }

        // Debug: Print raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📡 GraphQL Response: \(jsonString)")
        }

        let decoder = JSONDecoder()

        // First, check for GraphQL errors before attempting to decode the data
        // This prevents decoding errors when the server returns errors with null data
        let errorCheck = try decoder.decode(ErrorCheckResponse.self, from: data)
        if let errors = errorCheck.errors {
            print("❌ GraphQL Errors: \(errors.map { $0.message }.joined(separator: ", "))")
            throw GraphQLClientError.graphQLErrors(errors.map { $0.message })
        }

        // Now decode the full response (we know there are no errors)
        let graphQLResponse: GraphQLResponse<T>
        do {
            graphQLResponse = try decoder.decode(
                GraphQLResponse<T>.self,
                from: data
            )
        } catch {
            print("❌ Decoding error: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("   Missing key '\(key.stringValue)' - \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("   Type mismatch for type '\(type)' - \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("   Value not found for type '\(type)' - \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("   Data corrupted - \(context.debugDescription)")
                @unknown default:
                    print("   Unknown decoding error")
                }
            }
            throw error
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
