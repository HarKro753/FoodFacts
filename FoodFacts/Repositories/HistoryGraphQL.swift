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
                product: nil
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
