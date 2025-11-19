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
    @State private var isSearching = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.shouldShowCompletions {
                    TextCompletionView(viewModel: viewModel)
                } else {
                    switch viewModel.searchState {
                    case .idle:
                        LabelCategoriesView(
                            viewModel: viewModel,
                            navigationPath: $navigationPath
                        )

                    case .searching, .searchResults, .loadingMore, .error:
                        SearchResultsView(viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("Suche")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                isPresented: $isSearching,
                placement: .automatic,
                prompt: "Search products..."
            )
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onChange(of: isSearching) { oldValue, newValue in
                // When search is dismissed (cancel button pressed)
                if !newValue && oldValue {
                    viewModel.resetToIdle()
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
            .onDisappear {
                viewModel.resetToIdle()
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

// MARK: - TextCompletionView

struct TextCompletionView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        List {
            if let completions = viewModel.completions {
                // Products
                ForEach(completions.productNames) { product in
                    Button(action: {
                        Task {
                            await viewModel.selectProductCompletion(product)
                        }
                    }) {
                        CompletionRow(
                            icon: "cube.box.fill",
                            iconColor: .gray,
                            name: product.name,
                            searchText: viewModel.searchText
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }

                // Categories
                ForEach(completions.categoryNames) { category in
                    Button(action: {
                        // Empty for now as requested
                    }) {
                        CompletionRow(
                            icon: "tag.fill",
                            iconColor: .gray,
                            name: category.name,
                            searchText: viewModel.searchText
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }

                // Food Groups
                ForEach(completions.foodGroups) { foodGroup in
                    Button(action: {
                        // Empty for now as requested
                    }) {
                        CompletionRow(
                            icon: "leaf.fill",
                            iconColor: .gray,
                            name: foodGroup.name,
                            searchText: viewModel.searchText
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
            } else {
                // Loading placeholders
                ForEach(0..<10, id: \.self) { _ in
                    CompletionRowPlaceholder()
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Completion Row

struct CompletionRow: View {
    let icon: String
    let iconColor: Color
    let name: String
    let searchText: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 20)

            highlightedText
                .lineLimit(1)

            Spacer()
        }
    }

    @ViewBuilder
    private var highlightedText: some View {
        let prefix = searchText.trimmingCharacters(in: .whitespaces)

        if !prefix.isEmpty,
           let range = name.range(of: prefix, options: [.caseInsensitive, .diacriticInsensitive]) {
            let beforeMatch = String(name[..<range.lowerBound])
            let match = String(name[range])
            let afterMatch = String(name[range.upperBound...])

            (Text(beforeMatch).foregroundColor(.secondary) +
             Text(match).foregroundColor(.primary).fontWeight(.semibold) +
             Text(afterMatch).foregroundColor(.secondary))
                .font(.system(size: 15))
        } else {
            Text(name)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Completion Row Placeholder

struct CompletionRowPlaceholder: View {
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 20, height: 16)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 15)
                .frame(maxWidth: .infinity)

            Spacer()
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
                ForEach(
                    viewModel.categories.filter {
                        viewModel.shouldShowCategory($0.id)
                    }
                ) { category in
                    VStack(spacing: 0) {
                        Button(action: {
                            if let products = viewModel.categoryProducts[
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
                            viewModel.categoryProducts[category.id]?.isEmpty
                                ?? true
                        )

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 12) {
                                if let products = viewModel.categoryProducts[
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
                    .id("\(category.id)-\(viewModel.filterStateId)")
                    .task(id: viewModel.filterStateId) {
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
        .environmentObject(SearchViewModel.shared)
}
