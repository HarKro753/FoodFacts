//
//  AlternativeProductsList.swift
//  FoodFacts
//
//  Created by Harro Krog on 18.11.25.
//


import SwiftUI
import NetworkImage
import Models

struct AlternativeProductsList: View {
    let originalProduct: Product
    let alternatives: [Product]

    var body: some View {
        Group {
            if alternatives.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)

                    Text("No alternatives found")
                        .font(.headline)
                }
            } else {
                List {
                    ForEach(Array(alternatives.enumerated()), id: \.element.id) { index, product in
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
            }
        }
        .navigationTitle("Alternativen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Alternativen zu")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(originalProduct.name ?? "Unknown Product")
                        .font(.headline)
                        .lineLimit(1)
                }
            }
        }
    }
}
