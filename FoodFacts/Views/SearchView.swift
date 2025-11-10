//
//  SearchView.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                // Content
                Group {
                    if viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                        // Empty state - no search query
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)

                            Text("Search for Products")
                                .font(.headline)

                            Text("Enter a product name to search")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxHeight: .infinity)
                    } else if viewModel.isSearching && viewModel.products.isEmpty {
                        // Loading state
                        VStack(spacing: 16) {
                            ProgressView()
                            Text("Searching...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxHeight: .infinity)
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
                        .frame(maxHeight: .infinity)
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
                        .frame(maxHeight: .infinity)
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
            }
            .navigationTitle("Search")
            .toolbar {
                if !viewModel.searchText.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            viewModel.clearSearch()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search products...", text: $text)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    SearchView()
}
