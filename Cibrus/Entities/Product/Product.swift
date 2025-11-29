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

    // Derived properties
    let overallRatingText: String
    let ratingColor: Color

    enum CodingKeys: String, CodingKey {
        case id = "code"
        case name, brand, imageUrl, nutriScore
        case positiveNutrientRatings, negativeNutrientRatings, additivesRatings
    }

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

        // Use mappers
        self.overallRatingText = NutriTextMapper.text(for: nutriScore)
        self.ratingColor = RatingColorMapper.color(for: nutriScore)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.brand = try container.decodeIfPresent(String.self, forKey: .brand)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.nutriScore = try container.decodeIfPresent(Int.self, forKey: .nutriScore)
        self.positiveNutrientRatings = try container.decode([NutrientRating].self, forKey: .positiveNutrientRatings)
        self.negativeNutrientRatings = try container.decode([NutrientRating].self, forKey: .negativeNutrientRatings)
        self.additivesRatings = try container.decodeIfPresent(AdditiveRating.self, forKey: .additivesRatings)

        // Use mappers
        self.overallRatingText = NutriTextMapper.text(for: nutriScore)
        self.ratingColor = RatingColorMapper.color(for: nutriScore)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(brand, forKey: .brand)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(nutriScore, forKey: .nutriScore)
        try container.encode(positiveNutrientRatings, forKey: .positiveNutrientRatings)
        try container.encode(negativeNutrientRatings, forKey: .negativeNutrientRatings)
        try container.encodeIfPresent(additivesRatings, forKey: .additivesRatings)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(brand)
        hasher.combine(imageUrl)
        hasher.combine(nutriScore)
        hasher.combine(positiveNutrientRatings)
        hasher.combine(negativeNutrientRatings)
        hasher.combine(additivesRatings)
    }

    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.brand == rhs.brand &&
        lhs.imageUrl == rhs.imageUrl &&
        lhs.nutriScore == rhs.nutriScore &&
        lhs.positiveNutrientRatings == rhs.positiveNutrientRatings &&
        lhs.negativeNutrientRatings == rhs.negativeNutrientRatings &&
        lhs.additivesRatings == rhs.additivesRatings
    }
}
