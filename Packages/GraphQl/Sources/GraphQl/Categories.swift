//
//  CategoryGraphQL.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import Foundation
import SwiftUI
import Models

// MARK: - Public Category Model

public struct CategoryNode: Decodable {
    public let id: Int
    public let name: String
}

// MARK: - GraphQL Client Extension

@available(iOS 15.0, *)
extension GraphQLClient {
    private struct CategoriesQueryResponse: Decodable {
        struct Categories: Decodable {
            let nodes: [CategoryNode]
            let pageInfo: PageInfo
        }
        let categories: Categories
    }

    public func fetchCategories() async throws -> PaginatedResult<CategoryNode> {
        let queryString = """
            query Categories {
                categories(first: 500) {
                    nodes {
                        name
                        id
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

        let response: CategoriesQueryResponse = try await execute(query: queryString)

        return PaginatedResult(
            items: response.categories.nodes,
            pageInfo: response.categories.pageInfo
        )
    }
}
