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
    @Published var errorMessage: String?
    private var hasLoadedInitially = false

    func fetchProducts() async {
        guard !hasLoadedInitially else { return }

        isInitialLoading = true
        errorMessage = nil

        do {
            products = try await GraphQLClient.shared.fetchProducts()
            errorMessage = nil
            hasLoadedInitially = true
        } catch {
            errorMessage = error.localizedDescription
            products = []
            hasLoadedInitially = true
        }

        isInitialLoading = false
    }
}
