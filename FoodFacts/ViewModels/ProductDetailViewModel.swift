//
//  ProductDetailViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import Combine
import Foundation
import SwiftUI

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
            let result = try await GraphQLClient.shared.fetchProducts(
                countryId: 9,
                productCodeForAlternatives: productCode
            )
            alternatives = result.products
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            alternatives = []
        }

        isLoadingAlternatives = false
    }
}
