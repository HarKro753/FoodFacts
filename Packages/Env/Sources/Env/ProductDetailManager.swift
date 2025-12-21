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
public class ProductDetailManager {
    public var product: Product?
    public var alternatives: [Product] = []
    public var isLoadingProduct = false
    public var isLoadingAlternatives = false
    public var errorMessage: String?

    private let productCode: Int

    public init(productCode: Int, product: Product? = nil) {
        self.productCode = productCode
        self.product = product
    }

    public func fetchProduct() async {
        guard product == nil else { return }

        isLoadingProduct = true
        errorMessage = nil

        do {
            let fetchedProduct = try await GraphQLClient.shared.fetchProductByCode(
                code: String(productCode)
            )
            product = fetchedProduct
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingProduct = false
    }

    public func fetchAlternatives() async {
        isLoadingAlternatives = true
        errorMessage = nil

        do {
            let result = try await GraphQLClient.shared.fetchProducts(
                countryId: 2,
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
