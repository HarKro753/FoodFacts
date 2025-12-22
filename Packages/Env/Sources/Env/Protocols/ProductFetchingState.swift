//
//  ProductFetchingState.swift
//  Env
//
//  Protocol for common state management in product fetching
//

import Foundation

@MainActor
public protocol ProductFetchingState: AnyObject {
    var errorMessage: String? { get set }
    var isLoading: Bool { get set }
}

extension ProductFetchingState {
    public func setError(_ message: String) {
        errorMessage = message
        isLoading = false
    }

    public func clearError() {
        errorMessage = nil
    }

    public func startLoading() {
        isLoading = true
        errorMessage = nil
    }

    public func stopLoading() {
        isLoading = false
    }
}
