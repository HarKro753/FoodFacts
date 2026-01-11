//
//  ProductDetail.swift
//  YukaMock
//
//  Created by Harro Krog on 08.11.25.
//

import NetworkImage
import SwiftUI
import Models
import Env

// MARK: - Product Detail View
struct ProductDetail: View {
    @State private var viewModel: ProductDetailManager
    @State private var showRatingDetails = false
    @State private var showFullscreenImage = false

    enum DetailTab: String, CaseIterable {
        case nutrition = "Nutrition"
        case ingredients = "Ingredients"
    }

    init(product: Product) {
        _viewModel = State(
            wrappedValue: ProductDetailManager(
                productCode: product.id,
                product: product
            )
        )
    }

    init(productCode: Int) {
        _viewModel = State(
            wrappedValue: ProductDetailManager(productCode: productCode)
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoadingProduct {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading product...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage = viewModel.getErrorMessage(),
                viewModel.product == nil
            {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    Text("Error loading product")
                        .font(.headline)

                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else if let product = viewModel.product {
                ScrollView {
                    ProductDetailSharedContent(
                        product: product,
                        alternatives: viewModel.alternatives,
                        showFullscreenImage: $showFullscreenImage,
                        showRatingDetails: $showRatingDetails
                    )
                }
                .fullScreenCover(isPresented: $showFullscreenImage) {
                    FullscreenImageView(
                        imageUrl: product.imageUrl,
                        isPresented: $showFullscreenImage
                    )
                }
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
        .task {
            await viewModel.fetchProduct()
            await viewModel.fetchAlternatives()
        }
    }
}

// MARK: - Shared Product Detail Content (Reusable)
struct ProductDetailSharedContent: View {
    let product: Product
    let alternatives: [Product]
    @Binding var showFullscreenImage: Bool
    @Binding var showRatingDetails: Bool

    @State private var showAdditivesSheet = false

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                // Product Header
                HStack(alignment: .top, spacing: 20) {
                    Group {
                        if let imageUrl = product.imageUrl,
                            let url = URL(string: imageUrl)
                        {
                            NetworkImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
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
                    .onTapGesture {
                        showFullscreenImage = true
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name ?? "Unknown Product")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Text(product.brand ?? "Unknown Brand")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .padding(.bottom, 12)

                        HStack(alignment: .center, spacing: 8) {
                            if product.nutriScore != nil {
                                Circle()
                                    .fill(product.ratingColor)
                                    .frame(width: 12, height: 12)

                                VStack(spacing: 2) {
                                    Text("\(product.nutriScore!)/100")
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
                    }
                    .frame(height: 110, alignment: .top)

                    Spacer()
                }
                .padding(.horizontal, 16)

                //MARK: Positive Traits
                if !product.positiveNutrientRatings.isEmpty
                    || (product.additivesRatings != nil
                        && isPositiveAdditive(product.additivesRatings!))
                {
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
                        .background(Color(.systemBackground))

                        ForEach(product.positiveNutrientRatings) { rating in
                            ProductDetailNutritionRowItem(
                                icon: rating.icon,
                                trait: rating.name,
                                traitDescription: rating.text,
                                amount: rating.formattedValue,
                                color: rating.ratingColor,
                                ratingSections: rating.ratingSections,
                                currentValue: rating.value
                            )
                        }

                        if let additivesRating = product.additivesRatings,
                            isPositiveAdditive(additivesRating)
                        {
                            ProductDetailAdditiveRowItem(
                                additivesRating: additivesRating,
                                showAdditivesSheet: $showAdditivesSheet
                            )
                        }
                    }
                    .padding(.top, 8)
                }

                //MARK: Negative Traits
                if !product.negativeNutrientRatings.isEmpty
                    || (product.additivesRatings != nil
                        && !isPositiveAdditive(product.additivesRatings!))
                {
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
                        .background(Color(.systemBackground))

                        ForEach(product.negativeNutrientRatings) { rating in
                            ProductDetailNutritionRowItem(
                                icon: rating.icon,
                                trait: rating.name,
                                traitDescription: rating.text,
                                amount: rating.formattedValue,
                                color: rating.ratingColor,
                                ratingSections: rating.ratingSections,
                                currentValue: rating.value
                            )
                        }

                        if let additivesRating = product.additivesRatings,
                            !isPositiveAdditive(additivesRating)
                        {
                            ProductDetailAdditiveRowItem(
                                additivesRating: additivesRating,
                                showAdditivesSheet: $showAdditivesSheet
                            )
                        }
                    }
                    .padding(.top, 8)
                }

                //MARK: Alternatives
                if !alternatives.isEmpty {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Alternatives")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(alternatives) { alternativeProduct in
                                    NavigationLink(
                                        destination: ProductDetail(
                                            product: alternativeProduct
                                        )
                                    ) {
                                        AlternativeProductCard(
                                            product: alternativeProduct
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .padding(.top, 8)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(
                        "We rate products based on nutritional value, ingredient quality, and processing level."
                    )
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
            .background(Color(.systemBackground))

        }
        .sheet(isPresented: $showAdditivesSheet) {
            if let additivesRating = product.additivesRatings {
                AdditivesListSheet(additives: additivesRating.additives)
            }
        }
    }

    private func isPositiveAdditive(_ additiveRating: AdditiveRating) -> Bool {
        return additiveRating.rating == "VERY_GOOD"
            || additiveRating.rating == "GOOD"
    }
}

// MARK: - Alternative Product Card
struct AlternativeProductCard: View {
    let product: Product

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Group {
                if let imageUrl = product.imageUrl,
                    let url = URL(string: imageUrl)
                {
                    NetworkImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.gray.opacity(0.2))

                        Image(systemName: "photo")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 80, height: 120)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name ?? "Unknown Product")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(product.brand ?? "Unknown Brand")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.bottom, 8)

                HStack(alignment: .center, spacing: 8) {
                    if product.nutriScore != nil {
                        Circle()
                            .fill(product.ratingColor)
                            .frame(width: 10, height: 10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(product.nutriScore!)/100")
                                .font(.system(size: 15))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            Text(product.overallRatingText)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .frame(width: UIScreen.main.bounds.width * 0.8)
        .background(Color(.systemBackground))
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
                            description:
                                "We analyze the macronutrient balance, vitamin and mineral content, and overall nutritional density."
                        )

                        RatingCriteriaRow(
                            icon: "leaf.fill",
                            title: "Ingredient Quality",
                            description:
                                "We evaluate the quality and origin of ingredients, prioritizing organic and natural components."
                        )

                        RatingCriteriaRow(
                            icon: "gear",
                            title: "Processing Level",
                            description:
                                "We assess how processed the product is, favoring minimally processed foods with fewer additives."
                        )
                    }

                    Text(
                        "Each criterion is weighted and combined to produce a final score out of 100."
                    )
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

// MARK: - Fullscreen Image View
struct FullscreenImageView: View {
    let imageUrl: String?
    @Binding var isPresented: Bool

    @State private var dragOffset: CGSize = .zero
    @State private var backgroundOpacity: Double = 1.0

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissView()
                }

            if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                NetworkImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                            // Adjust background opacity based on drag distance
                            let dragDistance = sqrt(
                                pow(value.translation.width, 2)
                                    + pow(value.translation.height, 2)
                            )
                            backgroundOpacity = max(
                                0.0,
                                1.0 - dragDistance / 500
                            )
                        }
                        .onEnded { value in
                            let dragDistance = sqrt(
                                pow(value.translation.width, 2)
                                    + pow(value.translation.height, 2)
                            )
                            if dragDistance > 150 {
                                dismissView()
                            } else {
                                withAnimation(
                                    .spring(response: 0.4, dampingFraction: 0.8)
                                ) {
                                    dragOffset = .zero
                                    backgroundOpacity = 1.0
                                }
                            }
                        }
                )
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No image available")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
            }

            VStack {
                HStack {
                    Button(action: {
                        dismissView()
                    }) {
                        ZStack {
                            // Glassmorphism background
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)

                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(20)

                    Spacer()
                }
                Spacer()
            }
        }
    }

    private func dismissView() {
        dragOffset = .zero
        backgroundOpacity = 1.0
        isPresented = false
    }
}
