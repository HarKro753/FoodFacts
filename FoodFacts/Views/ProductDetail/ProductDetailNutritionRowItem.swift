//
//  KategorieRowItem.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import Foundation
import SwiftUI

struct ProductDetailNutritionRowItem: View {
    let icon: String
    let trait: String
    let traitDescription: String
    let amount: String
    var color: Color = .green
    var ratingSections: [RatingSection]? = nil
    var currentValue: Double = 0

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                if ratingSections != nil && !ratingSections!.isEmpty {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.gray)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(trait)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)

                        Text(traitDescription)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Text(amount)
                            .font(.system(size: 15))
                            .foregroundStyle(.primary)

                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)

                        if ratingSections != nil && !ratingSections!.isEmpty {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.gray)
                                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                RatingRangeView(
                    ratingSections: ratingSections!,
                    currentValue: currentValue,
                    indicatorColor: color
                )
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
}

#Preview {
    VStack(spacing: 0) {
        // With rating sections
        ProductDetailNutritionRowItem(
            icon: "cube.fill",
            trait: "Salt",
            traitDescription: "Low salt",
            amount: "0.65g",
            color: .green,
            ratingSections: [
                RatingSection(
                    rating: "VERY_GOOD",
                    minValue: 0,
                    maxValue: 0.3,
                    description: "Very low salt"
                ),
                RatingSection(
                    rating: "GOOD",
                    minValue: 0.3,
                    maxValue: 0.9,
                    description: "Low salt"
                ),
                RatingSection(
                    rating: "MEDIUM",
                    minValue: 0.9,
                    maxValue: 1.5,
                    description: "Moderate salt"
                ),
                RatingSection(
                    rating: "BAD",
                    minValue: 1.5,
                    maxValue: 6,
                    description: "High salt"
                ),
            ],
            currentValue: 0.65
        )

        // Without rating sections
        ProductDetailNutritionRowItem(
            icon: "bolt.fill",
            trait: "Energy",
            traitDescription: "Moderate calorie",
            amount: "490kcal",
            color: .orange,
            ratingSections: [
                RatingSection(
                    rating: "VERY_GOOD",
                    minValue: 0,
                    maxValue: 0.3,
                    description: "Very low salt"
                ),
                RatingSection(
                    rating: "GOOD",
                    minValue: 0.3,
                    maxValue: 0.9,
                    description: "Low salt"
                ),
                RatingSection(
                    rating: "MEDIUM",
                    minValue: 0.9,
                    maxValue: 1.5,
                    description: "Moderate salt"
                ),
                RatingSection(
                    rating: "BAD",
                    minValue: 1.5,
                    maxValue: 100,
                    description: "High salt"
                ),
            ]
        )

        // Bad rating
        ProductDetailNutritionRowItem(
            icon: "sparkle",
            trait: "Sugars",
            traitDescription: "High sugar",
            amount: "35.9g",
            color: .red
        )
    }
    .background(Color(.systemBackground))
}
