import Foundation

public struct PageInfo: Decodable, Sendable {
    public let hasNextPage: Bool
    public let hasPreviousPage: Bool
    public let startCursor: String?
    public let endCursor: String?

    public init(hasNextPage: Bool, hasPreviousPage: Bool, startCursor: String?, endCursor: String?) {
        self.hasNextPage = hasNextPage
        self.hasPreviousPage = hasPreviousPage
        self.startCursor = startCursor
        self.endCursor = endCursor
    }
}

@available(iOS 15.0, *)
public struct PaginatedResult<Item> {
    public let items: [Item]
    public let pageInfo: PageInfo

    public init(items: [Item], pageInfo: PageInfo) {
        self.items = items
        self.pageInfo = pageInfo
    }
}
