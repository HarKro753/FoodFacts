//
//  ProductFetchingState.swift
//  Env
//
//  Protocol for common state management in product fetching
//

import Foundation

@MainActor
public protocol ProductFetchingState: AnyObject {
    func getErrorMessage() -> String?
    func setErrorMessage(_ message: String?)
    func getIsLoading() -> Bool
    func setIsLoading(_ loading: Bool)
}

extension ProductFetchingState {
    public func setError(_ message: String) {
        setErrorMessage(message)
        setIsLoading(false)
    }

    public func clearError() {
        setErrorMessage(nil)
    }

    public func startLoading() {
        setIsLoading(true)
        setErrorMessage(nil)
    }

    public func stopLoading() {
        setIsLoading(false)
    }
}
