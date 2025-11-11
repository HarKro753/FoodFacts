//
//  ScannerViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import Foundation

@MainActor
class ScannerViewModel: ObservableObject {
    @Published var isAddingToHistory = false
    @Published var errorMessage: String?

    /// Adds a scanned product to the user's history
    func addScannedProductToHistory(productCode: String) async {
        // Convert barcode string to Int
        guard let code = Int(productCode) else {
            errorMessage = "Invalid product code"
            return
        }

        isAddingToHistory = true
        errorMessage = nil

        do {
            _ = try await GraphQLClient.shared.addProductHistoryItem(productCode: code)
            // Successfully added to history
            print("Product \(code) added to history")
        } catch {
            errorMessage = error.localizedDescription
            print("Error adding product to history: \(error)")
        }

        isAddingToHistory = false
    }
}
