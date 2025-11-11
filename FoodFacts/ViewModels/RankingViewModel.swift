//
//  RankingViewModel.swift
//  YukaMock
//
//  Created by Harro Krog on 10.11.25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class RankingViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var hasLoadedInitially = false

    struct CategoryStyle {
        let icon: String
        let color: Color
    }

    private let categoryStyles: [Int: CategoryStyle] = [
        // Snacks
        1: CategoryStyle(icon: "takeoutbag.and.cup.and.straw", color: .blue),
        2: CategoryStyle(icon: "birthday.cake", color: .orange),
    ]

    func fetchCategories() async {
        guard !hasLoadedInitially else { return }

        isLoading = true
        errorMessage = nil

        do {
            let allCategories = try await GraphQLClient.shared.fetchCategories()
            categories = allCategories
                .filter { categoryStyles.keys.contains($0.id) }
                .map { node in
                    let style = categoryStyles[node.id] ?? CategoryStyle(icon: "square.grid.2x2", color: .gray)
                    return Category(
                        id: node.id,
                        name: node.name,
                        icon: style.icon,
                        color: style.color
                    )
                }
            errorMessage = nil
            hasLoadedInitially = true
        } catch {
            errorMessage = error.localizedDescription
            categories = []
            hasLoadedInitially = true
        }

        isLoading = false
    }

    func refresh() async {
        hasLoadedInitially = false
        categories = []
        await fetchCategories()
    }
}
