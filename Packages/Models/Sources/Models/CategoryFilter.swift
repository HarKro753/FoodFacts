//
//  CategoryFilter.swift
//  Models
//
//  Created by Harro Krog on 18.11.25.
//

import Foundation

public struct ProductLabel: Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let filter: CategoryFilter

    public init(id: Int, name: String, filter: CategoryFilter) {
        self.id = id
        self.name = name
        self.filter = filter
    }
}

public enum CategoryFilter: Hashable, Sendable {
    case label(id: Int)
    case category(id: Int)
    case foodGroup(id: Int)
    case nutrientMin(fieldName: String, minValue: Double)
    case nutrientMax(fieldName: String, maxValue: Double)
}

public enum ProductFilter: Hashable, Identifiable, CaseIterable {
    case lowCalorie
    case highProtein
    case highNutriScore
    case vegan
    case vegetarian

    public var id: String {
        switch self {
        case .lowCalorie: return "lowCalorie"
        case .highProtein: return "highProtein"
        case .highNutriScore: return "highNutriScore"
        case .vegan: return "vegan"
        case .vegetarian: return "vegetarian"
        }
    }

    public var displayName: String {
        switch self {
        case .lowCalorie: return "Low Calorie"
        case .highProtein: return "High Protein"
        case .highNutriScore: return "High Nutri Score"
        case .vegan: return "Vegan"
        case .vegetarian: return "Vegetarian"
        }
    }

    public var icon: String {
        switch self {
        case .lowCalorie: return "flame.fill"
        case .highProtein: return "figure.strengthtraining.traditional"
        case .highNutriScore: return "star.fill"
        case .vegan: return "leaf.fill"
        case .vegetarian: return "carrot.fill"
        }
    }
}
