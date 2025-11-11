//
//  SearchView.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject private var viewModel = SearchViewModel.shared

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                    // Empty state - show placeholder items
                    List {
                        ForEach(0..<8, id: \.self) { _ in
                            ListRowItemPlaceholder()
                                .listRowInsets(
                                    EdgeInsets(
                                        top: 0,
                                        leading: 16,
                                        bottom: 0,
                                        trailing: 16
                                    )
                                )
                        }
                    }
                    .listStyle(.plain)
                } else if viewModel.isSearching && viewModel.products.isEmpty {
                    // Loading state - show placeholder items
                    List {
                        ForEach(0..<8, id: \.self) { _ in
                            ListRowItemPlaceholder()
                                .listRowInsets(
                                    EdgeInsets(
                                        top: 0,
                                        leading: 16,
                                        bottom: 0,
                                        trailing: 16
                                    )
                                )
                        }
                    }
                    .listStyle(.plain)
                } else if let errorMessage = viewModel.errorMessage,
                          viewModel.products.isEmpty {
                    // Error state
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(.orange)

                        Text("Error searching products")
                            .font(.headline)

                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Try Again") {
                            Task {
                                await viewModel.performSearch(query: viewModel.searchText)
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else if viewModel.products.isEmpty {
                    // No results state
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        Text("No Products Found")
                            .font(.headline)

                        Text("Try a different search term")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // Results list
                    List {
                        ForEach(Array(viewModel.products.enumerated()), id: \.element.id) { index, product in
                            NavigationLink {
                                ProductDetail(product: product)
                            } label: {
                                ListRowItem(product: product)
                            }
                            .listRowInsets(
                                EdgeInsets(
                                    top: 0,
                                    leading: 16,
                                    bottom: 0,
                                    trailing: 16
                                )
                            )
                            .onAppear {
                                // Load more when reaching the 5th item from the end
                                if index == viewModel.products.count - 5 {
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
                }
            }
            .navigationTitle("Suche")
            .searchable(
                text: $viewModel.searchText,
                placement: .automatic,
                prompt: "Search products..."
            )
        }
    }
}

#Preview {
    SearchView()
}
