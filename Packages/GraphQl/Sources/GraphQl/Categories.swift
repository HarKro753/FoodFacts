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
    public func fetchCategories() async throws -> PaginatedResult<CategoryNode> {
        MockGraphQLStore.shared.fetchCategories()
    }
}
