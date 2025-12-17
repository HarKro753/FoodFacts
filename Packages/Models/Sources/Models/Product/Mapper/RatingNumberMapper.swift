public struct RatingNumberMapper {
    public static func score(for rating: String) -> Int {
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
}
