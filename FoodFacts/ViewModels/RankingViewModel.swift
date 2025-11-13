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
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var hasLoadedInitially = false

    struct CategoryStyle {
        let icon: String
        let color: Color
        let imageName: String?
    }

    private let categoryStyles: [Int: CategoryStyle] = [
        4: CategoryStyle(icon: "leaf", color: .green, imageName: "Leaf Color Hand Drawn"), // Plant based foods and beverages
        9: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Halloween Candy Color Hand Drawn"), // Snacks
        1: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Pack Of Milk Color Hand Drawn"), // Dairies
        2: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Meat Color Hand Drawn"), // Meats and their products
        3: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Cola Color Hand Drawn"), // Beverages and beverages preparations
        6: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Soy Sauce Color Hand Drawn"), // Condiments
        53: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Cola Color Hand Drawn"), // Beverages
        10: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Meal Color Hand Drawn"), // Meals
        20: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Whole Fish Color Hand Drawn"), // Seafood
        19: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Brownie Color Hand Drawn"), // Desserts
        33: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Pancake Stack Color Hand Drawn"), // Breakfasts
        31: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Hamburger Color Hand Drawn"), // Sandwiches
        100: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Sugar Cube Color Hand Drawn"), // Sweeteners
        74: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Wheat Color Hand Drawn"), // Farming products
        261: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Halloween Candy Color Hand Drawn"), // Salted snacks
        32: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Firm Tofu Color Hand Drawn"), // Meat alternatives
        173: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Flour Color Hand Drawn"), // Cooking helpers
        29: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Egg Color Hand Drawn"), // Fish and meat and eggs
        64: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Peanut Butter Color Hand Drawn"), // Spreads
        28: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Bento Color Hand Drawn"), // Appetizers sides
        169: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Butter Color Hand Drawn"), // Fats
        231: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Merry Pie Color Hand Drawn"), // Sweet pies
        63: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "French Fries Color Hand Drawn"), // Chips and fries
        8: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Cinnamon Roll Color Hand Drawn"), // Baked goods
        36: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Salad Color Hand Drawn"), // Salads
        119: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Maple Syrup Color Hand Drawn"), // Syrups
        86: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Gingerbread House Color Hand Drawn"), // Festive foods
        1103: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Kawaii Taco Color Hand Drawn"), // Mexican dinner mixes
        71: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Merry Pie Color Hand Drawn"), // Pies
        282: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Food Cart Color Hand Drawn"), // Groceries
        37: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Potato Color Hand Drawn"), // Fried potatoes
        127: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Bread Crumbs Color Hand Drawn"), // Bread coverings
        662: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Food Color Hand Drawn"), // Food
        182: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Bento Color Hand Drawn"), // Meal kits
        9492: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Spinach Color Hand Drawn"), // Vegetables prepared processed frozen
        13798: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Meat Color Hand Drawn"), // Meat products
        1559: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Brownie Color Hand Drawn"), // Десерт
        9486: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Spinach Color Hand Drawn"), // Vegetables prepared processed shelf stable
        375: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Halloween Candy Color Hand Drawn"), // Snack bar
        490: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Dog Bowl Color Hand Drawn"), // Open Pet Food Facts
        335: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "French Fries Color Hand Drawn"), // Chips
        1641: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Dog Bowl Color Hand Drawn"), // Dog and cat food
        1259: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Vegan Food Color Hand Drawn"), // Vegan products
        266: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Raspberry Color Hand Drawn"), // Fruit snack
        557: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Farfalle Color Hand Drawn"), // tagliolini
        820: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Leaf Color Hand Drawn"), // Aliments d origine vegetale
        6480: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Organic Food Color Hand Drawn"), // Produce
        457: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Flour Color Hand Drawn"), // Baking
        19709: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Avocado Color Hand Drawn"), // fruits legumes
        1251: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Peanuts Color Hand Drawn"), // Trail mix
        97: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Meat Color Hand Drawn"), // boucherie
        1266: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Chinese Noodle Color Hand Drawn"), // Rice noodles
        827: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Cinnamon Roll Color Hand Drawn"), // boulangerie patisserie
        674: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Halloween Candy Color Hand Drawn"), // Gummy candies
        1048: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Sausage Color Hand Drawn"), // Meat snack
        2212: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Dumplings Color Hand Drawn"), // Dumplings
        931: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Halloween Candy Color Hand Drawn"), // Gummies
        3528: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Lentil Color Hand Drawn"), // Beans
        10090: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Food Color Hand Drawn"), // epicerie
        9493: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Spinach Color Hand Drawn"), // Vegetables unprepared unprocessed frozen
        9508: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Spinach Color Hand Drawn"), // Vegetables prepared processed perishable
        701: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Peanuts Color Hand Drawn"), // pralines aux cacahuetes
        10910: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Heap Of Spice Color Hand Drawn"), // epices et aromates
        963: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Organic Food Color Hand Drawn"), // Fresh foods
        24875: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Rice Bowl Color Hand Drawn"), // Prepared mixes for risotto
        441: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Leaf Color Hand Drawn"), // Alimentos de origen vegetal
        923: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Cola Color Hand Drawn"), // Soft drinks
        4475: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Raspberry Color Hand Drawn"), // Fruit spread
        320: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Ground Beef Color Hand Drawn"), // Meatballs
        1489: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Vegan Food Color Hand Drawn"), // Vegan
        1100: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Organic Food Color Hand Drawn"), // Natural organic
        563: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Cinnamon Roll Color Hand Drawn"), // boulangerie
        1937: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Cola Color Hand Drawn"), // Soft drink
        1943: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "French Fries Color Hand Drawn"), // Fried foods
        2973: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Heap Of Spice Color Hand Drawn"), // sazonador
        1596: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Oat Milk Color Hand Drawn"), // Plant based milk
        1792: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Food Color Hand Drawn"), // food
        879: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Vegan Food Color Hand Drawn"), // vegan
        3286: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Korean Rice Cake Color Hand Drawn"), // Rice cakes
        2688: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Avocado Color Hand Drawn"), // obst
        1598: CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: "Salad Color Hand Drawn"), // Салата
    ]

    func fetchCategories() async {
        guard !hasLoadedInitially else { return }

        isLoading = true
        errorMessage = nil

        do {
            let allCategories = try await GraphQLClient.shared.fetchCategories()
            categories = allCategories
                .filter { categoryStyles.keys.contains($0.id) }
                .map { node in
                    let style = categoryStyles[node.id] ?? CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: nil)
                    return Category(
                        id: node.id,
                        name: node.name,
                        icon: style.icon,
                        color: style.color,
                        imageName: style.imageName
                    )
                }
            errorMessage = nil
            hasLoadedInitially = true
        } catch {
            errorMessage = error.localizedDescription
            categories = []
            hasLoadedInitially = true
        }

        isLoading = false
    }

    func refresh() async {
        errorMessage = nil

        do {
            let allCategories = try await GraphQLClient.shared.fetchCategories()
            categories = allCategories
                .filter { categoryStyles.keys.contains($0.id) }
                .map { node in
                    let style = categoryStyles[node.id] ?? CategoryStyle(icon: "square.grid.2x2", color: .gray, imageName: nil)
                    return Category(
                        id: node.id,
                        name: node.name,
                        icon: style.icon,
                        color: style.color,
                        imageName: style.imageName
                    )
                }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
