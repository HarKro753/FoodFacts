import Foundation

@available(iOS 14.0, *)
public struct User: Identifiable, Equatable {
    public let id: Int
    public let username: String?
    public let email: String?
    public let appleId: String?
    public let isPremium: Bool
    public let createdAt: Date
    public let updatedAt: Date
    public let lastLoginAt: Date?

    public init(
        id: Int,
        username: String? = nil,
        email: String? = nil,
        appleId: String? = nil,
        isPremium: Bool = false,
        createdAt: Date,
        updatedAt: Date,
        lastLoginAt: Date? = nil
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.appleId = appleId
        self.isPremium = isPremium
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastLoginAt = lastLoginAt
    }
}
