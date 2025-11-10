//
//  ProductDetailViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProductDetailViewModel: ObservableObject {
    @Published var alternatives: [Product] = []
    @Published var isLoadingAlternatives = false
    @Published var errorMessage: String?

    private let productCode: Int

    init(productCode: Int) {
        self.productCode = productCode
    }

    func fetchAlternatives() async {
        isLoadingAlternatives = true
        errorMessage = nil

        do {
            let fetchedAlternatives = try await GraphQLClient.shared.fetchAlternatives(productCode: productCode)
            alternatives = fetchedAlternatives
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            alternatives = []
        }

        isLoadingAlternatives = false
    }
}
