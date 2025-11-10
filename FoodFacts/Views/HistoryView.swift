//
//  HistoryView.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var viewModel: HistoryViewModel

    var body: some View {
        NavigationStack {
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
                        ForEach(viewModel.products) { product in
                            NavigationLink {
                                ProductDetail(product: product)
                            } label: {
                                ListRowItem(product: product)
                            }
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
                    .refreshable {
                        await viewModel.fetchProducts()
                    }
                }
            }
            .navigationTitle("Verlauf")
            .toolbar {}
            .task {
                await viewModel.fetchProducts()
            }
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(HistoryViewModel())
}
