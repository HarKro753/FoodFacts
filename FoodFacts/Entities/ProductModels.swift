//
//  ProductModels.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import Foundation
import SwiftUI

// MARK: - Product Models

struct Product: Codable, Identifiable {
    let id: String
    let code: Int
    let name: String?
    let brand: String?
    let imageUrl: String?
    let positiveNutrientRatings: [NutrientRating]
    let negativeNutrientRatings: [NutrientRating]

    // Initializer for GraphQL response (generic to work with any GraphQL Product type)
    init(
        code: Int,
        name: String?,
        brand: String?,
        imageUrl: String?,
        positiveNutrientRatings: [NutrientRating],
        negativeNutrientRatings: [NutrientRating]
    ) {
        self.id = "\(code)"
        self.code = code
        self.name = name
        self.brand = brand
        self.imageUrl = imageUrl
        self.positiveNutrientRatings = positiveNutrientRatings
        self.negativeNutrientRatings = negativeNutrientRatings
    }

    var overallRating: Int {
        let positiveScore = positiveNutrientRatings.reduce(0) { sum, rating in
            sum + rating.ratingScore
        }
        let negativeScore = negativeNutrientRatings.reduce(0) { sum, rating in
            sum + (100 - rating.ratingScore)
        }

        let totalRatings =
            positiveNutrientRatings.count + negativeNutrientRatings.count
        guard totalRatings > 0 else { return 50 }

        return (positiveScore + negativeScore) / totalRatings
    }

    var overallRatingText: String {
        switch overallRating {
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
        switch overallRating {
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

struct NutrientRating: Codable, Identifiable {
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

    // Computed property that returns the value in the correct unit
    // API returns values in grams, but MILLIGRAM unit means we need to convert
    var actualValue: Double {
        switch unit {
        case "MILLIGRAM":
            return value * 1000  // Convert grams to milligrams
        default:
            return value
        }
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
            return String(format: "%.1fg", actualValue)
        case "MILLIGRAM":
            return String(format: "%.0fmg", actualValue)
        case "KILOCALORIE":
            return String(format: "%.0fkcal", actualValue)
        default:
            return String(format: "%.1f%@", actualValue, unit.lowercased())
        }
    }

    var icon: String {
        NutrientTypeMapper.icon(for: nutrientType)
    }
}

struct RatingSection: Codable {
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

// MARK: - Sample Data

extension Product {
    static let sampleProduct = Product(
        code: 984904,
        name: "Sample Product",
        brand: "Sample Brand",
        imageUrl: nil,
        positiveNutrientRatings: [
            NutrientRating(
                nutrientType: "SALT",
                name: "Salt",
                value: 0.65,
                unit: "GRAM",
                rating: "GOOD",
                text: "Low salt",
                ratingSections: [
                    RatingSection(
                        rating: "VERY_GOOD",
                        minValue: 0,
                        maxValue: 0.3,
                        description: "Very low salt"
                    ),
                    RatingSection(
                        rating: "GOOD",
                        minValue: 0.3,
                        maxValue: 0.9,
                        description: "Low salt"
                    ),
                    RatingSection(
                        rating: "MEDIUM",
                        minValue: 0.9,
                        maxValue: 1.5,
                        description: "Moderate salt"
                    ),
                    RatingSection(
                        rating: "BAD",
                        minValue: 1.5,
                        maxValue: 7.922816251426434e+28,
                        description: "High salt"
                    ),
                ]
            ),
            NutrientRating(
                nutrientType: "SODIUM",
                name: "Sodium",
                value: 0.26,
                unit: "MILLIGRAM",
                rating: "VERY_GOOD",
                text: "Very low sodium",
                ratingSections: [
                    RatingSection(
                        rating: "VERY_GOOD",
                        minValue: 0,
                        maxValue: 120,
                        description: "Very low sodium"
                    ),
                    RatingSection(
                        rating: "GOOD",
                        minValue: 120,
                        maxValue: 360,
                        description: "Low sodium"
                    ),
                    RatingSection(
                        rating: "MEDIUM",
                        minValue: 360,
                        maxValue: 600,
                        description: "Moderate sodium"
                    ),
                    RatingSection(
                        rating: "BAD",
                        minValue: 600,
                        maxValue: 7.922816251426434e+28,
                        description: "High sodium"
                    ),
                ]
            ),
        ],
        negativeNutrientRatings: [
            NutrientRating(
                nutrientType: "ENERGY_KCAL",
                name: "Energy",
                value: 490,
                unit: "KILOCALORIE",
                rating: "MEDIUM",
                text: "Moderate calorie",
                ratingSections: nil
            ),
            NutrientRating(
                nutrientType: "FAT",
                name: "Fat",
                value: 23.6,
                unit: "GRAM",
                rating: "BAD",
                text: "High fat",
                ratingSections: nil
            ),
            NutrientRating(
                nutrientType: "SATURATED_FAT",
                name: "Saturated Fat",
                value: 13.8,
                unit: "GRAM",
                rating: "BAD",
                text: "High saturated fat",
                ratingSections: nil
            ),
            NutrientRating(
                nutrientType: "CARBOHYDRATES",
                name: "Carbohydrates",
                value: 62.6,
                unit: "GRAM",
                rating: "BAD",
                text: "High carb",
                ratingSections: nil
            ),
            NutrientRating(
                nutrientType: "SUGARS",
                name: "Sugars",
                value: 35.9,
                unit: "GRAM",
                rating: "BAD",
                text: "High sugar",
                ratingSections: nil
            ),
            NutrientRating(
                nutrientType: "PROTEINS",
                name: "Protein",
                value: 5.8,
                unit: "GRAM",
                rating: "MEDIUM",
                text: "Moderate protein",
                ratingSections: nil
            ),
        ]
    )

    static let sampleProducts: [Product] = [
        sampleProduct,
        Product(
            code: 123456,
            name: "Organic Yogurt",
            brand: "Natural Foods",
            imageUrl: nil,
            positiveNutrientRatings: [
                NutrientRating(
                    nutrientType: "PROTEINS",
                    name: "Protein",
                    value: 8.5,
                    unit: "GRAM",
                    rating: "GOOD",
                    text: "Good protein",
                    ratingSections: nil
                ),
                NutrientRating(
                    nutrientType: "SALT",
                    name: "Salt",
                    value: 0.2,
                    unit: "GRAM",
                    rating: "VERY_GOOD",
                    text: "Very low salt",
                    ratingSections: nil
                ),
            ],
            negativeNutrientRatings: [
                NutrientRating(
                    nutrientType: "SUGARS",
                    name: "Sugars",
                    value: 12.3,
                    unit: "GRAM",
                    rating: "MEDIUM",
                    text: "Moderate sugar",
                    ratingSections: nil
                ),
                NutrientRating(
                    nutrientType: "FAT",
                    name: "Fat",
                    value: 3.2,
                    unit: "GRAM",
                    rating: "GOOD",
                    text: "Low fat",
                    ratingSections: nil
                ),
            ]
        ),
        Product(
            code: 789012,
            name: "Whole Grain Bread",
            brand: "Artisan Bakery",
            imageUrl: nil,
            positiveNutrientRatings: [
                NutrientRating(
                    nutrientType: "FIBER",
                    name: "Fiber",
                    value: 6.5,
                    unit: "GRAM",
                    rating: "VERY_GOOD",
                    text: "High fiber",
                    ratingSections: nil
                )
            ],
            negativeNutrientRatings: [
                NutrientRating(
                    nutrientType: "SALT",
                    name: "Salt",
                    value: 1.8,
                    unit: "GRAM",
                    rating: "BAD",
                    text: "High salt",
                    ratingSections: nil
                ),
                NutrientRating(
                    nutrientType: "CARBOHYDRATES",
                    name: "Carbohydrates",
                    value: 45.2,
                    unit: "GRAM",
                    rating: "MEDIUM",
                    text: "Moderate carb",
                    ratingSections: nil
                ),
            ]
        ),
    ]
}
