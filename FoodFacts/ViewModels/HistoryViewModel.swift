//
//  HistoryViewModel.swift
//  YukaMock
//
//  Created by Harro Krog on 09.11.25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isInitialLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?

    func fetchProducts(isInitialLoad: Bool) async {
        if isInitialLoad {
            isInitialLoading = true
        } else {
            isRefreshing = true
        }

        errorMessage = nil

        do {
            products = try await GraphQLClient.shared.fetchProducts()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            // Fallback to sample data for development/testing
            products = Product.sampleProducts
        }

        if isInitialLoad {
            isInitialLoading = false
        } else {
            isRefreshing = false
        }
    }
}
