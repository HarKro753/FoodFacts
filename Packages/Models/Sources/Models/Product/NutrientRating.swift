import SwiftUI

@available(iOS 13.0, *)
public struct NutrientRating: Codable, Identifiable, Hashable {
    public let id = UUID()
    public let nutrientType: String
    public let name: String
    public let value: Double
    public let unit: String
    public let rating: String
    public let text: String
    public let ratingSections: [RatingSection]?

    // Derived properties
    public let ratingScore: Int
    public let ratingColor: Color
    public let formattedValue: String
    public var icon: String {
        NutrientTypeMapper.icon(for: nutrientType)
    }

    public enum CodingKeys: String, CodingKey {
        case nutrientType, name, value, unit, rating, text, ratingSections
    }

    public init(
        nutrientType: String,
        name: String,
        value: Double,
        unit: String,
        rating: String,
        text: String,
        ratingSections: [RatingSection]?
    ) {
        self.nutrientType = nutrientType
        self.name = name
        self.value = value
        self.unit = unit
        self.rating = rating
        self.text = text
        self.ratingSections = ratingSections

        // Use mappers and formatters
        self.ratingScore = RatingNumberMapper.score(for: rating)
        self.ratingColor = RatingColorMapper.color(for: rating)
        self.formattedValue = NutrientValueFormatter.formatValue(value, unit: unit)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.nutrientType = try container.decode(String.self, forKey: .nutrientType)
        self.name = try container.decode(String.self, forKey: .name)
        self.value = try container.decode(Double.self, forKey: .value)
        self.unit = try container.decode(String.self, forKey: .unit)
        self.rating = try container.decode(String.self, forKey: .rating)
        self.text = try container.decode(String.self, forKey: .text)
        self.ratingSections = try container.decodeIfPresent([RatingSection].self, forKey: .ratingSections)

        // Use mappers and formatters
        self.ratingScore = RatingNumberMapper.score(for: rating)
        self.ratingColor = RatingColorMapper.color(for: rating)
        self.formattedValue = NutrientValueFormatter.formatValue(value, unit: unit)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(nutrientType, forKey: .nutrientType)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
        try container.encode(unit, forKey: .unit)
        try container.encode(rating, forKey: .rating)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(ratingSections, forKey: .ratingSections)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(nutrientType)
        hasher.combine(name)
        hasher.combine(value)
        hasher.combine(unit)
        hasher.combine(rating)
        hasher.combine(text)
        hasher.combine(ratingSections)
    }

    public static func == (lhs: NutrientRating, rhs: NutrientRating) -> Bool {
        lhs.nutrientType == rhs.nutrientType &&
        lhs.name == rhs.name &&
        lhs.value == rhs.value &&
        lhs.unit == rhs.unit &&
        lhs.rating == rhs.rating &&
        lhs.text == rhs.text &&
        lhs.ratingSections == rhs.ratingSections
    }
}
