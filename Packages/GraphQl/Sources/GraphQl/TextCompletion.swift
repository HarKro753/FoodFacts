import Foundation
import SwiftUI

// MARK: - Public Completion Models

public struct CompletionItem: Decodable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String
}

public struct CompletionsData: Decodable, Equatable {
    public let productNames: [CompletionItem]
    public let categoryNames: [CompletionItem]
    public let foodGroups: [CompletionItem]
}

// MARK: - GraphQL Client Extension

@available(iOS 15.0, *)
extension GraphQLClient {
    private struct CompletionsWrapper: Decodable {
        let completionsForPrefix: CompletionsData
    }

    public func fetchCompletions(
        prefix: String,
        completeness: Double? = 0.7,
        lastImageDatetime: String? = "2025-01-01",
        removeNoNutriScore: Bool? = true
    ) async throws -> CompletionsData {
        var filterParams: [String] = []

        if let completeness = completeness {
            filterParams.append("completeness: \(completeness)")
        }
        if let lastImageDatetime = lastImageDatetime {
            filterParams.append("lastImageDatetime: \"\(lastImageDatetime)\"")
        }
        if let removeNoNutriScore = removeNoNutriScore {
            filterParams.append("removeNoNutriScore: \(removeNoNutriScore)")
        }

        let filterString = filterParams.isEmpty ? "" : ", filter: { \(filterParams.joined(separator: ", ")) }"

        let queryString = """
            query CompletionsForPrefix {
                completionsForPrefix(prefix: "\(prefix)"\(filterString)) {
                    productNames {
                        id
                        name
                    }
                    categoryNames {
                        id
                        name
                    }
                    foodGroups {
                        id
                        name
                    }
                }
            }
            """

        let response: CompletionsWrapper = try await execute(query: queryString)

        return response.completionsForPrefix
    }
}

// Sample Response:
// {
//     "data": {
//         "completionsForPrefix": {
//             "productNames": [
//                 {
//                     "id": 2625400031829,
//                     "name": "Choc"
//                 },
//                 {
//                     "id": 6006323700034,
//                     "name": "Choc  Caramel sandwich biscuits"
//                 },
//                 {
//                     "id": 6009614342845,
//                     "name": "Choc  macadamia energy bar"
//                 },
//                 {
//                     "id": 4061445110453,
//                     "name": "Choc & Blueberry"
//                 },
//                 {
//                     "id": 3700569009502,
//                     "name": "Choc & Boost"
//                 },
//                 {
//                     "id": 72417200878,
//                     "name": "Choc & Caramel Cookies"
//                 },
//                 {
//                     "id": 5054795185492,
//                     "name": "Choc & Caramel Spread"
//                 },
//                 {
//                     "id": 5060426813399,
//                     "name": "Choc & Caramel Yoghurt"
//                 },
//                 {
//                     "id": 4400000167,
//                     "name": "Choc & Choc"
//                 },
//                 {
//                     "id": 5052319332414,
//                     "name": "Choc & Crispie Bar"
//                 }
//             ],
//             "categoryNames": [
//                 {
//                     "id": 1042008,
//                     "name": "Choc"
//                 },
//                 {
//                     "id": 1075632,
//                     "name": "Choc-and-nut-granola"
//                 },
//                 {
//                     "id": 509931,
//                     "name": "Choc-biscuits"
//                 },
//                 {
//                     "id": 1192058,
//                     "name": "Choc-cherry-granola"
//                 },
//                 {
//                     "id": 1243263,
//                     "name": "Choc-chips"
//                 },
//                 {
//                     "id": 1730062,
//                     "name": "Choc-malt-drink"
//                 },
//                 {
//                     "id": 1559836,
//                     "name": "Choc-pot"
//                 },
//                 {
//                     "id": 1082987,
//                     "name": "Choc-pots"
//                 },
//                 {
//                     "id": 1522993,
//                     "name": "Chocalate"
//                 },
//                 {
//                     "id": 1169091,
//                     "name": "Choch"
//                 }
//             ],
//             "foodGroups": [
//                 {
//                     "id": 28,
//                     "name": "Chocolate products"
//                 }
//             ]
//         }
//     }
// }
