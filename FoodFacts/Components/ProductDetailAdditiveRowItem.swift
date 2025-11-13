//
//  ProductDetailAdditiveRowItem.swift
//  FoodFacts
//
//  Created by Claude on 13.11.25.
//

import SwiftUI

struct ProductDetailAdditiveRowItem: View {
    let additivesRating: AdditiveRating
    @Binding var showAdditivesSheet: Bool

    @State private var isExpanded = false

    private var ratingColor: Color {
        colorForRating(additivesRating.rating)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "flask.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.gray)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Zusatzstoffe")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)

                        Text(additivesRating.description)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Text("\(additivesRating.numberOfAdditives)")
                            .font(.system(size: 12))
                            .foregroundStyle(.primary)

                        Circle()
                            .fill(ratingColor)
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 12) {
                    AdditivesRatingRowsView(additives: additivesRating.additives)

                    Button(action: {
                        showAdditivesSheet = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 16))
                                .foregroundStyle(.blue)

                            Text("Mehr über die Zusatzstoffe")
                                .font(.system(size: 15))
                                .foregroundStyle(.blue)

                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.leading, 48)
                .padding(.trailing, 16)
                .padding(.top, 4)
                .padding(.bottom, 12)
                .background(Color(.systemBackground))
                .transition(
                    .asymmetric(
                        insertion: .offset(y: -20).combined(with: .opacity),
                        removal: .offset(y: -10).combined(with: .opacity)
                    )
                )
            }

            Divider()
                .padding(.leading, 52)
        }
    }

    private func colorForRating(_ rating: String) -> Color {
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

#Preview {
    VStack(spacing: 0) {
        ProductDetailAdditiveRowItem(
            additivesRating: AdditiveRating(
                rating: "MEDIUM",
                description: "Mittleres Risiko",
                numberOfAdditives: 4,
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
                            description: "Färbemittel"
                        ),
                        additiveHealthRisks: nil
                    ),
                    Additive(
                        id: 2,
                        name: "E211 - Natriumbenzoat",
                        description: "Konservierungsmittel",
                        risk: "LOW_RISK",
                        additiveTypeId: 2,
                        additiveType: nil,
                        additiveHealthRisks: nil
                    ),
                    Additive(
                        id: 3,
                        name: "E621 - Mononatriumglutamat",
                        description: "Geschmacksverstärker",
                        risk: "MODERATE_RISK",
                        additiveTypeId: 3,
                        additiveType: nil,
                        additiveHealthRisks: nil
                    ),
                    Additive(
                        id: 4,
                        name: "E300 - Ascorbinsäure",
                        description: "Vitamin C",
                        risk: "NO_RISK",
                        additiveTypeId: 4,
                        additiveType: nil,
                        additiveHealthRisks: nil
                    )
                ]
            ),
            showAdditivesSheet: .constant(false)
        )
    }
    .background(Color(.systemBackground))
}
