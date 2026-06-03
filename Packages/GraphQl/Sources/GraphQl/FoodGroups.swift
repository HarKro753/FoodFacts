//
//  FoodGroupsGraphQL.swift
//  FoodFacts
//
//  Created by Harro Krog on 17.11.25.
//

import Foundation
import Models

// MARK: - Public Food Group Model

public struct FoodGroupNode: Decodable {
    public let id: Int
    public let name: String
}

// MARK: - GraphQL Client Extension

@available(iOS 15.0, *)
extension GraphQLClient {
    public func fetchFoodGroups() async throws -> PaginatedResult<FoodGroupNode> {
        MockGraphQLStore.shared.fetchFoodGroups()
    }
}
