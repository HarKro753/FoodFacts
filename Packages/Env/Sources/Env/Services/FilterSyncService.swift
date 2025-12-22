//
//  FilterSyncService.swift
//  Env
//
//  Reusable service for synchronizing with FilterManager
//

import Combine
import Models

@available(iOS 13.0, macOS 10.15, *)
@MainActor
public class FilterSyncService {
    public private(set) var activeFilters: Set<ProductFilter> = []
    public private(set) var filterStateId: String = ""

    private var cancellables = Set<AnyCancellable>()
    private let filterManager = FilterManager.shared
    private let onFilterChange: () async -> Void

    public init(onFilterChange: @escaping () async -> Void) {
        self.onFilterChange = onFilterChange
        setupBindings()
    }

    private func setupBindings() {
        filterManager.$activeFilters
            .sink { [weak self] filters in
                self?.activeFilters = filters
            }
            .store(in: &cancellables)

        filterManager.$filterStateId
            .sink { [weak self] stateId in
                guard let self = self else { return }
                self.filterStateId = stateId
                Task {
                    await self.onFilterChange()
                }
            }
            .store(in: &cancellables)
    }

    public func buildFilterParameters() -> (
        labelIds: [Int]?,
        nutrientConditions: [(String, Double?, Double?)]?,
        sortAscending: Bool?
    ) {
        filterManager.buildFilterParameters()
    }
}
