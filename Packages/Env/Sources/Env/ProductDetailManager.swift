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
    private var errorMessage: String?
    private var isLoading: Bool = false

    private let productCode: Int

    // MARK: - Protocol Conformance (ProductFetchingState)

    public func getErrorMessage() -> String? {
        return errorMessage
    }

    public func setErrorMessage(_ message: String?) {
        errorMessage = message
    }

    public func getIsLoading() -> Bool {
        return isLoading
    }

    public func setIsLoading(_ loading: Bool) {
        isLoading = loading
    }

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

        alternatives = result?.items ?? []
        isLoadingAlternatives = false
    }
}
