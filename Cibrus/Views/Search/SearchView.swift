//
//  SearchView.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import Combine
import Env
import GraphQl
import Models
import NetworkImage
import SwiftUI

struct SearchView: View {
    @Environment(SearchManager.self) private var manager
    @State private var navigationPath = NavigationPath()
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?

    private var exploreContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(
                    manager.getCategories().filter {
                        manager.shouldShowCategory($0.id)
                    }
                ) { category in
                    CategoryRow(
                        category: category,
                        navigationPath: $navigationPath,
                        manager: manager
                    )
                }
            }
        }
        .background(Color(.systemBackground))
        .overlay {
            if manager.getShouldShowCompletions() {
                CompletionView(navigationPath: $navigationPath)
            }
        }
        .overlay {
            switch manager.getSearchState() {
            case .searching, .searchResults, .loadingMore, .error:
                SearchResultsView()
            case .idle:
                EmptyView()
            }
        }
    }

    var body: some View {
        @Bindable var searchManager = manager

        NavigationStack(path: $navigationPath) {
            exploreContent
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
                .onChange(of: manager.searchText) { oldValue, newValue in
                    // Debounced search text observation
                    searchTask?.cancel()
                    let trimmedText = newValue.trimmingCharacters(
                        in: .whitespaces
                    )

                    if trimmedText.isEmpty {
                        manager.setCompletions(nil)
                        if manager.getSearchState() != .idle
                            && manager.getSearchState() != .searchResults
                            && manager.getSearchState() != .loadingMore
                        {
                            manager.setSearchState(.idle)
                        }
                    } else {
                        if manager.getSearchState() == .idle {
                            searchTask = Task {
                                try? await Task.sleep(nanoseconds: 300_000_000)
                                if !Task.isCancelled {
                                    await manager.fetchCompletions(
                                        for: trimmedText
                                    )
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
                .navigationDestination(for: ProductCategoryData.self) {
                    category in
                    CategoryProductsList(category: category)
                }
                .navigationDestination(for: ProductLabel.self) { label in
                    ProductList(label: label)
                }
                .onDisappear {
                    manager.resetToIdle()
                }
                .overlay {
                    if manager.getShouldShowCompletions() {
                        CompletionView(navigationPath: $navigationPath)
                    }
                }
                .overlay {
                    switch manager.getSearchState() {
                    case .searching, .searchResults, .loadingMore, .error:
                        SearchResultsView()
                    case .idle:
                        EmptyView()
                    }
                }
        }
    }
}

struct CategoryRow: View {
    let category: ProductCategoryData
    @Binding var navigationPath: NavigationPath
    let manager: SearchManager

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                if let products = manager.getCategoryProducts()[category.id],
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
                manager.getCategoryProducts()[category.id]?.isEmpty ?? true
            )

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 12) {
                    if let products = manager.getCategoryProducts()[
                        category.id
                    ],
                        !products.isEmpty
                    {
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
        .id("\(category.id)-\(manager.getFilterStateId())")
        .task(id: manager.getFilterStateId()) {
            await manager.fetchProductsForCategory(category)
        }
    }
}

#Preview {
    SearchView()
        .environment(SearchManager())
}
