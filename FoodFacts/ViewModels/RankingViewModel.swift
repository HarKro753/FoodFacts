//
//  RankingViewModel.swift
//  YukaMock
//
//  Created by Harro Krog on 10.11.25.
//

import Foundation
import SwiftUI
import Combine

struct Category: Identifiable {
    let id: Int
    let name: String
    let icon: String
    let color: Color
}

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
        3: CategoryStyle(icon: "bag", color: .brown),
        4: CategoryStyle(icon: "fork.knife", color: .purple),
        5: CategoryStyle(icon: "crown", color: .pink),

        // Dairy
        6: CategoryStyle(icon: "drop", color: .green),
        7: CategoryStyle(icon: "leaf", color: .green),
        8: CategoryStyle(icon: "cup.and.saucer", color: .cyan),
        9: CategoryStyle(icon: "square.stack.3d.up", color: .yellow),

        // Pastries & Pies
        10: CategoryStyle(icon: "birthday.cake", color: .pink),
        11: CategoryStyle(icon: "croissant", color: .brown),
        12: CategoryStyle(icon: "croissant.fill", color: .brown),

        // Plant-based
        13: CategoryStyle(icon: "leaf", color: .green),
        14: CategoryStyle(icon: "leaf.fill", color: .green),
        15: CategoryStyle(icon: "grain", color: .brown),
        16: CategoryStyle(icon: "basket", color: .brown),
        17: CategoryStyle(icon: "basket.fill", color: .yellow),
        18: CategoryStyle(icon: "house", color: .brown),

        // Condiments
        19: CategoryStyle(icon: "drop.triangle", color: .red),
        20: CategoryStyle(icon: "drop.triangle.fill", color: .red),
        21: CategoryStyle(icon: "drop.circle", color: .orange),

        // Groceries & Biscuits
        22: CategoryStyle(icon: "cart", color: .blue),
        23: CategoryStyle(icon: "square.on.square", color: .orange),
        24: CategoryStyle(icon: "circle.hexagongrid", color: .pink),
        25: CategoryStyle(icon: "circle.hexagongrid.fill", color: .orange),
        26: CategoryStyle(icon: "circle.grid.2x2", color: .pink),
        27: CategoryStyle(icon: "leaf.circle", color: .red),
        28: CategoryStyle(icon: "sun.max", color: .yellow),
        29: CategoryStyle(icon: "circle.fill", color: .red),

        // Cheeses
        30: CategoryStyle(icon: "square.stack.3d.up", color: .yellow),
        31: CategoryStyle(icon: "flag", color: .blue),
        32: CategoryStyle(icon: "square.stack", color: .yellow),
        33: CategoryStyle(icon: "square.fill", color: .yellow),

        // More Pies & Tarts
        34: CategoryStyle(icon: "circle.hexagongrid", color: .pink),
        35: CategoryStyle(icon: "leaf.circle.fill", color: .red),
        36: CategoryStyle(icon: "leaf", color: .green),
        37: CategoryStyle(icon: "basket", color: .brown),

        // Meats
        38: CategoryStyle(icon: "fork.knife", color: .red),
        39: CategoryStyle(icon: "fork.knife.circle", color: .red),
        40: CategoryStyle(icon: "fork.knife.circle.fill", color: .red),
        41: CategoryStyle(icon: "circle.hexagongrid.fill", color: .orange),
        42: CategoryStyle(icon: "leaf.fill", color: .red),

        // Hams
        43: CategoryStyle(icon: "fork.knife", color: .pink),
        44: CategoryStyle(icon: "fork.knife.circle", color: .pink),
        45: CategoryStyle(icon: "crown.fill", color: .pink),

        // Breads
        46: CategoryStyle(icon: "basket", color: .brown),
        47: CategoryStyle(icon: "basket.fill", color: .brown),

        // Cakes & Doughnuts
        48: CategoryStyle(icon: "birthday.cake", color: .pink),
        49: CategoryStyle(icon: "circle", color: .brown),
        50: CategoryStyle(icon: "circle.fill", color: .brown)
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
