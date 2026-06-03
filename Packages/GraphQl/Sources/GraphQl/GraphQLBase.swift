//
//  GraphQLBase.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import Foundation

// MARK: - GraphQL Request/Response

public struct GraphQLRequest: Encodable {
    let query: String
    let variables: [String: String]?
}

public struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLError]?
}

public struct GraphQLError: Decodable {
    let message: String
}

public struct ErrorCheckResponse: Decodable {
    let errors: [GraphQLError]?
}

// MARK: - GraphQL Client

@available(iOS 15.0, *)
public final class GraphQLClient: @unchecked Sendable {
    public static let shared = GraphQLClient()
    public static let usesLocalMockData = true

    private static let accessTokenKey = "accessToken"
    private nonisolated(unsafe) static let sharedDefaults = UserDefaults(suiteName: "group.cibrusapp")

    private var currentToken: String? {
        Self.sharedDefaults?.string(forKey: Self.accessTokenKey)
    }

    private init() {}

    public func execute<T: Decodable>(
        query: String,
        variables: [String: String]? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        _ = currentToken
        _ = query
        _ = variables
        _ = headers
        throw GraphQLClientError.mockExecuteUnsupported
    }
}

// MARK: - GraphQL Client Error

public enum GraphQLClientError: LocalizedError {
    case queryNotFound
    case invalidResponse
    case noData
    case graphQLErrors([String])
    case mockExecuteUnsupported

    public var errorDescription: String? {
        switch self {
        case .queryNotFound:
            return "GraphQL query file not found"
        case .invalidResponse:
            return "Invalid server response"
        case .noData:
            return "No data received from server"
        case .graphQLErrors(let errors):
            return "GraphQL errors: \(errors.joined(separator: ", "))"
        case .mockExecuteUnsupported:
            return "Raw GraphQL execution is unavailable in local mock mode"
        }
    }
}
