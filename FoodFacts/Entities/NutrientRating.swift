import Foundation
import SwiftUI

struct NutrientRating: Codable, Identifiable, Hashable {
    let id = UUID()
    let nutrientType: String
    let name: String
    let value: Double
    let unit: String
    let rating: String
    let text: String
    let ratingSections: [RatingSection]?

    enum CodingKeys: String, CodingKey {
        case nutrientType, name, value, unit, rating, text, ratingSections
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(nutrientType)
        hasher.combine(name)
        hasher.combine(value)
        hasher.combine(unit)
        hasher.combine(rating)
        hasher.combine(text)
        hasher.combine(ratingSections)
    }

    static func == (lhs: NutrientRating, rhs: NutrientRating) -> Bool {
        lhs.nutrientType == rhs.nutrientType &&
        lhs.name == rhs.name &&
        lhs.value == rhs.value &&
        lhs.unit == rhs.unit &&
        lhs.rating == rhs.rating &&
        lhs.text == rhs.text &&
        lhs.ratingSections == rhs.ratingSections
    }

    var ratingScore: Int {
        switch rating {
        case "VERY_GOOD":
            return 95
        case "GOOD":
            return 75
        case "MEDIUM":
            return 50
        case "BAD":
            return 25
        default:
            return 50
        }
    }

    var ratingColor: Color {
        switch rating {
        case "VERY_GOOD":
            return .green
        case "GOOD":
            return Color(red: 0.5, green: 0.8, blue: 0.3)
        case "MEDIUM":
            return .orange
        case "BAD":
            return .red
        default:
            return .gray
        }
    }

    var formattedValue: String {
        switch unit {
        case "GRAM":
            return String(format: "%.1fg", value)
        case "MILLIGRAM":
            return String(format: "%.0fmg", value)
        case "KILOCALORIE":
            return String(format: "%.0fkcal", value)
        default:
            return String(format: "%.1f%@", value, unit.lowercased())
        }
    }

    var icon: String {
        NutrientTypeMapper.icon(for: nutrientType)
    }
}



// MARK: - Nutrient Type to Icon Mapper

struct NutrientTypeMapper {
    static func icon(for nutrientType: String) -> String {
        switch nutrientType {
        // Positive nutrients
        case "FIBER":
            return "leaf.fill"
        case "PROTEIN", "PROTEINS":
            return "flame.fill"
        case "VITAMINS":
            return "star.fill"
        case "MINERALS":
            return "sparkles"

        // Negative nutrients
        case "SALT":
            return "cube.fill"
        case "SODIUM":
            return "drop.fill"
        case "ENERGY_KCAL", "ENERGY":
            return "bolt.fill"
        case "FAT":
            return "circle.fill"
        case "SATURATED_FAT":
            return "exclamationmark.circle.fill"
        case "CARBOHYDRATES", "CARBS":
            return "square.fill"
        case "SUGARS", "SUGAR":
            return "sparkle"
        case "ADDITIVES":
            return "exclamationmark.triangle.fill"
        case "PRESERVATIVES":
            return "flask.fill"

        default:
            return "circle"
        }
    }
}
