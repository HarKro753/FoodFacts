import SwiftUI

struct RatingColorMapper {
    static func color(for score: Int?) -> Color {
        guard let score = score else {
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

    static func color(for rating: String) -> Color {
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
