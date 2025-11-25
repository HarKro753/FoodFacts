//
//  ProductModels.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import Foundation
import SwiftUI

// MARK: - Product Models

struct Product: Codable, Identifiable, Hashable {
    let id: Int
    let name: String?
    let brand: String?
    let imageUrl: String?
    let nutriScore: Int?
    let positiveNutrientRatings: [NutrientRating]
    let negativeNutrientRatings: [NutrientRating]
    let additivesRatings: AdditiveRating?

    init(
        code: Int,
        name: String?,
        brand: String?,
        imageUrl: String?,
        nutriScore: Int?,
        positiveNutrientRatings: [NutrientRating],
        negativeNutrientRatings: [NutrientRating],
        additivesRatings: AdditiveRating? = nil
    ) {
        self.id = code
        self.name = name
        self.brand = brand
        self.imageUrl = imageUrl
        self.nutriScore = nutriScore
        self.positiveNutrientRatings = positiveNutrientRatings
        self.negativeNutrientRatings = negativeNutrientRatings
        self.additivesRatings = additivesRatings
    }

    var overallRatingText: String {
        guard let score = nutriScore else {
            return "Keine Bewertung"
        }

        switch score {
        case 80...100:
            return "Ausgezeichnet"
        case 60..<80:
            return "Gut"
        case 40..<60:
            return "Mittel"
        default:
            return "Schlecht"
        }
    }

    var ratingColor: Color {
        guard let score = nutriScore else {
            return .gray
        }

        switch score {
        case 80...100:
            return .green
        case 60..<80:
            return Color(red: 0.5, green: 0.8, blue: 0.3)
        case 40..<60:
            return .orange
        default:
            return .red
        }
    }
}

// Mark: Nutrient Rating

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
        case "PERCENTAGE":
            return String(format: "%.0f%%", value)
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
        // Basic Nutrients - Energy
        case "ENERGY_KCAL", "ENERGY":
            return "bolt.fill"
        case "ENERGY_FROM_FAT":
            return "bolt.circle.fill"

        // Fats
        case "FAT":
            return "circle.fill"
        case "SATURATED_FAT":
            return "exclamationmark.circle.fill"
        case "TRANS_FAT":
            return "exclamationmark.triangle.fill"
        case "UNSATURATED_FAT":
            return "circle.dotted"
        case "MONOUNSATURATED_FAT":
            return "circle.lefthalf.filled"
        case "POLYUNSATURATED_FAT":
            return "circle.righthalf.filled"
        case "OMEGA_3_FAT", "OMEGA3_FAT":
            return "drop.triangle.fill"
        case "OMEGA_6_FAT", "OMEGA6_FAT":
            return "drop.triangle"
        case "OMEGA_9_FAT", "OMEGA9_FAT":
            return "drop.circle.fill"

        // Essential Fatty Acids
        case "ALPHA_LINOLENIC_ACID":
            return "aqi.low"
        case "EICOSAPENTAENOIC_ACID":
            return "waveform.path.ecg"
        case "DOCOSAHEXAENOIC_ACID":
            return "waveform"
        case "LINOLEIC_ACID":
            return "aqi.medium"

        // Cholesterol
        case "CHOLESTEROL":
            return "heart.circle.fill"

        // Carbohydrates
        case "CARBOHYDRATES", "CARBS":
            return "square.fill"
        case "SUGARS", "SUGAR":
            return "sparkle"
        case "ADDED_SUGARS":
            return "plus.circle.fill"
        case "SUCROSE":
            return "square.grid.2x2.fill"
        case "GLUCOSE":
            return "square.circle.fill"
        case "FRUCTOSE":
            return "square.dotted"
        case "LACTOSE":
            return "square.lefthalf.filled"
        case "STARCH":
            return "square.stack.fill"

        // Fiber
        case "FIBER":
            return "leaf.fill"
        case "SOLUBLE_FIBER":
            return "leaf.circle.fill"
        case "INSOLUBLE_FIBER":
            return "leaf"

        // Proteins
        case "PROTEIN", "PROTEINS":
            return "flame.fill"

        // Salt & Sodium
        case "SALT":
            return "cube.fill"
        case "SODIUM":
            return "drop.fill"
        case "CHLORIDE":
            return "drop.circle"

        // Alcohol
        case "ALCOHOL":
            return "wineglass.fill"

        // Vitamins - Fat Soluble
        case "VITAMIN_A", "VITAMINA":
            return "sun.max.fill"
        case "VITAMIN_D", "VITAMIND":
            return "sun.min.fill"
        case "VITAMIN_E", "VITAMINE":
            return "shield.fill"
        case "VITAMIN_K", "VITAMINK":
            return "shield.lefthalf.filled"
        case "BETA_CAROTENE":
            return "sun.horizon.fill"

        // Vitamins - Water Soluble
        case "VITAMIN_C", "VITAMINC":
            return "star.fill"
        case "VITAMIN_B1", "VITAMINB1":
            return "star.circle.fill"
        case "VITAMIN_B2", "VITAMINB2":
            return "star.circle"
        case "VITAMIN_PP", "VITAMINPP":
            return "star.square.fill"
        case "VITAMIN_B6", "VITAMINB6":
            return "star.square"
        case "VITAMIN_B9", "VITAMINB9", "FOLATES":
            return "star.leadinghalf.filled"
        case "VITAMIN_B12", "VITAMINB12":
            return "star.slash.fill"
        case "BIOTIN":
            return "sparkles"
        case "PANTOTHENIC_ACID":
            return "star.bubble.fill"

        // Minerals - Major
        case "CALCIUM":
            return "cross.case.fill"
        case "PHOSPHORUS":
            return "diamond.fill"
        case "MAGNESIUM":
            return "hexagon.fill"
        case "POTASSIUM":
            return "bolt.heart.fill"

        // Minerals - Trace
        case "IRON":
            return "bolt.shield.fill"
        case "ZINC":
            return "shield.checkered"
        case "COPPER":
            return "circle.hexagonpath.fill"
        case "MANGANESE":
            return "hexagon"
        case "SELENIUM":
            return "shield.slash.fill"
        case "CHROMIUM":
            return "diamond"
        case "MOLYBDENUM":
            return "hexagon.lefthalf.filled"
        case "IODINE":
            return "drop.triangle.fill"

        // Fruits & Vegetables
        case "VEGETABLE_PERCANTAGE", "FRUITS_VEGETABLES_NUTS":
            return "carrot.fill"

        // Caffeine
        case "CAFFEINE":
            return "mug.fill"

        // Generic Categories
        case "VITAMINS":
            return "star.fill"
        case "MINERALS":
            return "sparkles"
        case "ADDITIVES":
            return "exclamationmark.triangle.fill"
        case "PRESERVATIVES":
            return "flask.fill"

        default:
            return "circle"
        }
    }
}

//MARK: RatingSection

struct RatingSection: Codable, Hashable {
    let rating: String
    let minValue: Double
    let maxValue: Double
    let description: String

    var color: Color {
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
}


//MARK: Additives

struct AdditiveRating: Codable, Hashable {
    let rating: String
    let description: String
    let numberOfAdditives: Int
    let additives: [Additive]
}

struct Additive: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let risk: String?
    let additiveTypeId: Int?
    let additiveType: AdditiveType?
    let additiveHealthRisks: [AdditiveHealthRiskRelation]?
}

struct AdditiveType: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String?
}

struct AdditiveHealthRiskRelation: Codable, Identifiable, Hashable {
    let additiveId: Int
    let healthRiskId: Int
    let healthRisk: HealthRisk

    var id: String { "\(additiveId)-\(healthRiskId)" }

    func hash(into hasher: inout Hasher) {
        hasher.combine(additiveId)
        hasher.combine(healthRiskId)
        hasher.combine(healthRisk)
    }

    static func == (lhs: AdditiveHealthRiskRelation, rhs: AdditiveHealthRiskRelation) -> Bool {
        lhs.additiveId == rhs.additiveId && lhs.healthRiskId == rhs.healthRiskId && lhs.healthRisk == rhs.healthRisk
    }
}

struct HealthRisk: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

// MARK: - Sample Data
extension Product {
    static let sampleProducts: [Product] = [
        Product(
            code: 1,
            name: "Organic Almond Milk",
            brand: "Nature's Best",
            imageUrl: nil,
            nutriScore: 85,
            positiveNutrientRatings: [
                NutrientRating(
                    nutrientType: "FIBER",
                    name: "Fiber",
                    value: 3.5,
                    unit: "GRAM",
                    rating: "VERY_GOOD",
                    text: "High fiber content",
                    ratingSections: nil
                ),
                NutrientRating(
                    nutrientType: "PROTEIN",
                    name: "Protein",
                    value: 2.0,
                    unit: "GRAM",
                    rating: "GOOD",
                    text: "Good protein source",
                    ratingSections: nil
                )
            ],
            negativeNutrientRatings: [
                NutrientRating(
                    nutrientType: "SUGAR",
                    name: "Sugars",
                    value: 1.5,
                    unit: "GRAM",
                    rating: "VERY_GOOD",
                    text: "Low sugar content",
                    ratingSections: nil
                )
            ]
        ),
        Product(
            code: 2,
            name: "Whole Grain Bread",
            brand: "Baker's Choice",
            imageUrl: nil,
            nutriScore: 72,
            positiveNutrientRatings: [
                NutrientRating(
                    nutrientType: "FIBER",
                    name: "Fiber",
                    value: 5.0,
                    unit: "GRAM",
                    rating: "VERY_GOOD",
                    text: "Excellent fiber content",
                    ratingSections: nil
                )
            ],
            negativeNutrientRatings: [
                NutrientRating(
                    nutrientType: "SALT",
                    name: "Salt",
                    value: 1.2,
                    unit: "GRAM",
                    rating: "MEDIUM",
                    text: "Moderate salt content",
                    ratingSections: nil
                )
            ]
        ),
        Product(
            code: 3,
            name: "Dark Chocolate",
            brand: "Cocoa Delights",
            imageUrl: nil,
            nutriScore: 45,
            positiveNutrientRatings: [],
            negativeNutrientRatings: [
                NutrientRating(
                    nutrientType: "SUGAR",
                    name: "Sugars",
                    value: 25.0,
                    unit: "GRAM",
                    rating: "BAD",
                    text: "High sugar content",
                    ratingSections: nil
                ),
                NutrientRating(
                    nutrientType: "SATURATED_FAT",
                    name: "Saturated Fat",
                    value: 8.0,
                    unit: "GRAM",
                    rating: "MEDIUM",
                    text: "Moderate saturated fat",
                    ratingSections: nil
                )
            ]
        )
    ]
}

