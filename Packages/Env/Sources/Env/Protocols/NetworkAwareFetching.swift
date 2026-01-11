//
//  NetworkAwareFetching.swift
//  Env
//
//  Protocol for network-aware product fetching operations
//

import Foundation

@MainActor
public protocol NetworkAwareFetching: ProductFetchingState {}

extension NetworkAwareFetching {
    public func fetchWithNetworkCheck<T>(
        _ operation: () async throws -> T
    ) async -> T? {
        guard NetworkMonitor.shared.getIsConnected() else {
            setError("No internet connection. Please check your network and try again.")
            return nil
        }

        startLoading()

        do {
            let result = try await operation()
            stopLoading()
            clearError()
            return result
        } catch {
            if !NetworkMonitor.shared.getIsConnected() {
                setError("Lost internet connection. Please check your network and try again.")
            } else {
                setError(error.localizedDescription)
            }
            return nil
        }
    }

    public func fetchWithNetworkCheckVoid(
        _ operation: () async throws -> Void
    ) async -> Bool {
        guard NetworkMonitor.shared.getIsConnected() else {
            setError("No internet connection. Please check your network and try again.")
            return false
        }

        startLoading()

        do {
            try await operation()
            stopLoading()
            clearError()
            return true
        } catch {
            if !NetworkMonitor.shared.getIsConnected() {
                setError("Lost internet connection. Please check your network and try again.")
            } else {
                setError(error.localizedDescription)
            }
            return false
        }
    }
}
