//
//  FoodGroupsGraphQL.swift
//  FoodFacts
//
//  Created by Harro Krog on 17.11.25.
//

import Foundation

// MARK: - Food Groups Query Response Models

public struct FoodGroupsQueryResponse: Decodable {
    public let foodGroups: FoodGroupsData
}

public struct FoodGroupsData: Decodable {
    public let nodes: [FoodGroupNode]
}

public struct FoodGroupNode: Decodable {
    public let id: Int
    public let name: String
}

// MARK: - GraphQL Client Extension

@available(iOS 15.0, *)
extension GraphQLClient {
    public func fetchFoodGroups() async throws -> [FoodGroupNode] {
        let queryString = """
            query FoodGroups {
                foodGroups {
                    nodes {
                        id
                        name
                    }
                }
            }
            """

        let response: FoodGroupsQueryResponse = try await execute(
            query: queryString
        )
        return response.foodGroups.nodes
    }
}
