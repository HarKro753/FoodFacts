//
//  SearchViewModel.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Category Models

enum CategoryFilter: Hashable {
    case label(id: Int)
    case category(id: Int)
    case foodGroup(id: Int)
    case nutrientMin(fieldName: String, minValue: Double)
    case nutrientMax(fieldName: String, maxValue: Double)

    // Generic method to fetch products for any filter type
    func fetchProducts(first: Int = 20, after: String? = nil) async throws -> ProductsResult {
        switch self {
        case .label(let id):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                labelId: id
            )

        case .category(let id):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                categoryId: id
            )

        case .foodGroup(let id):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                foodGroup: id
            )

        case .nutrientMin(let fieldName, let minValue):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                nutrientFieldName: fieldName,
                nutrientMinValue: minValue
            )

        case .nutrientMax(let fieldName, let maxValue):
            return try await GraphQLClient.shared.fetchProducts(
                first: first,
                after: after,
                nutrientFieldName: fieldName,
                nutrientMaxValue: maxValue
            )
        }
    }
}

//Staples / Pasta / Grains
//
//Spaghetti – 319
//
//Fusilli – 1205
//
//Penne / Penne rigate – 206 / 11721
//
//Tagliatelle – 10683
//
//Tortelloni – 520
//
//Rice (Japonica / Basmati / Long grain) – 1085 / 1326 / 1038
//
//Bread rolls – 1802 / 19729
//
//Pancakes – 102 / 359
//
//Meat / Fish / Poultry
//
//Chicken breasts / Chicken cutlets – 448 / 1539
//
//Chicken drumsticks – 1537
//
//Chicken wings – 615
//
//Ground beef steaks – 1016
//
//Pork sausages – 1662 / 187
//
//Meat balls – 1547
//
//Salmon fillets / Salmon steaks – 523 / 4927
//
//Tuna fillets / Tuna chunks – 4939 / 4928
//
//Vegetables / Fruits
//
//Broccoli – 1113
//
//Cherry tomatoes – 21588
//
//Avocados – 7501
//
//Onions – 110 / 111
//
//Garlic – 572 / 571
//
//Carrots – 116 / 1494
//
//Apples – 3402
//
//Bananas – 1724
//
//Dairy / Eggs
//
//Eggs / Chicken eggs – 45 / 46 / 8250
//
//Milk / Pasteurised milks / Whole milks – 180 / 11743 / 25255
//
//Butter / Half-salted butter – 678 / 3901
//
//Mozzarella / Cow camemberts / Cheddar cheese – 963 / 19107 / 566
//
//Sweets / Snacks
//
//Chocolate bars / Milk chocolates – 146 / 147 / 527 / 31893
//
//Gummy bears – 4268
//
//Cookies / Chocolate chip cookies / Madeleines – 335 / 4846 / 1769
//
//Ice cream tubs – 520 / 3531 / 375

struct ProductCategory: Identifiable, Hashable {
    let id: Int
    let name: String
    let filter: CategoryFilter

    static let categories: [ProductCategory] = [
        // Nutrient-based categories
        ProductCategory(
            id: 0,
            name: "High Protein",
            filter: .nutrientMin(fieldName: "proteins100g", minValue: 10.0)
        ),
        ProductCategory(
            id: 1,
            name: "Less than 500 Cal",
            filter: .nutrientMax(fieldName: "energyKcal100g", maxValue: 500.0)
        ),
        ProductCategory(
            id: 2,
            name: "Vitamin A High",
            filter: .nutrientMin(fieldName: "vitaminA100g", minValue: 50.0)
        ),
        ProductCategory(
            id: 3,
            name: "Vitamin D High",
            filter: .nutrientMin(fieldName: "vitaminD100g", minValue: 5.0)
        ),
        // Label-based categories
        ProductCategory(
            id: 4,
            name: "Organic",
            filter: .label(id: 1)
        ),
        ProductCategory(
            id: 5,
            name: "No gluten",
            filter: .label(id: 5)
        ),
        ProductCategory(
            id: 6,
            name: "EU Organic",
            filter: .label(id: 11)
        ),
        ProductCategory(
            id: 7,
            name: "Vegetarian",
            filter: .label(id: 3)
        ),
        ProductCategory(
            id: 8,
            name: "Vegan",
            filter: .label(id: 4)
        ),
        ProductCategory(
            id: 9,
            name: "No GMOs",
            filter: .label(id: 6)
        ),

        // Staples / Pasta / Grains
        ProductCategory(id: 10, name: "Spaghetti", filter: .category(id: 319)),
        ProductCategory(id: 11, name: "Fusilli", filter: .category(id: 1205)),
        ProductCategory(id: 12, name: "Penne", filter: .category(id: 206)),
        ProductCategory(id: 13, name: "Penne rigate", filter: .category(id: 11721)),
        ProductCategory(id: 14, name: "Tagliatelle", filter: .category(id: 10683)),
        ProductCategory(id: 15, name: "Tortelloni", filter: .category(id: 520)),
        ProductCategory(id: 16, name: "Rice (Japonica)", filter: .category(id: 1085)),
        ProductCategory(id: 17, name: "Rice (Basmati)", filter: .category(id: 1326)),
        ProductCategory(id: 18, name: "Rice (Long grain)", filter: .category(id: 1038)),
        ProductCategory(id: 19, name: "Bread rolls", filter: .category(id: 1802)),
        ProductCategory(id: 20, name: "Pancakes", filter: .category(id: 102)),

        // Meat / Fish / Poultry
        ProductCategory(id: 21, name: "Chicken breasts", filter: .category(id: 448)),
        ProductCategory(id: 22, name: "Chicken cutlets", filter: .category(id: 1539)),
        ProductCategory(id: 23, name: "Chicken drumsticks", filter: .category(id: 1537)),
        ProductCategory(id: 24, name: "Chicken wings", filter: .category(id: 615)),
        ProductCategory(id: 25, name: "Ground beef steaks", filter: .category(id: 1016)),
        ProductCategory(id: 26, name: "Pork sausages", filter: .category(id: 1662)),
        ProductCategory(id: 27, name: "Meat balls", filter: .category(id: 1547)),
        ProductCategory(id: 28, name: "Salmon fillets", filter: .category(id: 523)),
        ProductCategory(id: 29, name: "Salmon steaks", filter: .category(id: 4927)),
        ProductCategory(id: 30, name: "Tuna fillets", filter: .category(id: 4939)),
        ProductCategory(id: 31, name: "Tuna chunks", filter: .category(id: 4928)),

        // Vegetables / Fruits
        ProductCategory(id: 32, name: "Broccoli", filter: .category(id: 1113)),
        ProductCategory(id: 33, name: "Cherry tomatoes", filter: .category(id: 21588)),
        ProductCategory(id: 34, name: "Avocados", filter: .category(id: 7501)),
        ProductCategory(id: 35, name: "Onions", filter: .category(id: 110)),
        ProductCategory(id: 36, name: "Garlic", filter: .category(id: 572)),
        ProductCategory(id: 37, name: "Carrots", filter: .category(id: 116)),
        ProductCategory(id: 38, name: "Apples", filter: .category(id: 3402)),
        ProductCategory(id: 39, name: "Bananas", filter: .category(id: 1724)),

        // Dairy / Eggs
        ProductCategory(id: 40, name: "Eggs", filter: .category(id: 45)),
        ProductCategory(id: 41, name: "Chicken eggs", filter: .category(id: 46)),
        ProductCategory(id: 42, name: "Milk", filter: .category(id: 180)),
        ProductCategory(id: 43, name: "Pasteurised milks", filter: .category(id: 11743)),
        ProductCategory(id: 44, name: "Whole milks", filter: .category(id: 25255)),
        ProductCategory(id: 45, name: "Butter", filter: .category(id: 678)),
        ProductCategory(id: 46, name: "Half-salted butter", filter: .category(id: 3901)),
        ProductCategory(id: 47, name: "Mozzarella", filter: .category(id: 963)),
        ProductCategory(id: 48, name: "Cow camemberts", filter: .category(id: 19107)),
        ProductCategory(id: 49, name: "Cheddar cheese", filter: .category(id: 566)),

        // Sweets / Snacks
        ProductCategory(id: 50, name: "Chocolate bars", filter: .category(id: 146)),
        ProductCategory(id: 51, name: "Milk chocolates", filter: .category(id: 527)),
        ProductCategory(id: 52, name: "Gummy bears", filter: .category(id: 4268)),
        ProductCategory(id: 53, name: "Cookies", filter: .category(id: 335)),
        ProductCategory(id: 54, name: "Chocolate chip cookies", filter: .category(id: 4846)),
        ProductCategory(id: 55, name: "Madeleines", filter: .category(id: 1769)),
        ProductCategory(id: 56, name: "Ice cream tubs", filter: .category(id: 375)),

        // Food Groups - commonly used groups
        ProductCategory(id: 57, name: "Composite foods", filter: .foodGroup(id: 1)),
        ProductCategory(id: 58, name: "Fruits and vegetables", filter: .foodGroup(id: 2)),
        ProductCategory(id: 59, name: "Cereals and potatoes", filter: .foodGroup(id: 3)),
        ProductCategory(id: 60, name: "Fish, Meat, Eggs", filter: .foodGroup(id: 4)),
        ProductCategory(id: 61, name: "Milk and dairy products", filter: .foodGroup(id: 5)),
        ProductCategory(id: 62, name: "Beverages", filter: .foodGroup(id: 6)),
        ProductCategory(id: 63, name: "Fats and sauces", filter: .foodGroup(id: 7)),
        ProductCategory(id: 64, name: "Sugary snacks", filter: .foodGroup(id: 8)),
    ]
}

struct ProductLabel: Identifiable, Hashable {
    let id: String
    let name: String
    let filter: CategoryFilter
}

enum SearchState: Equatable {
    case idle
    case searching
    case searchResults
    case loadingMore
    case error(String)
}

@MainActor
class SearchViewModel: ObservableObject {
    static let shared = SearchViewModel()

    // Search results
    @Published var products: [Product] = []
    @Published var searchText = ""
    @Published var searchState: SearchState = .idle
    @Published var hasNextPage = false

    // Category products
    @Published var categoryProducts: [Int: [Product]] = [:]
    @Published var loadingCategories: Set<Int> = []

    private var endCursor: String?
    private var searchTask: Task<Void, Never>?

    init() {
        // Watch for search text changes to update state
        $searchText
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }

                let trimmedText = text.trimmingCharacters(in: .whitespaces)

                if trimmedText.isEmpty && self.searchState != .idle {
                    self.searchState = .idle
                }
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    func onSearchSubmit() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        await performSearch(query: searchText)
    }

    func performSearch(query: String) async {
        searchTask?.cancel()

        endCursor = nil
        hasNextPage = false

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            products = []
            searchState = .idle
            return
        }

        searchState = .searching
        products = []

        searchTask = Task {

            do {
                let result = try await GraphQLClient.shared.fetchProducts(
                    after: nil,
                    sortAscending: true,
                    searchQuery: query
                )

                guard !Task.isCancelled else { return }

                products = result.products
                hasNextPage = result.pageInfo.hasNextPage
                endCursor = result.pageInfo.endCursor
                searchState = .searchResults
            } catch {
                guard !Task.isCancelled else { return }
                searchState = .error(error.localizedDescription)
                products = []
                hasNextPage = false
                endCursor = nil
            }
        }

        await searchTask?.value
    }

    func loadMore() async {
        guard case .searchResults = searchState,
            hasNextPage,
            let cursor = endCursor,
            !searchText.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }

        searchState = .loadingMore

        do {
            let result = try await GraphQLClient.shared.fetchProducts(
                after: cursor,
                sortAscending: true,
                searchQuery: searchText,
            )
            products.append(contentsOf: result.products)
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            searchState = .searchResults
        } catch {
            searchState = .error(error.localizedDescription)
        }
    }

    func clearSearch() {
        searchText = ""
        products = []
        searchState = .idle
        hasNextPage = false
        endCursor = nil
    }

    // MARK: - Category Products

    func fetchProductsForCategory(_ category: ProductCategory) async {
        // Skip if already loaded or currently loading
        guard categoryProducts[category.id] == nil,
              !loadingCategories.contains(category.id) else { return }

        loadingCategories.insert(category.id)

        do {
            let result = try await category.filter.fetchProducts(first: 10)
            categoryProducts[category.id] = result.products
            print("Successfully fetched \(result.products.count) products for category \(category.name)")
        } catch {
            print("Error fetching products for category \(category.name): \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("Decoding error details: \(decodingError)")
            }
            categoryProducts[category.id] = []
        }

        loadingCategories.remove(category.id)
    }

    func isLoadingCategory(_ categoryId: Int) -> Bool {
        loadingCategories.contains(categoryId)
    }

}
