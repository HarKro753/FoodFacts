//
//  HistoryViewModel.swift
//  YukaMock
//
//  Created by Harro Krog on 09.11.25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var historyItems: [ProductHistory] = []
    @Published var isInitialLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasNextPage = false

    private var endCursor: String?
    private var hasLoadedInitially = false

    func fetchHistory() async {
        guard !hasLoadedInitially else { return }

        isInitialLoading = true
        errorMessage = nil

        do {
            let result = try await GraphQLClient.shared.fetchProductHistory()
            historyItems = result.historyItems
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            hasLoadedInitially = true
            // Clear error on successful fetch, even if empty
            errorMessage = nil
        } catch {
            // Ignore cancellation errors (happens when user navigates away or refreshes again)
            if error is CancellationError {
                return
            }
            // Only set error if fetch actually failed
            errorMessage = error.localizedDescription
            historyItems = []
            hasNextPage = false
            endCursor = nil
            hasLoadedInitially = true
        }

        isInitialLoading = false
    }

    func loadMore() async {
        guard !isLoadingMore, hasNextPage, let cursor = endCursor else { return }

        isLoadingMore = true

        do {
            let result = try await GraphQLClient.shared.fetchProductHistory(after: cursor)
            historyItems.append(contentsOf: result.historyItems)
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            // Clear error on successful fetch
            errorMessage = nil
        } catch {
            // Ignore cancellation errors
            if error is CancellationError {
                isLoadingMore = false
                return
            }
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    func refresh() async {
        hasLoadedInitially = false
        endCursor = nil
        hasNextPage = false
        historyItems = []
        errorMessage = nil
        await fetchHistory()
    }

    func removeHistoryItem(_ historyId: Int) async {
        do {
            let result = try await GraphQLClient.shared.removeProductHistoryItem(historyId: historyId)
            if result.success {
                historyItems.removeAll { $0.id == historyId }
            } else {
                errorMessage = result.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
