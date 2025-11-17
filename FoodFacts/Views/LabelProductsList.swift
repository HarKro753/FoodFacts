//
//  LabelProductsList.swift
//  FoodFacts
//
//  Created by Harro Krog on 17.11.25.
//


import SwiftUI
import NetworkImage
import Combine

struct LabelProductsList: View {
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
            } else if let errorMessage = viewModel.errorMessage, viewModel.products.isEmpty {
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
                            await viewModel.fetchProducts(for: label.id)
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
                            ProductHistoryRowItem(product: product)
                        }
                        .listRowInsets(
                            EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                        )
                        .onAppear {
                            if index == viewModel.products.count - 5 {
                                Task {
                                    await viewModel.loadMore(for: label.id)
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
            await viewModel.fetchProducts(for: label.id)
        }
    }
}
