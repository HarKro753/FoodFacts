//
//  PaginatedFetching.swift
//  Env
//
//  Protocol for paginated product fetching
//

import Foundation

@MainActor
public protocol PaginatedFetching: ProductFetchingState {
    func getHasNextPage() -> Bool
    func setHasNextPage(_ hasNextPage: Bool)
    func getEndCursor() -> String?
    func setEndCursor(_ cursor: String?)
    func getIsLoadingMore() -> Bool
    func setIsLoadingMore(_ loading: Bool)
}

extension PaginatedFetching {
    public func updatePagination(hasNextPage: Bool, endCursor: String?) {
        setHasNextPage(hasNextPage)
        setEndCursor(endCursor)
    }

    public func resetPagination() {
        setHasNextPage(false)
        setEndCursor(nil)
        setIsLoadingMore(false)
    }

    public func startLoadingMore() {
        setIsLoadingMore(true)
        setErrorMessage(nil)
    }

    public func stopLoadingMore() {
        setIsLoadingMore(false)
    }
}
