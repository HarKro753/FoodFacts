//
//  AdditivesRatingRowsView.swift
//  FoodFacts
//
//  Created by Claude on 13.11.25.
//

import SwiftUI
import Models

struct AdditivesRatingRowsView: View {
    let additives: [Additive]

    private var groupedByRating: [(rating: String, count: Int, color: Color)] {
        let grouped = Dictionary(grouping: additives) { $0.risk ?? "UNKNOWN" }
        let ratings: [(String, Int)] = [
            ("NO_RISK", grouped["NO_RISK"]?.count ?? 0),
            ("LOW_RISK", grouped["LOW_RISK"]?.count ?? 0),
            ("MODERATE_RISK", grouped["MODERATE_RISK"]?.count ?? 0),
            ("HIGH_RISK", grouped["HIGH_RISK"]?.count ?? 0)
        ]

        return ratings
            .filter { $0.1 > 0 }
            .map { (rating: $0.0, count: $0.1, color: colorForRisk($0.0)) }
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(groupedByRating, id: \.rating) { item in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 24, height: 24)

                        Text("\(item.count)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Text(ratingText(for: item.rating))
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)

                    Spacer()
                }
            }
        }
    }

    private func colorForRisk(_ risk: String) -> Color {
        switch risk {
        case "NO_RISK":
            return .green
        case "LOW_RISK":
            return Color(red: 0.5, green: 0.8, blue: 0.3)
        case "MODERATE_RISK":
            return .orange
        case "HIGH_RISK":
            return .red
        default:
            return .gray
        }
    }

    private func ratingText(for risk: String) -> String {
        switch risk {
        case "NO_RISK":
            return "Kein Risiko"
        case "LOW_RISK":
            return "Geringes Risiko"
        case "MODERATE_RISK":
            return "Mittleres Risiko"
        case "HIGH_RISK":
            return "Hohes Risiko"
        default:
            return "Unbekannt"
        }
    }
}

#Preview {
    AdditivesRatingRowsView(
        additives: [
            Additive(
                id: 1,
                name: "E102",
                description: nil,
                risk: "MODERATE_RISK",
                additiveTypeId: nil,
                additiveType: nil,
                additiveHealthRisks: nil
            ),
            Additive(
                id: 2,
                name: "E211",
                description: nil,
                risk: "LOW_RISK",
                additiveTypeId: nil,
                additiveType: nil,
                additiveHealthRisks: nil
            ),
            Additive(
                id: 3,
                name: "E621",
                description: nil,
                risk: "MODERATE_RISK",
                additiveTypeId: nil,
                additiveType: nil,
                additiveHealthRisks: nil
            ),
            Additive(
                id: 4,
                name: "E300",
                description: nil,
                risk: "NO_RISK",
                additiveTypeId: nil,
                additiveType: nil,
                additiveHealthRisks: nil
            ),
            Additive(
                id: 5,
                name: "E150",
                description: nil,
                risk: "HIGH_RISK",
                additiveTypeId: nil,
                additiveType: nil,
                additiveHealthRisks: nil
            )
        ]
    )
    .padding()
}
