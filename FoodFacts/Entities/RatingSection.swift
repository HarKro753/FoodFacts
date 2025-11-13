import SwiftUI
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
