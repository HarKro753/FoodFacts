//
//  RankingView.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import SwiftUI

// MARK: - Main Ranking View
struct RankingView: View {
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
                        ForEach(ProductCategory.allCases, id: \.self) {
                            category in
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
                        NavigationLink {
                            ProductRankingList(
                                category: "Ice Cream",
                                icon: "frozen.dessert",
                                color: .blue
                            )
                        } label: {
                            HStack {
                                Image(systemName: "frozen.dessert")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.blue)
                                Text("Ice Cream")
                            }
                        }

                        NavigationLink {
                            ProductRankingList(
                                category: "Cereal",
                                icon: "bowl.fill",
                                color: .orange
                            )
                        } label: {
                            HStack {
                                Image(systemName: "bowl.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.orange)
                                Text("Cereal")
                            }
                        }

                        NavigationLink {
                            ProductRankingList(
                                category: "Cookies",
                                icon: "birthday.cake",
                                color: .brown
                            )
                        } label: {
                            HStack {
                                Image(systemName: "birthday.cake")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.brown)
                                Text("Cookies")
                            }
                        }
                    } else {
                        NavigationLink {
                            ProductRankingList(
                                category: "Shampoo",
                                icon: "sink",
                                color: .blue
                            )
                        } label: {
                            HStack {
                                Image(systemName: "sink")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.blue)
                                Text("Shampoo")
                            }
                        }

                        NavigationLink {
                            ProductRankingList(
                                category: "Face Cream",
                                icon: "sparkles",
                                color: .pink
                            )
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.pink)
                                Text("Face Cream")
                            }
                        }

                        NavigationLink {
                            ProductRankingList(
                                category: "Makeup",
                                icon: "paintbrush",
                                color: .purple
                            )
                        } label: {
                            HStack {
                                Image(systemName: "paintbrush")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.purple)
                                Text("Makeup")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ranking")
        }
    }
}

// MARK: - Product Ranking List View
struct ProductRankingList: View {
    let category: String
    let icon: String
    let color: Color

    var body: some View {
        List {
            ForEach(1...10, id: \.self) { index in
                NavigationLink {
//                    ProductDetail()
                } label: {
                    ListRankItem(
                        rank: index,
                        productName: "\(category) Product \(index)",
                        brandName: "Brand \(index)",
                        score: 85 - (index * 2),
                        rating: getRating(for: 85 - (index * 2))
                    )
                }
                .listRowInsets(
                    EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                )
            }
        }
        .listStyle(.plain)
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func getRating(for score: Int) -> String {
        switch score {
        case 80...100: return "Gut"
        case 60..<80: return "Mittel"
        default: return "Schlecht"
        }
    }
}

// MARK: - List Rank Item Component
struct ListRankItem: View {
    let rank: Int
    let productName: String
    let brandName: String
    let score: Int
    let rating: String

    var ratingColor: Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Product Image Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            // Rank Number
            Text("\(rank)")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)

            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(productName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(brandName)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                // Rating
                HStack(alignment: .center, spacing: 8) {
                    Circle()
                        .fill(ratingColor)
                        .frame(width: 12, height: 12)

                    VStack(spacing: 2) {
                        Text("\(score)/100")
                            .font(.system(size: 15))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Text(rating)
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .frame(height: 100, alignment: .top)
        }
        .padding(.vertical, 8)
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
    }
}

#Preview {
    RankingView()
}
