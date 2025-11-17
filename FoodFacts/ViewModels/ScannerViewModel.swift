//
//  ScannerViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import Combine
import Foundation

@MainActor
class ScannerViewModel: ObservableObject {
    @Published var scannedProduct: Product?
    @Published var errorMessage: String?

    func handleScannedBarcode(productCode: String) async {
        errorMessage = nil
        scannedProduct = nil
        
        guard let code = Int(productCode) else {
            errorMessage = "Invalid product code"
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
            errorMessage = error.localizedDescription
            scannedProduct = nil
        }
    }

    func clearScannedProduct() {
        scannedProduct = nil
        errorMessage = nil
    }
}