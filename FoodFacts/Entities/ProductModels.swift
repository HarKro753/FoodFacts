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
    let id: Int
    let name: String?
    let brand: String?
    let imageUrl: String?
    let nutriScore: Int?
    let positiveNutrientRatings: [NutrientRating]
    let negativeNutrientRatings: [NutrientRating]

    // Initializer for GraphQL response (generic to work with any GraphQL Product type)
    init(
        code: Int,
        name: String?,
        brand: String?,
        imageUrl: String?,
        nutriScore: Int?,
        positiveNutrientRatings: [NutrientRating],
        negativeNutrientRatings: [NutrientRating]
    ) {
        self.id = code
        self.name = name
        self.brand = brand
        self.imageUrl = imageUrl
        self.nutriScore = nutriScore
        self.positiveNutrientRatings = positiveNutrientRatings
        self.negativeNutrientRatings = negativeNutrientRatings
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

