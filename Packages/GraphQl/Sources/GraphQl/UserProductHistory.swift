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
    public static let userId = "1"
    public static let username = "mock_user"

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
    public func fetchProductHistory(
        first: Int = 20,
        after: String? = nil
    ) async throws -> PaginatedResult<ProductHistory> {
        MockGraphQLStore.shared.fetchProductHistory(first: first, after: after)
    }

    public func addProductHistoryItem(productCode: Int) async throws -> AddProductHistoryItemPayload {
        MockGraphQLStore.shared.addProductHistoryItem(productCode: productCode)
    }

    public func removeProductHistoryItem(historyId: Int) async throws -> RemoveProductHistoryItemPayload {
        MockGraphQLStore.shared.removeProductHistoryItem(historyId: historyId)
    }
}
