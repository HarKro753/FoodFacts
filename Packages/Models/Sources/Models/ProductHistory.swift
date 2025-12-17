import Foundation

@available(iOS 13.0, *)
public struct ProductHistory: Codable, Identifiable {
    public let id: Int
    public let productCode: Int
    public let scannedAt: String
    public let product: Product?

    public enum CodingKeys: String, CodingKey {
        case id, productCode, scannedAt, product
    }
    
    public init(id: Int, productCode: Int, scannedAt: String, product: Product?) {
        self.id = id
        self.productCode = productCode
        self.scannedAt = scannedAt
        self.product = product
    }
}
