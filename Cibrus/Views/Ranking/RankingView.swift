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
                // Food Groups List
                Section {
                    if selectedCategory == .lebensmittel {
                        if viewModel.isLoading || (viewModel.foodGroups.isEmpty && viewModel.errorMessage != nil) {
                            // Show placeholders while loading or on error
                            ForEach(0..<8, id: \.self) { index in
                                FoodGroupRowItemPlaceholder()
                            }
                        } else if viewModel.foodGroups.isEmpty {
                            HStack {
                                Spacer()
                                Text("No food groups found")
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        } else {
                            ForEach(viewModel.foodGroups) { foodGroup in
                                NavigationLink {
                                    ProductRankingList(
                                        foodGroupId: foodGroup.id,
                                        foodGroupName: foodGroup.name
                                    )
                                } label: {
                                    FoodGroupRowItem(foodGroup: foodGroup)
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
            .refreshable {
                await viewModel.refresh()
            }
            .navigationTitle("Ranking")
            .task {
                await viewModel.fetchFoodGroups()
            }
        }
    }
}

//MARK: Food Group Row Item

struct FoodGroupRowItem: View {
    let foodGroup: FoodGroup

    var body: some View {
        HStack {
            Image(foodGroup.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            Text(foodGroup.name)
        }
    }
}

struct FoodGroupRowItemPlaceholder: View {
    var body: some View {
        HStack(spacing: 12) {
            // Icon placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 32, height: 32)
                .shimmering()

            // Text placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 16)
                .shimmering()
        }
        .padding(.vertical, 4)
    }
}

//MARK: Liste

/**
Die Liste welche geoefnfet wird wenn man clickt
**/
struct ProductRankingList: View {
    let foodGroupId: Int
    let foodGroupName: String

    @StateObject private var viewModel: ProductRankingViewModel

    init(foodGroupId: Int, foodGroupName: String) {
        self.foodGroupId = foodGroupId
        self.foodGroupName = foodGroupName
        self._viewModel = StateObject(wrappedValue: ProductRankingViewModel(foodGroupId: foodGroupId))
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
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .navigationTitle(foodGroupName)
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
