//
//  AdditivesListSheet.swift
//  FoodFacts
//
//  Created by Claude on 13.11.25.
//

import SwiftUI
import Models

struct AdditivesListSheet: View {
    let additives: [Additive]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(additives) { additive in
                    NavigationLink(destination: AdditiveDetailView(additive: additive)) {
                        AdditiveListRow(additive: additive)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Zusatzstoffe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AdditiveListRow: View {
    let additive: Additive

    private var riskColor: Color {
        colorForRisk(additive.risk ?? "UNKNOWN")
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(riskColor)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "flask.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(additive.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    if let additiveType = additive.additiveType {
                        Text(additiveType.name)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }

                    if additive.additiveType != nil && additive.risk != nil {
                        Text("•")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }

                    if additive.risk != nil {
                        Text(riskText(for: additive.risk!))
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.gray)
        }
        .padding(.vertical, 4)
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

    private func riskText(for risk: String) -> String {
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
    AdditivesListSheet(
        additives: [
            Additive(
                id: 1,
                name: "E102 - Tartrazin",
                description: "Ein synthetischer Azofarbstoff",
                risk: "MODERATE_RISK",
                additiveTypeId: 1,
                additiveType: AdditiveType(
                    id: 1,
                    name: "Farbstoff",
                    description: nil
                ),
                additiveHealthRisks: nil
            ),
            Additive(
                id: 2,
                name: "E211 - Natriumbenzoat",
                description: "Konservierungsmittel",
                risk: "LOW_RISK",
                additiveTypeId: 2,
                additiveType: AdditiveType(
                    id: 2,
                    name: "Konservierungsmittel",
                    description: nil
                ),
                additiveHealthRisks: nil
            ),
            Additive(
                id: 3,
                name: "E621 - Mononatriumglutamat",
                description: "Geschmacksverstärker",
                risk: "MODERATE_RISK",
                additiveTypeId: 3,
                additiveType: AdditiveType(
                    id: 3,
                    name: "Geschmacksverstärker",
                    description: nil
                ),
                additiveHealthRisks: nil
            ),
            Additive(
                id: 4,
                name: "E300 - Ascorbinsäure",
                description: "Vitamin C",
                risk: "NO_RISK",
                additiveTypeId: 4,
                additiveType: AdditiveType(
                    id: 4,
                    name: "Antioxidans",
                    description: nil
                ),
                additiveHealthRisks: nil
            ),
            Additive(
                id: 5,
                name: "E150 - Zuckerkulör",
                description: "Farbstoff aus Zucker",
                risk: "HIGH_RISK",
                additiveTypeId: 1,
                additiveType: AdditiveType(
                    id: 1,
                    name: "Farbstoff",
                    description: nil
                ),
                additiveHealthRisks: nil
            )
        ]
    )
}
