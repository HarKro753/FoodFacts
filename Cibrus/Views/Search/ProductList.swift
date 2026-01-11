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
import Env

/// This is the list which is opened from SearchView when pressing on a header.
/// It displays all the items in a certain Category, Food Group
struct ProductList: View {
    let label: ProductLabel
    @Environment(SearchManager.self) private var searchManager

    var body: some View {
        Group {
            if searchManager.getDetailIsLoading() && searchManager.getDetailProducts().isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading products...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage = searchManager.getDetailErrorMessage(),
                searchManager.getDetailProducts().isEmpty
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
                            await searchManager.fetchDetailProducts(for: label.filter)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else if searchManager.getDetailProducts().isEmpty {
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
                        Array(searchManager.getDetailProducts().enumerated()),
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
                            if index == searchManager.getDetailProducts().count - 5 {
                                Task {
                                    await searchManager.loadMoreDetailProducts()
                                }
                            }
                        }
                    }

                    if searchManager.getDetailIsLoadingMore() {
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
            await searchManager.fetchDetailProducts(for: label.filter)
        }
    }
}

struct CategoryProductsList: View {
    let category: ProductCategoryData
    @Environment(SearchManager.self) private var searchManager

    var body: some View {
        Group {
            if searchManager.getDetailIsLoading() && searchManager.getDetailProducts().isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading products...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage = searchManager.getDetailErrorMessage(),
                searchManager.getDetailProducts().isEmpty
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
                            await searchManager.fetchDetailProducts(for: category.filter)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else if searchManager.getDetailProducts().isEmpty {
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
                        Array(searchManager.getDetailProducts().enumerated()),
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
                            if index == searchManager.getDetailProducts().count - 5 {
                                Task {
                                    await searchManager.loadMoreDetailProducts()
                                }
                            }
                        }
                    }

                    if searchManager.getDetailIsLoadingMore() {
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
            await searchManager.fetchDetailProducts(for: category.filter)
        }
    }
}

// MARK: - Filter Menu Button for ProductList

struct ProductListFilterMenuButton: View {
    var searchManager: SearchManager

    var body: some View {
        Menu {
            ForEach(ProductFilter.allCases) { filter in
                Button {
                    searchManager.toggleFilterForDetail(filter)
                } label: {
                    Label {
                        Text(filter.displayName)
                    } icon: {
                        if searchManager.getActiveFiltersForDetail().contains(filter) {
                            Image(systemName: "checkmark")
                        }
                        Image(systemName: filter.icon)
                    }
                }
            }

            if !searchManager.getActiveFiltersForDetail().isEmpty {
                Divider()

                Button(role: .destructive) {
                    searchManager.clearFiltersForDetail()
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
