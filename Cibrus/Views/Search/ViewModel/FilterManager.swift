//
//  FilterManager.swift
//  FoodFacts
//
//  Created by Harro Krog on 20.11.25.
//

import Combine
import Foundation

@MainActor
class FilterManager: ObservableObject {
    static let shared = FilterManager()

    @Published var activeFilters: Set<ProductFilter> = []
    @Published private(set) var filterStateId: String = ""

    private func updateFilterStateId() {
        filterStateId = activeFilters.sorted(by: { $0.id < $1.id })
            .map { $0.id }
            .joined(separator: "-")
    }

    func toggleFilter(_ filter: ProductFilter) {
        if activeFilters.contains(filter) {
            activeFilters.remove(filter)
        } else {
            activeFilters.insert(filter)
        }
        updateFilterStateId()
    }

    func clearFilters() {
        activeFilters.removeAll()
        updateFilterStateId()
    }

    func buildFilterParameters() -> (
        labelIds: [Int]?, nutrientConditions: [(String, Double?, Double?)]?,
        sortAscending: Bool?
    ) {
        var labelIds: [Int] = []
        var nutrientConditions: [(String, Double?, Double?)] = []
        var sortAscending: Bool? = nil

        for filter in activeFilters {
            switch filter {
            case .vegan:
                labelIds.append(4)
            case .vegetarian:
                labelIds.append(3)
            case .lowCalorie:
                nutrientConditions.append(("energyKcal100g", nil, 200.0))
            case .highProtein:
                nutrientConditions.append(("proteins100g", 10.0, nil))
            case .highNutriScore:
                sortAscending = true
            }
        }

        return (
            labelIds: labelIds.isEmpty ? nil : labelIds,
            nutrientConditions: nutrientConditions.isEmpty
                ? nil : nutrientConditions,
            sortAscending: sortAscending
        )
    }
}
