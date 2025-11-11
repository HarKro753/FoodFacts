//
//  AlternativesView.swift
//  FoodFacts
//
//  Created by Harro Krog on 11.11.25.
//

import SwiftUI

struct AlternativesView: View {
    @EnvironmentObject private var viewModel: AlternativesViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isInitialLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading alternatives...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else if let errorMessage = viewModel.errorMessage,
                    viewModel.comparisons.isEmpty
                {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(.orange)

                        Text("Error loading alternatives")
                            .font(.headline)

                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Try Again") {
                            Task {
                                await viewModel.fetchAlternatives()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else if viewModel.comparisons.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        Text("No alternatives yet")
                            .font(.headline)

                        Text("Scan some products to see healthier alternatives")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(
                            Array(viewModel.comparisons.enumerated()),
                            id: \.element.id
                        ) { index, comparison in
                            VStack(spacing: 8) {
                                // Comparison Item
                                if let alternative = comparison
                                    .alternativeProduct
                                {
                                    NavigationLink {
                                        ProductDetail(product: alternative)
                                    } label: {
                                        ProductComparisonItem(
                                            originalProduct: comparison
                                                .originalProduct,
                                            alternativeProduct: alternative
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .listRowInsets(
                                EdgeInsets(
                                    top: 8,
                                    leading: 16,
                                    bottom: 8,
                                    trailing: 16
                                )
                            )
                            .onAppear {
                                // Load more when reaching the 5th item from the end
                                if index == viewModel.comparisons.count - 5 {
                                    Task {
                                        await viewModel.loadMore()
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
            .navigationTitle("Alternativen")
            .task {
                await viewModel.fetchAlternatives()
            }
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    AlternativesView()
        .environmentObject(AlternativesViewModel())
}
