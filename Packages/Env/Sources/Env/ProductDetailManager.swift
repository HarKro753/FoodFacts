//
//  ProductDetailManager.swift
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
public class ProductDetailManager: NetworkAwareFetching {
    public var product: Product?
    public var alternatives: [Product] = []
    public var isLoadingProduct = false
    public var isLoadingAlternatives = false
    public var errorMessage: String?
    public var isLoading: Bool = false

    public let networkMonitor = NetworkMonitor.shared
    private let productCode: Int

    public init(productCode: Int, product: Product? = nil) {
        self.productCode = productCode
        self.product = product
    }

    public func fetchProduct() async {
        guard product == nil else { return }

        isLoadingProduct = true

        if let fetchedProduct = await fetchWithNetworkCheck({
            try await GraphQLClient.shared.fetchProductByCode(
                code: String(productCode)
            )
        }) {
            product = fetchedProduct
        }

        isLoadingProduct = false
    }

    public func fetchAlternatives() async {
        isLoadingAlternatives = true

        let result = await fetchWithNetworkCheck {
            try await GraphQLClient.shared.fetchProducts(
                countryId: 2,
                productCodeForAlternatives: productCode
            )
        }

        alternatives = result?.products ?? []
        isLoadingAlternatives = false
    }
}
