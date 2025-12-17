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

struct SearchView: View {
    @EnvironmentObject private var viewModel: SearchViewModel
    @State private var navigationPath = NavigationPath()
    @State private var isSearching = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.shouldShowCompletions {
                    CompletionView(
                        viewModel: viewModel,
                        navigationPath: $navigationPath
                    )
                } else {
                    switch viewModel.searchState {
                    case .idle:
                        ExploreView(
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

struct CompletionView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Binding var navigationPath: NavigationPath

    var body: some View {
        List {
            if let completions = viewModel.completions {

                ForEach(completions.productNames) { product in
                    CompletionRow(
                        icon: "cube.box.fill",
                        iconColor: .gray,
                        name: product.name,
                        searchText: viewModel.searchText
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.clearCompletions()
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
                        searchText: viewModel.searchText
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.clearCompletions()

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
                        searchText: viewModel.searchText
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.clearCompletions()

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
                        .buttonStyle(PressScaleButtonStyle())
                        .disabled(
                            viewModel.categoryProducts[category.id]?.isEmpty
                                ?? true
                        )

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(alignment: .top, spacing: 12) {
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

// MARK: - Press Scale Button

struct PressScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.7

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(
                .spring(response: 0.2, dampingFraction: 0.7),
                value: configuration.isPressed
            )
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
