//
//  CompletionView.swift
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

struct CompletionView: View {
    @Environment(SearchManager.self) private var manager
    @Binding var navigationPath: NavigationPath

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            List {
                if let completions = manager.getCompletions() {

                    ForEach(completions.productNames) { product in
                        CompletionRow(
                            icon: "cube.box.fill",
                            iconColor: .gray,
                            name: product.name,
                            searchText: manager.searchText
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            manager.clearCompletions()
                            navigationPath.append(product.id)
                        }
                        .listRowInsets(
                            EdgeInsets(
                                top: 4,
                                leading: 16,
                                bottom: 4,
                                trailing: 16
                            )
                        )
                    }

                    ForEach(completions.categoryNames) { category in
                        CompletionRow(
                            icon: "tag.fill",
                            iconColor: .gray,
                            name: category.name,
                            searchText: manager.searchText
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            manager.clearCompletions()

                            let categoryData = ProductCategoryData(
                                id: category.id,
                                name: category.name,
                                filter: .category(id: category.id)
                            )

                            navigationPath.append(categoryData)
                        }
                        .listRowInsets(
                            EdgeInsets(
                                top: 4,
                                leading: 16,
                                bottom: 4,
                                trailing: 16
                            )
                        )
                    }

                    ForEach(completions.foodGroups) { foodGroup in
                        CompletionRow(
                            icon: "leaf.fill",
                            iconColor: .gray,
                            name: foodGroup.name,
                            searchText: manager.searchText
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            manager.clearCompletions()

                            let label = ProductLabel(
                                id: foodGroup.id,
                                name: foodGroup.name,
                                filter: .foodGroup(id: foodGroup.id)
                            )

                            navigationPath.append(label)
                        }
                        .listRowInsets(
                            EdgeInsets(
                                top: 4,
                                leading: 16,
                                bottom: 4,
                                trailing: 16
                            )
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
}
