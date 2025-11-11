//
//  ScannerViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import Foundation
import Combine

@MainActor
class ScannerViewModel: ObservableObject {
    @Published var scannedProduct: Product?
    @Published var isFetchingProduct = false
    @Published var isAddingToHistory = false
    @Published var errorMessage: String?

    /// Fetches product details and adds it to history when a barcode is scanned
    func handleScannedBarcode(productCode: String) async {
        guard let code = Int(productCode) else {
            errorMessage = "Invalid product code"
            return
        }

        isFetchingProduct = true
        errorMessage = nil

        do {
            // Fetch product details
            let product = try await GraphQLClient.shared.fetchProductByCode(code: productCode)

            if let product = product {
                scannedProduct = product

                // Add to history
                isAddingToHistory = true
                _ = try await GraphQLClient.shared.addProductHistoryItem(productCode: code)
                isAddingToHistory = false

                print("Product \(code) fetched and added to history")
            } else {
                errorMessage = "Product not found"
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error handling scanned barcode: \(error)")
        }

        isFetchingProduct = false
    }

    /// Clears the scanned product state
    func clearScannedProduct() {
        scannedProduct = nil
        errorMessage = nil
    }
}
