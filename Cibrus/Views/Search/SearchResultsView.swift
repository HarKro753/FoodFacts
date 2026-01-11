//
//  SearchResultsView.swift
//  Cibrus - Product Scanner
//
//  Created by Harro Krog on 11.01.26.
//

import Combine
import Env
import GraphQl
import Models
import NetworkImage
import SwiftUI

struct SearchResultsView: View {
    @Environment(SearchManager.self) private var manager

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            Group {
                switch manager.getSearchState() {
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
                    if manager.getProducts().isEmpty {
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
                                Array(manager.getProducts().enumerated()),
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
                                    if index == manager.getProducts().count - 5
                                    {
                                        Task {
                                            await manager.loadMore()
                                        }
                                    }
                                }
                            }

                            if case .loadingMore = manager.getSearchState() {
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
}
