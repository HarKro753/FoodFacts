//
//  NetworkAwareFetching.swift
//  Env
//
//  Protocol for network-aware product fetching operations
//

import Foundation
import GraphQl

@MainActor
public protocol NetworkAwareFetching: ProductFetchingState {}

extension NetworkAwareFetching {
    public func fetchWithNetworkCheck<T>(
        _ operation: () async throws -> T
    ) async -> T? {
        guard GraphQLClient.usesLocalMockData || NetworkMonitor.shared.getIsConnected() else {
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
            if !GraphQLClient.usesLocalMockData && !NetworkMonitor.shared.getIsConnected() {
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
        guard GraphQLClient.usesLocalMockData || NetworkMonitor.shared.getIsConnected() else {
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
            if !GraphQLClient.usesLocalMockData && !NetworkMonitor.shared.getIsConnected() {
                setError("Lost internet connection. Please check your network and try again.")
            } else {
                setError(error.localizedDescription)
            }
            return false
        }
    }
}
