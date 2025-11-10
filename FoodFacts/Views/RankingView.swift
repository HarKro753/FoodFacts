//
//  RankingView.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import SwiftUI
import NetworkImage

// MARK: - Main Ranking View
struct RankingView: View {
    @EnvironmentObject private var viewModel: RankingViewModel
    @State private var selectedCategory: ProductCategory = .lebensmittel

    enum ProductCategory: String, CaseIterable {
        case lebensmittel = "Lebensmittel"
        case kosmetik = "Kosmetik"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Kategorie", selection: $selectedCategory) {
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                }
                .listRowInsets(
                    EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
                )

                // Category List
                Section {
                    if selectedCategory == .lebensmittel {
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else if let errorMessage = viewModel.errorMessage,
                            viewModel.categories.isEmpty
                        {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(.orange)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else if viewModel.categories.isEmpty {
                            Text("No categories found")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.categories) { category in
                                NavigationLink {
                                    ProductRankingList(
                                        categoryId: category.id,
                                        categoryName: category.name
                                    )
                                } label: {
                                    CategoryRowItem(category: category)
                                }
                            }
                        }
                    } else {
                        // Kosmetik placeholder
                        Text("Coming soon...")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Ranking")
            .task {
                await viewModel.fetchCategories()
            }
        }
    }
}

//MARK: Liste

/**
Die Liste welche geoefnfet wird wenn man clickt
**/
struct ProductRankingList: View {
    let categoryId: Int
    let categoryName: String

    @StateObject private var viewModel: ProductRankingViewModel

    init(categoryId: Int, categoryName: String) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self._viewModel = StateObject(wrappedValue: ProductRankingViewModel(categoryId: categoryId))
    }

    var body: some View {
        Group {
            if viewModel.isInitialLoading {
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
                            await viewModel.fetchProducts()
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
                    ForEach(Array(viewModel.products.enumerated()), id: \.element.id) { index, product in
                        NavigationLink {
                            ProductDetail(product: product)
                        } label: {
                            ListRankItem(
                                rank: index + 1,
                                product: product
                            )
                        }
                        .listRowInsets(
                            EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
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
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchProducts()
        }
    }
}

#Preview {
    RankingView()
        .environmentObject(RankingViewModel())
}
