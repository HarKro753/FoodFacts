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
    public var errorMessage: String?
    public var isLoading: Bool = false

    public let networkMonitor = NetworkMonitor.shared

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
        } else if errorMessage == nil {
            setError("Product not found")
        }
    }

    public func clearScannedProduct() {
        scannedProduct = nil
        clearError()
    }
}
