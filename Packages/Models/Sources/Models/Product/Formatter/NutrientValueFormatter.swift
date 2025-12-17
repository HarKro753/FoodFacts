import Foundation
public struct NutrientValueFormatter {
    public static func formatValue(_ value: Double, unit: String) -> String {
        switch unit {
        case "GRAM":
            return String(format: "%.1fg", value)
        case "MILLIGRAM":
            return String(format: "%.0fmg", value)
        case "KILOCALORIE":
            return String(format: "%.0fkcal", value)
        case "PERCENTAGE":
            return String(format: "%.0f%%", value)
        default:
            return String(format: "%.1f%@", value, unit.lowercased())
        }
    }
}
