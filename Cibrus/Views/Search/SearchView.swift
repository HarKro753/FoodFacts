//
//  SearchView.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import Combine
import NetworkImage
import SwiftUI
import Models
import GraphQl
import Env

struct SearchView: View {
    @Environment(SearchManager.self) private var manager
    @State private var navigationPath = NavigationPath()
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        @Bindable var searchManager = manager

        NavigationStack(path: $navigationPath) {
            Group {
                if manager.shouldShowCompletions {
                    CompletionView(
                        manager: manager,
                        navigationPath: $navigationPath
                    )
                } else {
                    switch manager.searchState {
                    case .idle:
                        ExploreView(
                            manager: manager,
                            navigationPath: $navigationPath
                        )

                    case .searching, .searchResults, .loadingMore, .error:
                        SearchResultsView(manager: manager)
                    }
                }
            }
            .navigationTitle("Suche")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $searchManager.searchText,
                isPresented: $isSearching,
                placement: .automatic,
                prompt: "Search products..."
            )
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onChange(of: searchManager.searchText) { oldValue, newValue in
                // Debounced search text observation
                searchTask?.cancel()
                let trimmedText = newValue.trimmingCharacters(in: .whitespaces)

                if trimmedText.isEmpty {
                    manager.completions = nil
                    if manager.searchState != .idle
                        && manager.searchState != .searchResults
                        && manager.searchState != .loadingMore
                    {
                        manager.searchState = .idle
                    }
                } else {
                    if manager.searchState == .idle {
                        searchTask = Task {
                            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
                            if !Task.isCancelled {
                                await manager.fetchCompletions(for: trimmedText)
                            }
                        }
                    }
                }
            }
            .onChange(of: isSearching) { oldValue, newValue in
                // When search is dismissed (cancel button pressed)
                if !newValue && oldValue {
                    manager.resetToIdle()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    FilterMenuButton()
                }
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetail(product: product)
            }
            .navigationDestination(for: Int.self) { productCode in
                ProductDetail(productCode: productCode)
            }
            .navigationDestination(for: ProductCategoryData.self) { category in
                CategoryProductsList(category: category)
            }
            .navigationDestination(for: ProductLabel.self) { label in
                ProductList(label: label)
            }
            .onDisappear {
                manager.resetToIdle()
            }
        }
    }
}

// MARK: - Search Results View

struct SearchResultsView: View {
    var manager: SearchManager

    var body: some View {
        Group {
            switch manager.searchState {
            case .searching:
                List {
                    ForEach(0..<8, id: \.self) { _ in
                        ProductSearchItemPlaceholder()
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
                if manager.products.isEmpty {
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
                    List {
                        ForEach(
                            Array(manager.products.enumerated()),
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
                                if index == manager.products.count - 5 {
                                    Task {
                                        await manager.loadMore()
                                    }
                                }
                            }
                        }

                        if case .loadingMore = manager.searchState {
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

// MARK: - TextCompletionView

struct CompletionView: View {
    var manager: SearchManager
    @Binding var navigationPath: NavigationPath

    var body: some View {
        List {
            if let completions = manager.completions {

                ForEach(completions.productNames) { product in
                    CompletionRow(
                        icon: "cube.box.fill",
                        iconColor: .gray,
                        name: product.name,
                        searchText: manager.searchText
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        manager.clearCompletions()
                        navigationPath.append(product.id)
                    }
                    .listRowInsets(
                        EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
                    )
                }

                ForEach(completions.categoryNames) { category in
                    CompletionRow(
                        icon: "tag.fill",
                        iconColor: .gray,
                        name: category.name,
                        searchText: manager.searchText
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        manager.clearCompletions()

                        let categoryData = ProductCategoryData(
                            id: category.id,
                            name: category.name,
                            filter: .category(id: category.id)
                        )

                        navigationPath.append(categoryData)
                    }
                    .listRowInsets(
                        EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
                    )
                }

                ForEach(completions.foodGroups) { foodGroup in
                    CompletionRow(
                        icon: "leaf.fill",
                        iconColor: .gray,
                        name: foodGroup.name,
                        searchText: manager.searchText
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        manager.clearCompletions()

                        let label = ProductLabel(
                            id: foodGroup.id,
                            name: foodGroup.name,
                            filter: .foodGroup(id: foodGroup.id)
                        )

                        navigationPath.append(label)
                    }
                    .listRowInsets(
                        EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
                    )
                }

            } else {
                ForEach(0..<10, id: \.self) { _ in
                    CompletionRowPlaceholder()
                        .listRowInsets(
                            EdgeInsets(
                                top: 4,
                                leading: 16,
                                bottom: 4,
                                trailing: 16
                            )
                        )
                }
            }
        }
        .listStyle(.plain)
    }
}

//MARK: ExploreView

struct ExploreView: View {
    var manager: SearchManager
    @Binding var navigationPath: NavigationPath

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(
                    manager.categories.filter {
                        manager.shouldShowCategory($0.id)
                    }
                ) { category in
                    VStack(spacing: 0) {
                        Button(action: {
                            if let products = manager.categoryProducts[
                                category.id
                            ],
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
                            manager.categoryProducts[category.id]?.isEmpty
                                ?? true
                        )

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(alignment: .top, spacing: 12) {
                                if let products = manager.categoryProducts[
                                    category.id
                                ], !products.isEmpty {
                                    ForEach(products) { product in
                                        Button(action: {
                                            navigationPath.append(product)
                                        }) {
                                            ProductCard(product: product)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                } else {
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
                    .id("\(category.id)-\(manager.filterStateId)")
                    .task(id: manager.filterStateId) {
                        await manager.fetchProductsForCategory(category)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    SearchView()
        .environment(SearchManager())
}
