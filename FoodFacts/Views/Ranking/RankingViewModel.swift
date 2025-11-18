//
//  RankingViewModel.swift
//  YukaMock
//
//  Created by Harro Krog on 10.11.25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class RankingViewModel: ObservableObject {
    @Published var foodGroups: [FoodGroup] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var hasLoadedInitially = false

    struct FoodGroupStyle {
        let imageName: String
        let color: Color
    }

    private let foodGroupStyleMap: [String: FoodGroupStyle] = [
        "Composite foods": FoodGroupStyle(imageName: "Food Color Hand Drawn", color: .orange),
        "Sandwiches": FoodGroupStyle(imageName: "Hamburger Color Hand Drawn", color: .brown),
        "Fish‚ Meat‚ Eggs": FoodGroupStyle(imageName: "Meat Color Hand Drawn", color: .blue),
        "Processed meat": FoodGroupStyle(imageName: "Sausage Color Hand Drawn", color: .red),
        "Beverages": FoodGroupStyle(imageName: "Cola Color Hand Drawn", color: .cyan),
        "Sweetened beverages": FoodGroupStyle(imageName: "Shake Shack Color Hand Drawn", color: .pink),
        "Sugary snacks": FoodGroupStyle(imageName: "Halloween Candy Color Hand Drawn", color: .pink),
        "Sweets": FoodGroupStyle(imageName: "Kawaii Cupcake Color Hand Drawn", color: .red),
        "Fats and sauces": FoodGroupStyle(imageName: "Butter Color Hand Drawn", color: .yellow),
        "Fats": FoodGroupStyle(imageName: "Butter Color Hand Drawn", color: .orange),
        "Cereals and potatoes": FoodGroupStyle(imageName: "Grains Of Rice Color Hand Drawn", color: .green),
        "Cereals": FoodGroupStyle(imageName: "Rice Bowl Color Hand Drawn", color: .brown),
        "Salty snacks": FoodGroupStyle(imageName: "French Fries Color Hand Drawn", color: .orange),
        "Appetizers": FoodGroupStyle(imageName: "Bento Color Hand Drawn", color: .purple),
        "Eggs": FoodGroupStyle(imageName: "Egg Color Hand Drawn", color: .yellow),
        "Dressings and sauces": FoodGroupStyle(imageName: "Soy Sauce Color Hand Drawn", color: .brown),
        "Fruit juices": FoodGroupStyle(imageName: "Infusion Pumps Color Hand Drawn", color: .orange),
        "Fruits and vegetables": FoodGroupStyle(imageName: "Vegan Food Color Hand Drawn", color: .green),
        "Vegetables": FoodGroupStyle(imageName: "Salad Color Hand Drawn", color: .green),
        "Artificially sweetened beverages": FoodGroupStyle(imageName: "Shake Shack Color Hand Drawn(2)", color: .cyan),
        "Unsweetened beverages": FoodGroupStyle(imageName: "Hot Chocolate With Marshmallows Color Hand Drawn", color: .gray),
        "Nuts": FoodGroupStyle(imageName: "Peanuts Color Hand Drawn", color: .brown),
        "Fruits": FoodGroupStyle(imageName: "Bitten Apple Color Hand Drawn", color: .red),
        "Soups": FoodGroupStyle(imageName: "Rice Bowl Color Hand Drawn", color: .orange),
        "One-dish meals": FoodGroupStyle(imageName: "Meal Color Hand Drawn", color: .purple),
        "Potatoes": FoodGroupStyle(imageName: "Potato Color Hand Drawn", color: .brown),
        "Biscuits and cakes": FoodGroupStyle(imageName: "Brownie Color Hand Drawn", color: .pink),
        "Chocolate products": FoodGroupStyle(imageName: "Brownie Color Hand Drawn", color: .brown),
        "Fish and seafood": FoodGroupStyle(imageName: "Whole Fish Color Hand Drawn", color: .blue),
        "Dried fruits": FoodGroupStyle(imageName: "Raisins Color Hand Drawn", color: .orange),
        "Milk and dairy products": FoodGroupStyle(imageName: "Pack Of Milk Color Hand Drawn", color: .cyan),
        "Milk and yogurt": FoodGroupStyle(imageName: "Pack Of Milk Color Hand Drawn", color: .white),
        "Cheese": FoodGroupStyle(imageName: "Mozzarella Color Hand Drawn", color: .yellow),
        "Alcoholic beverages": FoodGroupStyle(imageName: "Hops Color Hand Drawn", color: .purple),
        "Waters and flavored waters": FoodGroupStyle(imageName: "Infusion Pumps Color Hand Drawn", color: .blue),
        "Meat": FoodGroupStyle(imageName: "Kawaii Steak Color Hand Drawn", color: .red),
        "Meat other than poultry": FoodGroupStyle(imageName: "Ground Beef Color Hand Drawn", color: .orange),
        "Bread": FoodGroupStyle(imageName: "Bread Crumbs Color Hand Drawn", color: .brown),
        "Poultry": FoodGroupStyle(imageName: "Kawaii Steak Color Hand Drawn(2)", color: .orange),
        "Pizza pies and quiches": FoodGroupStyle(imageName: "Pizza Color Hand Drawn", color: .red),
        "Breakfast cereals": FoodGroupStyle(imageName: "Rice Bowl Color Hand Drawn", color: .orange),
        "Ice cream": FoodGroupStyle(imageName: "Banana Split Color Hand Drawn", color: .cyan),
        "Plant-based milk substitutes": FoodGroupStyle(imageName: "Oat Milk Color Hand Drawn", color: .green),
        "Fatty fish": FoodGroupStyle(imageName: "Whole Fish Color Hand Drawn", color: .blue),
        "Salty and fatty products": FoodGroupStyle(imageName: "French Fries Color Hand Drawn", color: .orange),
        "Legumes": FoodGroupStyle(imageName: "Lentil Color Hand Drawn", color: .green),
        "Fruit nectars": FoodGroupStyle(imageName: "Slice Of Watermelon Color Hand Drawn", color: .orange),
        "Pastries": FoodGroupStyle(imageName: "Merry Pie Color Hand Drawn", color: .pink),
        "Teas and herbal teas and coffees": FoodGroupStyle(imageName: "Hot Chocolate With Marshmallows Color Hand Drawn", color: .brown),
        "Dairy desserts": FoodGroupStyle(imageName: "Banana Split Color Hand Drawn", color: .pink),
    ]

    private func getStyle(for name: String) -> FoodGroupStyle {
        foodGroupStyleMap[name] ?? FoodGroupStyle(imageName: "Food Color Hand Drawn", color: .gray)
    }

    func fetchFoodGroups() async {
        guard !hasLoadedInitially else { return }

        isLoading = true
        errorMessage = nil

        do {
            let foodGroupNodes = try await GraphQLClient.shared.fetchFoodGroups()
            foodGroups = foodGroupNodes.map { node in
                let style = getStyle(for: node.name)
                return FoodGroup(
                    id: node.id,
                    name: node.name,
                    icon: style.imageName,
                    color: style.color
                )
            }
            errorMessage = nil
            hasLoadedInitially = true
        } catch {
            errorMessage = error.localizedDescription
            foodGroups = []
            hasLoadedInitially = true
        }

        isLoading = false
    }

    func refresh() async {
        errorMessage = nil

        do {
            let foodGroupNodes = try await GraphQLClient.shared.fetchFoodGroups()
            foodGroups = foodGroupNodes.map { node in
                let style = getStyle(for: node.name)
                return FoodGroup(
                    id: node.id,
                    name: node.name,
                    icon: style.imageName,
                    color: style.color
                )
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchProducts(for foodGroupId: Int, first: Int = 20, after: String? = nil) async throws -> ProductsResult {
        return try await GraphQLClient.shared.fetchProducts(
            first: first,
            after: after,
            foodGroup: foodGroupId
        )
    }
}
