//
//  PaginatedFetching.swift
//  Env
//
//  Protocol for paginated product fetching
//

import Foundation

@MainActor
public protocol PaginatedFetching: ProductFetchingState {
    var hasNextPage: Bool { get set }
    var endCursor: String? { get set }
    var isLoadingMore: Bool { get set }
}

extension PaginatedFetching {
    public func updatePagination(hasNextPage: Bool, endCursor: String?) {
        self.hasNextPage = hasNextPage
        self.endCursor = endCursor
    }

    public func resetPagination() {
        hasNextPage = false
        endCursor = nil
        isLoadingMore = false
    }

    public func startLoadingMore() {
        isLoadingMore = true
        errorMessage = nil
    }

    public func stopLoadingMore() {
        isLoadingMore = false
    }
}
