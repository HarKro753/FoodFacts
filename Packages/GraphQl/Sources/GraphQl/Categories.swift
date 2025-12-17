//
//  CategoryGraphQL.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import Foundation
import SwiftUI

// MARK: - Categories Query Response Models

public struct CategoriesQueryResponse: Decodable {
    public let categories: CategoriesData
}

public struct CategoriesData: Decodable {
    public let nodes: [CategoryNode]
}

public struct CategoryNode: Decodable {
    public let id: Int
    public let name: String
}

// MARK: - GraphQL Client Extension

@available(iOS 15.0, *)
extension GraphQLClient {
    public func fetchCategories() async throws -> [CategoryNode] {
        let queryString = """
            query Categories {
                categories(first: 500) {
                    nodes {
                        name
                        id
                    }
                }
            }
            """

        let response: CategoriesQueryResponse = try await execute(query: queryString)

        return response.categories.nodes
    }
}
