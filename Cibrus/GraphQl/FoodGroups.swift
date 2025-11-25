//
//  FoodGroupsGraphQL.swift
//  FoodFacts
//
//  Created by Harro Krog on 17.11.25.
//

import Foundation

// MARK: - Food Groups Query Response Models

struct FoodGroupsQueryResponse: Decodable {
    let foodGroups: FoodGroupsData
}

struct FoodGroupsData: Decodable {
    let nodes: [FoodGroupNode]
}

struct FoodGroupNode: Decodable {
    let id: Int
    let name: String
}

// MARK: - GraphQL Client Extension

extension GraphQLClient {
    func fetchFoodGroups() async throws -> [FoodGroupNode] {
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
        
        let response: FoodGroupsQueryResponse = try await execute(query: queryString)
        return response.foodGroups.nodes
    }
}
