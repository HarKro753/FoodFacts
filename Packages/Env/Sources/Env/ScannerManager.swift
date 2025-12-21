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
public class ScannerManager {
    public var scannedProduct: Product?
    public var errorMessage: String?

    public let networkMonitor = NetworkMonitor.shared

    public init() {}

    public func handleScannedBarcode(productCode: String) async {
        errorMessage = nil
        scannedProduct = nil

        guard let code = Int(productCode) else {
            errorMessage = "Invalid product code"
            return
        }

        guard networkMonitor.isConnected else {
            errorMessage = "No internet connection. Please check your network and try scanning again."
            return
        }

        do {
            let product = try await GraphQLClient.shared.fetchProductByCode(
                code: productCode
            )

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
            } else {
                errorMessage = "Product not found"
            }
        } catch {
            if !networkMonitor.isConnected {
                errorMessage = "Lost internet connection. Please check your network and try scanning again."
            } else {
                errorMessage = error.localizedDescription
            }
            scannedProduct = nil
        }
    }

    public func clearScannedProduct() {
        scannedProduct = nil
        errorMessage = nil
    }
}
