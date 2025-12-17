//
//  LabelProductsList.swift
//  FoodFacts
//
//  Created by Harro Krog on 17.11.25.
//

import Combine
import NetworkImage
import SwiftUI
import Models

/// This is the list which is opened from SearchView when pressing on a header.
/// It displays all the items in a certain Category, Food Group
struct ProductList: View {
    let label: ProductLabel
    @StateObject private var viewModel = LabelProductsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.products.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading products...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage = viewModel.errorMessage,
                viewModel.products.isEmpty
            {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    Text("Error loading products")
                        .font(.headline)

                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Try Again") {
                        Task {
                            await viewModel.fetchProducts(for: label.filter)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else if viewModel.products.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)

                    Text("No products found")
                        .font(.headline)
                }
            } else {
                List {
                    ForEach(
                        Array(viewModel.products.enumerated()),
                        id: \.element.id
                    ) { index, product in
                        NavigationLink {
                            ProductDetail(product: product)
                        } label: {
                            ProductHistoryRowItem(product: product)
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
        .navigationTitle(label.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchProducts(for: label.filter)
        }
    }
}

struct CategoryProductsList: View {
    let category: ProductCategoryData
    @StateObject private var viewModel = LabelProductsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.products.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading products...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage = viewModel.errorMessage,
                viewModel.products.isEmpty
            {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    Text("Error loading products")
                        .font(.headline)

                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Try Again") {
                        Task {
                            await viewModel.fetchProducts(for: category.filter)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else if viewModel.products.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)

                    Text("No products found")
                        .font(.headline)
                }
            } else {
                List {
                    ForEach(
                        Array(viewModel.products.enumerated()),
                        id: \.element.id
                    ) { index, product in
                        NavigationLink {
                            ProductDetail(product: product)
                        } label: {
                            ProductSearchProductItem(product: product)
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
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchProducts(for: category.filter)
        }
    }
}

// MARK: - Filter Menu Button for ProductList

struct ProductListFilterMenuButton: View {
    @ObservedObject var viewModel: LabelProductsViewModel

    var body: some View {
        Menu {
            ForEach(ProductFilter.allCases) { filter in
                Button {
                    viewModel.toggleFilter(filter)
                } label: {
                    Label {
                        Text(filter.displayName)
                    } icon: {
                        if viewModel.activeFilters.contains(filter) {
                            Image(systemName: "checkmark")
                        }
                        Image(systemName: filter.icon)
                    }
                }
            }

            if !viewModel.activeFilters.isEmpty {
                Divider()

                Button(role: .destructive) {
                    viewModel.clearFilters()
                } label: {
                    Label("Clear All Filters", systemImage: "xmark.circle.fill")
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 22))
                .foregroundStyle(.primary)

        }
    }
}
