//
//  KategorieRowItem.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import Foundation
import SwiftUI

struct KategorieRowItem: View {
    let icon: String
    let trait: String
    let traitDescription: String
    let amount: String
    var color: Color = .green
    var ratingSections: [RatingSection]? = nil
    var currentValue: Double = 0

    @State private var isExpanded = false

    private func formatValue(_ value: Double) -> String {
        let formatted = String(format: "%.2f", value)
        if let number = Double(formatted) {
            if number.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%.0f", number)
            }
        }
        return formatted.replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
    }

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
                VStack(alignment: .leading, spacing: 8) {
                    let sortedSections = ratingSections!.sorted {
                        $0.minValue < $1.minValue
                    }

                    //MARK: Range visualization
                    VStack(alignment: .leading, spacing: 6) {
                        ZStack(alignment: .top) {
                            GeometryReader { geometry in
                                HStack(spacing: 2) {
                                    ForEach(sortedSections.indices, id: \.self)
                                    {
                                        index in
                                        let section = sortedSections[index]
                                        let maxDisplayValue = min(
                                            sortedSections.last!.maxValue,
                                            currentValue * 3
                                        )
                                        let totalRange = max(
                                            maxDisplayValue
                                                - sortedSections.first!.minValue,
                                            0.001
                                        )
                                        let sectionMin = section.minValue
                                        let sectionMax = min(
                                            section.maxValue,
                                            maxDisplayValue
                                        )
                                        let sectionRange = max(
                                            sectionMax - sectionMin,
                                            0
                                        )

                                        let availableWidth =
                                            geometry.size.width
                                            - CGFloat(
                                                (sortedSections.count - 1) * 2
                                            )
                                        let proportion =
                                            sectionRange / totalRange
                                        let width =
                                            availableWidth
                                            * CGFloat(proportion)

                                        if width > 0 {
                                            Rectangle()
                                                .fill(section.color)
                                                .frame(width: width)
                                        }
                                    }
                                }
                            }
                            .frame(height: 6)
                            .cornerRadius(3)

                            GeometryReader { geometry in
                                let sortedSections =
                                    ratingSections?.sorted {
                                        $0.minValue < $1.minValue
                                    } ?? []
                                if !sortedSections.isEmpty {
                                    let maxDisplayValue = min(
                                        sortedSections.last!.maxValue,
                                        currentValue * 3
                                    )
                                    let totalRange = max(
                                        maxDisplayValue
                                            - sortedSections.first!.minValue,
                                        0.001
                                    )
                                    let position =
                                        (currentValue
                                            - sortedSections.first!.minValue)
                                        / totalRange

                                    Triangle()
                                        .fill(color)
                                        .frame(width: 10, height: 8)
                                        .offset(
                                            x: geometry.size.width
                                                * CGFloat(
                                                    min(max(position, 0), 1)
                                                ) - 5,
                                            y: -10
                                        )
                                }
                            }
                            .frame(height: 6)
                        }
                        .frame(height: 16)
                        .padding(.top, 10)

                        // Min and max labels
                        HStack {
                            Text(formatValue(sortedSections.first?.minValue ?? 0))
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Spacer()

                            let maxDisplayValue = min(
                                sortedSections.last?.maxValue ?? 100,
                                currentValue * 3
                            )
                            Text(formatValue(maxDisplayValue))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                    }
                }
                .padding(.horizontal, 16)
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

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

#Preview {
    VStack(spacing: 0) {
        // With rating sections
        KategorieRowItem(
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
                    maxValue: 100,
                    description: "High salt"
                ),
            ],
            currentValue: 0.65
        )

        // Without rating sections
        KategorieRowItem(
            icon: "bolt.fill",
            trait: "Energy",
            traitDescription: "Moderate calorie",
            amount: "490kcal",
            color: .orange
        )

        // Bad rating
        KategorieRowItem(
            icon: "sparkle",
            trait: "Sugars",
            traitDescription: "High sugar",
            amount: "35.9g",
            color: .red
        )
    }
    .background(Color(.systemBackground))
}
