//
//  AdditiveDetailView.swift
//  FoodFacts
//
//  Created by Claude on 13.11.25.
//

import SwiftUI
import Models

struct AdditiveDetailView: View {
    let additive: Additive

    private var riskColor: Color {
        colorForRisk(additive.risk ?? "UNKNOWN")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with risk rating
                VStack(alignment: .leading, spacing: 12) {
                    Text(additive.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack(spacing: 8) {
                        Circle()
                            .fill(riskColor)
                            .frame(width: 12, height: 12)

                        Text(riskText(for: additive.risk ?? "UNKNOWN"))
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 8)

                // Description
                if let description = additive.description {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Beschreibung")
                            .font(.system(size: 18, weight: .semibold))

                        Text(description)
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                }

                // Additive Type
                if let additiveType = additive.additiveType {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kategorie")
                            .font(.system(size: 18, weight: .semibold))

                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundStyle(.blue)

                            Text(additiveType.name)
                                .font(.system(size: 15))
                                .foregroundStyle(.primary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)

                        if let typeDescription = additiveType.description {
                            Text(typeDescription)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                    }
                }

                // Health Risks
                if let healthRisks = additive.additiveHealthRisks, !healthRisks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gesundheitsrisiken")
                            .font(.system(size: 18, weight: .semibold))

                        VStack(spacing: 8) {
                            ForEach(healthRisks) { relation in
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.orange)
                                        .font(.system(size: 14))

                                    Text(relation.healthRisk.name)
                                        .font(.system(size: 15))
                                        .foregroundStyle(.primary)

                                    Spacer()
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                            }
                        }
                    }
                }

                // Risk Level Explanation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Risikostufe")
                        .font(.system(size: 18, weight: .semibold))

                    HStack(spacing: 12) {
                        Circle()
                            .fill(riskColor)
                            .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(riskText(for: additive.risk ?? "UNKNOWN"))
                                .font(.system(size: 16, weight: .medium))

                            Text(riskExplanation(for: additive.risk ?? "UNKNOWN"))
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Zusatzstoff Details")
        .navigationBarTitleDisplayMode(.inline)
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

    private func riskExplanation(for risk: String) -> String {
        switch risk {
        case "NO_RISK":
            return "Dieser Zusatzstoff gilt als unbedenklich und stellt kein bekanntes Gesundheitsrisiko dar."
        case "LOW_RISK":
            return "Dieser Zusatzstoff ist weitgehend unbedenklich, kann aber bei empfindlichen Personen Reaktionen hervorrufen."
        case "MODERATE_RISK":
            return "Dieser Zusatzstoff sollte in Maßen konsumiert werden. Bei regelmäßigem Verzehr können gesundheitliche Bedenken bestehen."
        case "HIGH_RISK":
            return "Dieser Zusatzstoff steht im Verdacht, gesundheitliche Probleme zu verursachen und sollte nach Möglichkeit vermieden werden."
        default:
            return "Keine Informationen über das Risiko dieses Zusatzstoffs verfügbar."
        }
    }
}
