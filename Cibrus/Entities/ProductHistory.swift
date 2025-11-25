import Foundation

struct ProductHistory: Codable, Identifiable {
    let id: Int
    let productCode: Int
    let scannedAt: String
    let product: Product?

    enum CodingKeys: String, CodingKey {
        case id, productCode, scannedAt, product
    }
}