//
//  HistoryView.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var viewModel: HistoryViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isInitialLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading history...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else if let errorMessage = viewModel.errorMessage,
                    viewModel.historyItems.isEmpty
                {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(.orange)

                        Text("Error loading history")
                            .font(.headline)

                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Try Again") {
                            Task {
                                await viewModel.fetchHistory()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else if viewModel.historyItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        Text("No history yet")
                            .font(.headline)

                        Text("Your scanned products will appear here")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List {
                        ForEach(
                            Array(viewModel.historyItems.enumerated()),
                            id: \.element.id
                        ) { index, historyItem in
                            if let product = historyItem.product {
                                NavigationLink(destination: ProductDetail(product: product)) {
                                    ListRowItem(
                                        product: product,
                                        timeAgo: formatTimeAgo(historyItem.scannedAt)
                                    )
                                }
                                .listRowInsets(
                                    EdgeInsets(
                                        top: 0,
                                        leading: 16,
                                        bottom: 0,
                                        trailing: 16
                                    )
                                )
                                .swipeActions(
                                    edge: .trailing,
                                    allowsFullSwipe: true
                                ) {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.removeHistoryItem(
                                                historyItem.id
                                            )
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .onAppear {
                                    // Load more when reaching the 5th item from the end
                                    if index == viewModel.historyItems.count - 5 {
                                        Task {
                                            await viewModel.loadMore()
                                        }
                                    }
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(
                                            "Product Code: \(historyItem.productCode)"
                                        )
                                        .font(.headline)
                                        Spacer()
                                    }
                                    Text(formatDate(historyItem.scannedAt))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text("Product data unavailable")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                                .padding(.vertical, 8)
                                .listRowInsets(
                                    EdgeInsets(
                                        top: 0,
                                        leading: 16,
                                        bottom: 0,
                                        trailing: 16
                                    )
                                )
                                .swipeActions(
                                    edge: .trailing,
                                    allowsFullSwipe: true
                                ) {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.removeHistoryItem(
                                                historyItem.id
                                            )
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .onAppear {
                                    // Load more when reaching the 5th item from the end
                                    if index == viewModel.historyItems.count - 5 {
                                        Task {
                                            await viewModel.loadMore()
                                        }
                                    }
                                }
                            }
                        }

                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Verlauf")
            .toolbar {}
            .task {
                await viewModel.fetchHistory()
            }
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }

    private func formatTimeAgo(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return "kürzlich" // recently
        }

        let now = Date()
        let timeInterval = now.timeIntervalSince(date)

        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        let weeks = Int(timeInterval / 604800)
        let months = Int(timeInterval / 2592000)
        let years = Int(timeInterval / 31536000)

        if years > 0 {
            return years == 1 ? "vor 1 Jahr" : "vor \(years) Jahren"
        } else if months > 0 {
            return months == 1 ? "vor 1 Monat" : "vor \(months) Monaten"
        } else if weeks > 0 {
            return weeks == 1 ? "vor 1 Woche" : "vor \(weeks) Wochen"
        } else if days > 0 {
            if days == 1 {
                return "gestern"
            } else if days == 2 {
                return "vorgestern"
            } else {
                return "vor \(days) Tagen"
            }
        } else if hours > 0 {
            return hours == 1 ? "vor 1 Stunde" : "vor \(hours) Stunden"
        } else if minutes > 0 {
            return minutes == 1 ? "vor 1 Minute" : "vor \(minutes) Minuten"
        } else {
            return "gerade eben"
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(HistoryViewModel())
}
