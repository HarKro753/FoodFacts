//
//  RankingView.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import SwiftUI
import NetworkImage
import Models
import Env

// MARK: - Main Ranking View
struct RankingView: View {
    @Environment(RankingManager.self) private var manager
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
                        if manager.getIsLoading() || (manager.getFoodGroups().isEmpty && manager.getErrorMessage() != nil) {
                            // Show placeholders while loading or on error
                            ForEach(0..<8, id: \.self) { index in
                                FoodGroupRowItemPlaceholder()
                            }
                        } else if manager.getFoodGroups().isEmpty {
                            HStack {
                                Spacer()
                                Text("No food groups found")
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        } else {
                            ForEach(manager.getFoodGroups()) { foodGroup in
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
                await manager.refreshFoodGroups()
            }
            .navigationTitle("Ranking")
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

    @Environment(RankingManager.self) private var manager

    var body: some View {
        Group {
            if manager.getIsInitialLoading() {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading products...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage = manager.getErrorMessage(),
                manager.getProducts().isEmpty
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
                            await manager.fetchProducts()
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else if manager.getProducts().isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)

                    Text("No products found")
                        .font(.headline)
                }
            } else {
                List {
                    ForEach(Array(manager.getProducts().enumerated()), id: \.element.id) { index, product in
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
                    await manager.refreshProducts()
                }
            }
        }
        .navigationTitle(foodGroupName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            manager.setCurrentFoodGroup(foodGroupId)
            await manager.fetchProducts()
        }
    }
}

#Preview {
    RankingView()
        .environment(RankingManager())
}
