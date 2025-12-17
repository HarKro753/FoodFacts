//
//  SampleProduct.swift
//  Cibrus - Product Scanner
//
//  Created by Harro Krog on 29.11.25.
//


import Foundation
import SwiftUI

@available(iOS 13.0, *)
public extension Product {
    nonisolated(unsafe) static let sampleProducts: [Product] = [
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
