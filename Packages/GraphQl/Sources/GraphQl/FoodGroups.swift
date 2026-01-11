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
    private struct FoodGroupsQueryResponse: Decodable {
        struct FoodGroups: Decodable {
            let nodes: [FoodGroupNode]
            let pageInfo: PageInfo
        }
        let foodGroups: FoodGroups
    }

    public func fetchFoodGroups() async throws -> PaginatedResult<FoodGroupNode> {
        let queryString = """
            query FoodGroups {
                foodGroups {
                    nodes {
                        id
                        name
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

        let response: FoodGroupsQueryResponse = try await execute(
            query: queryString
        )

        return PaginatedResult(
            items: response.foodGroups.nodes,
            pageInfo: response.foodGroups.pageInfo
        )
    }
}
