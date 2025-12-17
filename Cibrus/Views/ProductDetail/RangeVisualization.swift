//
//  RangeVisualization.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import Foundation
import SwiftUI
import Models

struct RatingRangeView: View {
    let ratingSections: [RatingSection]
    let currentValue: Double
    let indicatorColor: Color

    private func formatValue(_ value: Double) -> String {
        let formatted = String(format: "%.2f", value)
        if let number = Double(formatted),
            number.truncatingRemainder(dividingBy: 1) == 0
        {
            return String(format: "%.0f", number)
        }
        return formatted.replacingOccurrences(
            of: #"\.?0+$"#,
            with: "",
            options: .regularExpression
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: Bar + Triangle
            GeometryReader { geometry in
                let sortedSections = ratingSections.sorted {
                    $0.minValue < $1.minValue
                }
                let minDisplayValue = sortedSections.first?.minValue ?? 0
                let maxDisplayValue = sortedSections.last?.maxValue ?? 100
                let totalRange = max(maxDisplayValue - minDisplayValue, 0.001)
                let gapSize: CGFloat = 2
                let totalGaps = CGFloat(sortedSections.count - 1) * gapSize
                let availableWidth = geometry.size.width - totalGaps

                // Pre-calculate widths - equal width for all sections
                let barWidths: [CGFloat] = sortedSections.indices.map { _ in
                    return availableWidth / CGFloat(sortedSections.count)
                }

                // Triangle position
                let triangleX: CGFloat = {
                    // Clamp currentValue to display range
                    let clampedValue = min(max(currentValue, minDisplayValue), maxDisplayValue)
                    var pos: CGFloat = 0
                    
                    for i in sortedSections.indices {
                        let s = sortedSections[i]
                        let sMin = s.minValue
                        let sMax = s.maxValue
                        let sRange = sMax - sMin
                        let sWidth = barWidths[i]

                        if clampedValue >= sMin && clampedValue <= sMax {
                            let fraction = sRange > 0 ? (clampedValue - sMin) / sRange : 0
                            pos += sWidth * CGFloat(fraction)
                            break
                        } else if clampedValue > sMax {
                            pos += sWidth + (i < sortedSections.count - 1 ? gapSize : 0)
                        }
                    }
                    return min(max(pos, 0), geometry.size.width)
                }()

                ZStack(alignment: .topLeading) {
                    // Colored segments
                    HStack(spacing: gapSize) {
                        ForEach(sortedSections.indices, id: \.self) { i in
                            let width = barWidths[i]
                            if width > 0 {
                                Rectangle()
                                    .fill(sortedSections[i].color)
                                    .frame(width: width, height: 6)
                            }
                        }
                    }
                    .cornerRadius(3)

                    // Triangle indicator
                    Triangle()
                        .fill(indicatorColor)
                        .frame(width: 10, height: 8)
                        .offset(x: triangleX - 5, y: -10)
                }
            }
            .frame(height: 12)
            .padding(.top, 8)

            // MARK: Labels
            GeometryReader { geometry in
                let sortedSections = ratingSections.sorted {
                    $0.minValue < $1.minValue
                }
                let minDisplayValue = sortedSections.first?.minValue ?? 0
                let maxDisplayValue = sortedSections.last?.maxValue ?? 100
                let totalRange = max(maxDisplayValue - minDisplayValue, 0.001)
                let gapSize: CGFloat = 2
                let totalGaps = CGFloat(sortedSections.count - 1) * gapSize
                let availableWidth = geometry.size.width - totalGaps

                let labelData: [(value: Double, position: CGFloat)] = {
                    var result: [(Double, CGFloat)] = []
                    let sectionWidth = availableWidth / CGFloat(sortedSections.count)
                    var cum: CGFloat = 0
                    for i in sortedSections.indices {
                        let s = sortedSections[i]

                        if i < sortedSections.count - 1 {
                            let nextMin = sortedSections[i + 1].minValue
                            result.append((nextMin, cum + sectionWidth))
                        }
                        cum += sectionWidth + (i < sortedSections.count - 1 ? gapSize : 0)
                    }
                    return result
                }()

                ZStack(alignment: .topLeading) {
                    // Start
                    Text(formatValue(minDisplayValue))
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    // Boundaries
                    ForEach(labelData.indices, id: \.self) { i in
                        Text(formatValue(labelData[i].value))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .offset(x: labelData[i].position - 10, y: 0)
                    }

                    // End
                    Text(formatValue(maxDisplayValue))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .offset(x: geometry.size.width - 16, y: 0)
                }
            }
            .frame(height: 20)
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

// MARK: - Preview
#Preview("Salt – 0.65g (Good)") {
    RatingRangeView(
        ratingSections: [
            RatingSection(
                rating: "VERY_GOOD",
                minValue: 0,
                maxValue: 0.3,
                description: "Very low"
            ),
            RatingSection(
                rating: "GOOD",
                minValue: 0.3,
                maxValue: 0.9,
                description: "Low"
            ),
            RatingSection(
                rating: "MEDIUM",
                minValue: 0.9,
                maxValue: 1.5,
                description: "Moderate"
            ),
            RatingSection(
                rating: "BAD",
                minValue: 1.5,
                maxValue: 2.4,
                description: "High"
            ),
        ],
        currentValue: 100,
        indicatorColor: .green
    )
    .padding()
    .background(Color(.systemBackground))
}

#Preview("Sugar – 35.9g (Very High)") {
    RatingRangeView(
        ratingSections: [
            RatingSection(
                rating: "VERY_GOOD",
                minValue: 0,
                maxValue: 5,
                description: "Very low"
            ),
            RatingSection(
                rating: "GOOD",
                minValue: 5,
                maxValue: 12.5,
                description: "Low"
            ),
            RatingSection(
                rating: "MEDIUM",
                minValue: 12.5,
                maxValue: 22.5,
                description: "Moderate"
            ),
            RatingSection(
                rating: "BAD",
                minValue: 22.5,
                maxValue: 30,
                description: "High"
            ),
        ],
        currentValue: 35.9,
        indicatorColor: .red
    )
    .padding()
    .background(Color(.systemBackground))
}

#Preview("Energy – 1800 kcal (Extreme)") {
    RatingRangeView(
        ratingSections: [
            RatingSection(
                rating: "VERY_GOOD",
                minValue: 0,
                maxValue: 400,
                description: "Low"
            ),
            RatingSection(
                rating: "GOOD",
                minValue: 400,
                maxValue: 800,
                description: "Moderate"
            ),
            RatingSection(
                rating: "MEDIUM",
                minValue: 800,
                maxValue: 1200,
                description: "High"
            ),
            RatingSection(
                rating: "BAD",
                minValue: 1200,
                maxValue: 5000,
                description: "Very high"
            ),
        ],
        currentValue: 1800,
        indicatorColor: .orange
    )
    .padding()
    .background(Color(.systemBackground))
}
