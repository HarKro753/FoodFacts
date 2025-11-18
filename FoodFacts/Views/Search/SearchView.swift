//
//  SearchView.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import Combine
import NetworkImage
import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var viewModel: SearchViewModel
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                switch viewModel.searchState {
                case .idle:
                    // Show horizontal scrollable label categories
                    LabelCategoriesView(
                        viewModel: viewModel,
                        navigationPath: $navigationPath
                    )

                case .searching, .searchResults, .loadingMore, .error:
                    SearchResultsView(viewModel: viewModel)
                }
            }
            .navigationTitle("Suche")
            .searchable(
                text: $viewModel.searchText,
                placement: .automatic,
                prompt: "Search products..."
            )
            .onSubmit(of: .search) {
                Task {
                    await viewModel.onSearchSubmit()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    FilterMenuButton(viewModel: viewModel)
                }
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetail(product: product)
            }
            .navigationDestination(for: ProductCategoryData.self) { category in
                CategoryProductsList(category: category)
            }
        }
    }
}

// MARK: - Search Results View

struct SearchResultsView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        Group {
            switch viewModel.searchState {
            case .searching:
                // Show loading placeholders
                List {
                    ForEach(0..<8, id: \.self) { _ in
                        ProductListItemPlaceholder()
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

            case .error(let errorMessage):
                // Show error view
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
                }

            case .searchResults, .loadingMore:
                // Show results or no results
                if viewModel.products.isEmpty {
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
                                // Load more when reaching the 5th item from the end
                                if index == viewModel.products.count - 5 {
                                    Task {
                                        await viewModel.loadMore()
                                    }
                                }
                            }
                        }

                        if case .loadingMore = viewModel.searchState {
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

            default:
                EmptyView()
            }
        }
    }
}

//MARK: CategoryView

struct LabelCategoriesView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Binding var navigationPath: NavigationPath

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(ProductCategoryData.categories.filter { viewModel.shouldShowCategory($0.id) }) { category in
                    VStack(spacing: 0) {
                        // Header - always shown
                        Button(action: {
                            // Only allow navigation if products are loaded
                            if let products = viewModel.categoryProducts[category.id],
                                !products.isEmpty
                            {
                                navigationPath.append(category)
                            }
                        }) {
                            HStack {
                                Text(category.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.gray)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                        }
                        .buttonStyle(.plain)
                        .disabled(
                            viewModel.categoryProducts[category.id]?.isEmpty ?? true
                        )

                        // Horizontal scrolling products or placeholders
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 12) {
                                if let products = viewModel.categoryProducts[
                                    category.id
                                ], !products.isEmpty {
                                    // Show actual products
                                    ForEach(products) { product in
                                        Button(action: {
                                            navigationPath.append(product)
                                        }) {
                                            ProductCard(product: product)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                } else {
                                    // Show placeholders while loading or not yet fetched
                                    ForEach(0..<5, id: \.self) { _ in
                                        LabelProductCardPlaceholder()
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                    }
                    .background(Color(.systemBackground))
                    .id("\(category.id)-\(viewModel.filterStateId)")
                    .task(id: viewModel.filterStateId) {
                        // Fetch products when category appears or filters change
                        await viewModel.fetchProductsForCategory(category)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Filter Menu Button

struct FilterMenuButton: View {
    @ObservedObject var viewModel: SearchViewModel

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

#Preview {
    SearchView()
}
