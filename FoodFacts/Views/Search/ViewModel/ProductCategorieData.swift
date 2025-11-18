//
//  CategorieFilter.swift
//  FoodFacts
//
//  Created by Harro Krog on 18.11.25.
//

struct ProductCategoryData: Identifiable, Hashable {
    let id: Int
    let name: String
    let filter: CategoryFilter

    static let categories: [ProductCategoryData] = [
        // Staples / Pasta / Grains
        ProductCategoryData(id: 10, name: "Spaghetti", filter: .category(id: 319)),
        ProductCategoryData(id: 11, name: "Fusilli", filter: .category(id: 1205)),
        ProductCategoryData(id: 12, name: "Penne", filter: .category(id: 206)),
        ProductCategoryData(id: 13, name: "Penne rigate", filter: .category(id: 11721)),
        ProductCategoryData(id: 14, name: "Tagliatelle", filter: .category(id: 10683)),
        ProductCategoryData(id: 15, name: "Tortelloni", filter: .category(id: 520)),
        ProductCategoryData(id: 16, name: "Rice (Japonica)", filter: .category(id: 1085)),
        ProductCategoryData(id: 17, name: "Rice (Basmati)", filter: .category(id: 1326)),
        ProductCategoryData(id: 18, name: "Rice (Long grain)", filter: .category(id: 1038)),
        ProductCategoryData(id: 19, name: "Bread rolls", filter: .category(id: 1802)),
        ProductCategoryData(id: 20, name: "Pancakes", filter: .category(id: 102)),

        // Meat / Fish / Poultry
        ProductCategoryData(id: 21, name: "Chicken breasts", filter: .category(id: 448)),
        ProductCategoryData(id: 22, name: "Chicken cutlets", filter: .category(id: 1539)),
        ProductCategoryData(id: 23, name: "Chicken drumsticks", filter: .category(id: 1537)),
        ProductCategoryData(id: 24, name: "Chicken wings", filter: .category(id: 615)),
        ProductCategoryData(id: 25, name: "Ground beef steaks", filter: .category(id: 1016)),
        ProductCategoryData(id: 26, name: "Pork sausages", filter: .category(id: 1662)),
        ProductCategoryData(id: 27, name: "Meat balls", filter: .category(id: 1547)),
        ProductCategoryData(id: 28, name: "Salmon fillets", filter: .category(id: 523)),
        ProductCategoryData(id: 29, name: "Salmon steaks", filter: .category(id: 4927)),
        ProductCategoryData(id: 30, name: "Tuna fillets", filter: .category(id: 4939)),
        ProductCategoryData(id: 31, name: "Tuna chunks", filter: .category(id: 4928)),

        // Vegetables / Fruits
        ProductCategoryData(id: 32, name: "Broccoli", filter: .category(id: 1113)),
        ProductCategoryData(id: 33, name: "Cherry tomatoes", filter: .category(id: 21588)),
        ProductCategoryData(id: 34, name: "Avocados", filter: .category(id: 7501)),
        ProductCategoryData(id: 35, name: "Onions", filter: .category(id: 110)),
        ProductCategoryData(id: 36, name: "Garlic", filter: .category(id: 572)),
        ProductCategoryData(id: 37, name: "Carrots", filter: .category(id: 116)),
        ProductCategoryData(id: 38, name: "Apples", filter: .category(id: 3402)),
        ProductCategoryData(id: 39, name: "Bananas", filter: .category(id: 1724)),

        // Dairy / Eggs
        ProductCategoryData(id: 40, name: "Eggs", filter: .category(id: 45)),
        ProductCategoryData(id: 41, name: "Chicken eggs", filter: .category(id: 46)),
        ProductCategoryData(id: 42, name: "Milk", filter: .category(id: 180)),
        ProductCategoryData(id: 43, name: "Pasteurised milks", filter: .category(id: 11743)),
        ProductCategoryData(id: 44, name: "Whole milks", filter: .category(id: 25255)),
        ProductCategoryData(id: 45, name: "Butter", filter: .category(id: 678)),
        ProductCategoryData(id: 46, name: "Half-salted butter", filter: .category(id: 3901)),
        ProductCategoryData(id: 47, name: "Mozzarella", filter: .category(id: 963)),
        ProductCategoryData(id: 48, name: "Cow camemberts", filter: .category(id: 19107)),
        ProductCategoryData(id: 49, name: "Cheddar cheese", filter: .category(id: 566)),

        // Sweets / Snacks
        ProductCategoryData(id: 50, name: "Chocolate bars", filter: .category(id: 146)),
        ProductCategoryData(id: 51, name: "Milk chocolates", filter: .category(id: 527)),
        ProductCategoryData(id: 52, name: "Gummy bears", filter: .category(id: 4268)),
        ProductCategoryData(id: 53, name: "Cookies", filter: .category(id: 335)),
        ProductCategoryData(id: 54, name: "Chocolate chip cookies", filter: .category(id: 4846)),
        ProductCategoryData(id: 55, name: "Madeleines", filter: .category(id: 1769)),
        ProductCategoryData(id: 56, name: "Ice cream tubs", filter: .category(id: 375)),

        // Food Groups - commonly used groups
        ProductCategoryData(id: 57, name: "Composite foods", filter: .foodGroup(id: 1)),
        ProductCategoryData(id: 58, name: "Fruits and vegetables", filter: .foodGroup(id: 2)),
        ProductCategoryData(id: 59, name: "Cereals and potatoes", filter: .foodGroup(id: 3)),
        ProductCategoryData(id: 60, name: "Fish, Meat, Eggs", filter: .foodGroup(id: 4)),
        ProductCategoryData(id: 61, name: "Milk and dairy products", filter: .foodGroup(id: 5)),
        ProductCategoryData(id: 62, name: "Beverages", filter: .foodGroup(id: 6)),
        ProductCategoryData(id: 63, name: "Fats and sauces", filter: .foodGroup(id: 7)),
        ProductCategoryData(id: 64, name: "Sugary snacks", filter: .foodGroup(id: 8)),
    ]
}
