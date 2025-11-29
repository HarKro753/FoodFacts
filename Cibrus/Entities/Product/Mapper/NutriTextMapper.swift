struct NutriTextMapper {
    static func text(for nutriScore: Int?) -> String {
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
}
