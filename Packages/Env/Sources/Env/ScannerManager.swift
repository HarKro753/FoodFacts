//
//  ScannerManager.swift
//  Env
//
//  Created by Harro Krog on 11.11.25.
//

import Combine
import Foundation
import Models
import GraphQl

@MainActor
@Observable
public class ScannerManager: NetworkAwareFetching {
    public var scannedProduct: Product?
    private var errorMessage: String?
    private var isLoading: Bool = false

    public let networkMonitor = NetworkMonitor.shared

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

        guard let code = Int(productCode) else {
            setError("Invalid product code")
            return
        }

        let product = await fetchWithNetworkCheck {
            try await GraphQLClient.shared.fetchProductByCode(code: productCode)
        }

        if let product = product {
            Task {
                do {
                    _ = try await GraphQLClient.shared.addProductHistoryItem(
                        productCode: code
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
