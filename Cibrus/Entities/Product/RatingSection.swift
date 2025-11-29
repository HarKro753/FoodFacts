//
//  RatingSection.swift
//  Cibrus - Product Scanner
//
//  Created by Harro Krog on 29.11.25.
//

import Foundation
import SwiftUI

struct RatingSection: Codable, Hashable {
    let rating: String
    let minValue: Double
    let maxValue: Double
    let description: String

    // Derived property
    let color: Color

    enum CodingKeys: String, CodingKey {
        case rating, minValue, maxValue, description
    }

    init(
        rating: String,
        minValue: Double,
        maxValue: Double,
        description: String
    ) {
        self.rating = rating
        self.minValue = minValue
        self.maxValue = maxValue
        self.description = description

        // Use mapper
        self.color = RatingColorMapper.color(for: rating)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.rating = try container.decode(String.self, forKey: .rating)
        self.minValue = try container.decode(Double.self, forKey: .minValue)
        self.maxValue = try container.decode(Double.self, forKey: .maxValue)
        self.description = try container.decode(String.self, forKey: .description)

        // Use mapper
        self.color = RatingColorMapper.color(for: rating)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(rating, forKey: .rating)
        try container.encode(minValue, forKey: .minValue)
        try container.encode(maxValue, forKey: .maxValue)
        try container.encode(description, forKey: .description)
    }
}
