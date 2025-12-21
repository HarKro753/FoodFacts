//
//  ProductRankingManager.swift
//  Env
//
//  Created by Harro Krog on 10.11.25.
//

import Combine
import Foundation
import SwiftUI
import Models
import GraphQl

@MainActor
@Observable
public class ProductRankingManager {
    public var products: [Product] = []
    public var isInitialLoading = true
    public var errorMessage: String?

    private var hasLoadedInitially = false
    private let foodGroupId: Int

    public init(foodGroupId: Int) {
        self.foodGroupId = foodGroupId
    }

    public func fetchProducts() async {
        guard !hasLoadedInitially else { return }

        isInitialLoading = true
        errorMessage = nil

        do {
            let result = try await GraphQLClient.shared.fetchProducts(
                first: 20,
                countryId: 2,
                foodGroup: foodGroupId,
                sortAscending: true
            )
            products = result.products
            errorMessage = nil
            hasLoadedInitially = true
        } catch {
            errorMessage = error.localizedDescription
            products = []
            hasLoadedInitially = true
        }

        isInitialLoading = false
    }

    public func refresh() async {
        errorMessage = nil

        do {
            let result = try await GraphQLClient.shared.fetchProducts(
                first: 20,
                countryId: 2,
                foodGroup: foodGroupId,
                sortAscending: true
            )
            products = result.products
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
