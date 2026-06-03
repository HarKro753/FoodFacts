//
//  ScannerManager.swift
//  Env
//
//  Created by Harro Krog on 11.11.25.
//

import Combine
import Foundation
import GraphQl
import Models

@MainActor
@Observable
public class ScannerManager: NetworkAwareFetching {
    public var scannedProduct: Product?
    private var errorMessage: String?
    private var isLoading: Bool = false

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

    public init() {}

    public func handleScannedBarcode(productCode: String) async {
        clearError()
        scannedProduct = nil

        _ = productCode

        let product = await fetchWithNetworkCheck { () async throws -> Product in
            guard let product = try await GraphQLClient.shared.fetchRandomProduct() else {
                throw GraphQLClientError.noData
            }
            return product
        }

        if let product = product {
            Task {
                do {
                    _ = try await GraphQLClient.shared.addProductHistoryItem(
                        productCode: product.id
                    )
                } catch {
                    print("Failed to add to history: \(error)")
                }
            }

            scannedProduct = product
        } else if getErrorMessage() == nil {
            setError("Product not found")
        }
    }

    public func clearScannedProduct() {
        scannedProduct = nil
        clearError()
    }
}
