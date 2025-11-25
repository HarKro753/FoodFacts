//
//  CompletionRow.swift
//  FoodFacts
//
//  Created by Harro Krog on 20.11.25.
//

import SwiftUI

struct CompletionRow: View {
    let icon: String
    let iconColor: Color
    let name: String
    let searchText: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 20)

            highlightedText
                .lineLimit(1)

            Spacer()
        }
    }

    @ViewBuilder
    private var highlightedText: some View {
        let prefix = searchText.trimmingCharacters(in: .whitespaces)

        if !prefix.isEmpty,
            let range = name.range(
                of: prefix,
                options: [.caseInsensitive, .diacriticInsensitive]
            )
        {
            let beforeMatch = String(name[..<range.lowerBound])
            let match = String(name[range])
            let afterMatch = String(name[range.upperBound...])

            (Text(beforeMatch).foregroundColor(.secondary)
                + Text(match).foregroundColor(.primary).fontWeight(.semibold)
                + Text(afterMatch).foregroundColor(.secondary))
                .font(.system(size: 15))
        } else {
            Text(name)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Completion Row Placeholder

struct CompletionRowPlaceholder: View {
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 20, height: 16)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 15)
                .frame(maxWidth: .infinity)

            Spacer()
        }
    }
}
