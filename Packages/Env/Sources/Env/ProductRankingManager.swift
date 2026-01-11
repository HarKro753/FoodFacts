//
//  ProductRankingManager.swift
//  Env
//
//  Created by Harro Krog on 10.11.25.
//

import Combine
import Foundation
import GraphQl
import Models
import SwiftUI

@MainActor
@Observable
public class ProductRankingManager: NetworkAwareFetching {
    public var products: [Product] = []
    public var isInitialLoading = true
    public var errorMessage: String?
    public var isLoading: Bool = false

    public let networkMonitor = NetworkMonitor.shared

    private var hasLoadedInitially = false
    private let foodGroupId: Int

    public init(foodGroupId: Int) {
        self.foodGroupId = foodGroupId
    }

    public func fetchProducts() async {
        guard !hasLoadedInitially else { return }

        isInitialLoading = true

        let result = await fetchWithNetworkCheck {
            try await GraphQLClient.shared.fetchProducts(
                first: 20,
                countryId: 2,
                foodGroup: foodGroupId,
                sortAscending: true
            )
        }

        products = result?.products ?? []
        hasLoadedInitially = true
        isInitialLoading = false
    }

    public func refresh() async {
        let result = await fetchWithNetworkCheck {
            try await GraphQLClient.shared.fetchProducts(
                first: 20,
                countryId: 2,
                foodGroup: foodGroupId,
                sortAscending: true
            )
        }

        if let result = result {
            products = result.products
        }
    }
}
