//
//  CategoryGraphQL.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import Foundation
import SwiftUI

// MARK: - Categories Query Response Models

struct CategoriesQueryResponse: Decodable {
    let categories: CategoriesData
}

struct CategoriesData: Decodable {
    let nodes: [CategoryNode]
}

struct CategoryNode: Decodable {
    let id: Int
    let name: String
}

// MARK: - GraphQL Client Extension

extension GraphQLClient {
    func fetchCategories() async throws -> [CategoryNode] {
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
