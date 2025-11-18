//
//  CategoryFilter.swift
//  FoodFacts
//
//  Created by Harro Krog on 18.11.25.
//

enum CategoryFilter: Hashable {
    case label(id: Int)
    case category(id: Int)
    case foodGroup(id: Int)
    case nutrientMin(fieldName: String, minValue: Double)
    case nutrientMax(fieldName: String, maxValue: Double)

    // Generic method to fetch products for any filter type
    func fetchProducts(
        first: Int = 20,
        after: String? = nil,
        labelIds: [Int]? = nil,
        nutrientConditions: [(String, Double?, Double?)]? = nil,
        sortAscending: Bool? = nil
    ) async throws -> ProductsResult {
        switch self {
        case .label(let id):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelId: id,
                labelIds: labelIds,
                sortAscending: sortAscending,
                nutrientConditions: nutrientConditions
            )

        case .category(let id):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                categoryId: id,
                labelIds: labelIds,
                sortAscending: sortAscending,
                nutrientConditions: nutrientConditions
            )

        case .foodGroup(let id):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelIds: labelIds,
                foodGroup: id,
                sortAscending: sortAscending,
                nutrientConditions: nutrientConditions
            )

        case .nutrientMin(let fieldName, let minValue):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelIds: labelIds,
                sortAscending: sortAscending,
                nutrientFieldName: fieldName,
                nutrientMinValue: minValue,
                nutrientConditions: nutrientConditions
            )

        case .nutrientMax(let fieldName, let maxValue):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelIds: labelIds,
                sortAscending: sortAscending,
                nutrientFieldName: fieldName,
                nutrientMaxValue: maxValue,
                nutrientConditions: nutrientConditions
            )
        }
    }
}

enum ProductFilter: Hashable, Identifiable, CaseIterable {
    case lowCalorie
    case highProtein
    case highNutriScore
    case vegan
    case vegetarian

    var id: String {
        switch self {
        case .lowCalorie: return "lowCalorie"
        case .highProtein: return "highProtein"
        case .highNutriScore: return "highNutriScore"
        case .vegan: return "vegan"
        case .vegetarian: return "vegetarian"
        }
    }

    var displayName: String {
        switch self {
        case .lowCalorie: return "Low Calorie"
        case .highProtein: return "High Protein"
        case .highNutriScore: return "High Nutri Score"
        case .vegan: return "Vegan"
        case .vegetarian: return "Vegetarian"
        }
    }

    var icon: String {
        switch self {
        case .lowCalorie: return "flame.fill"
        case .highProtein: return "figure.strengthtraining.traditional"
        case .highNutriScore: return "star.fill"
        case .vegan: return "leaf.fill"
        case .vegetarian: return "carrot.fill"
        }
    }
}


