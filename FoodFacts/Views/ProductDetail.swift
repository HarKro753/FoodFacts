//
//  ProductDetail.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import SwiftUI

// MARK: - Product Detail View
struct ProductDetail: View {
    let product: Product

    @State private var selectedTab: DetailTab = .nutrition
    @State private var showRatingDetails = false

    enum DetailTab: String, CaseIterable {
        case nutrition = "Nutrition"
        case ingredients = "Ingredients"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 16) {
                    // Product Header
                    HStack(alignment: .top, spacing: 20) {
                        Group {
                            if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                                CachedAsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 0)
                                            .fill(Color.gray.opacity(0.2))
                                        ProgressView()
                                    }
                                }
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 0)
                                        .fill(Color.gray.opacity(0.2))
                                    Image(systemName: "photo")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .frame(width: 100, height: 120)
                        .clipped()

                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.name ?? "Unknown Product")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            Text(product.brand ?? "Unknown Brand")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .padding(.bottom, 12)

                            HStack(alignment: .center, spacing: 8) {
                                Circle()
                                    .fill(product.ratingColor)
                                    .frame(width: 12, height: 12)

                                VStack(spacing: 2) {
                                    Text("\(product.overallRating)/100")
                                        .font(.system(size: 15))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    Text(product.overallRatingText)
                                        .font(.system(size: 15))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .frame(height: 110, alignment: .top)

                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    // Tab Picker
                    Picker("Kategorie", selection: $selectedTab) {
                        ForEach(DetailTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                //MARK: Positive Traits
                if !product.positiveNutrientRatings.isEmpty {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Positive")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("pro 100g")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.white))

                        ForEach(product.positiveNutrientRatings) { rating in
                            KategorieRowItem(
                                icon: rating.icon,
                                trait: rating.name,
                                traitDescription: rating.text,
                                amount: rating.formattedValue,
                                color: rating.ratingColor,
                                ratingSections: rating.ratingSections,
                                currentValue: rating.actualValue
                            )
                        }
                    }
                    .padding(.top, 8)
                }

                //MARK: Negative Traits
                if !product.negativeNutrientRatings.isEmpty {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Negative")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("pro 100g")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.white))

                        ForEach(product.negativeNutrientRatings) { rating in
                            KategorieRowItem(
                                icon: rating.icon,
                                trait: rating.name,
                                traitDescription: rating.text,
                                amount: rating.formattedValue,
                                color: rating.ratingColor,
                                ratingSections: rating.ratingSections,
                                currentValue: rating.actualValue
                            )
                        }
                    }
                    .padding(.top, 8)
                }

                //MARK: Alternatives
                VStack(spacing: 0) {
                    HStack {
                        Text("Alternatives")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.white))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<5, id: \.self) { _ in
                                AlternativeProductCard()
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("We rate products based on nutritional value, ingredient quality, and processing level.")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)

                        Button(action: {
                            showRatingDetails = true
                        }) {
                            Text("See full details")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(Color(.white))

                //MARK: Options Section
                VStack(spacing: 0) {
                    HStack {
                        Text("Options")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))

                    VStack(spacing: 0) {
                        OptionButton(icon: "heart", title: "Add to favorites")
                        Divider().padding(.leading, 52)

                        OptionButton(icon: "person.crop.circle", title: "Personal preferences")
                        Divider().padding(.leading, 52)

                        OptionButton(icon: "trash", title: "Remove from history")
                    }
                }
                .padding(.top, 8)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Share action
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showRatingDetails) {
            RatingDetailsSheet()
        }
    }
}

// MARK: - Alternative Product Card
struct AlternativeProductCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 100)

                Image(systemName: "photo")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Alternative Product")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text("Brand Name")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.bottom, 8)

                HStack(alignment: .center, spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("85/100")
                            .font(.system(size: 15))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Text("Excellent")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .frame(width: UIScreen.main.bounds.width * 0.8)
        .background(Color(.white))
    }
}

// MARK: - Option Button Component
struct OptionButton: View {
    let icon: String
    let title: String

    var body: some View {
        Button(action: {
            // No implementation yet
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.gray)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rating Details Sheet
struct RatingDetailsSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("How We Rate Products")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)

                    Text("Our rating system is based on three main criteria:")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        RatingCriteriaRow(
                            icon: "chart.bar.fill",
                            title: "Nutritional Value",
                            description: "We analyze the macronutrient balance, vitamin and mineral content, and overall nutritional density."
                        )

                        RatingCriteriaRow(
                            icon: "leaf.fill",
                            title: "Ingredient Quality",
                            description: "We evaluate the quality and origin of ingredients, prioritizing organic and natural components."
                        )

                        RatingCriteriaRow(
                            icon: "gear",
                            title: "Processing Level",
                            description: "We assess how processed the product is, favoring minimally processed foods with fewer additives."
                        )
                    }

                    Text("Each criterion is weighted and combined to produce a final score out of 100.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Rating Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Rating Criteria Row
struct RatingCriteriaRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))

                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProductDetail(product: Product.sampleProduct)
    }
}
