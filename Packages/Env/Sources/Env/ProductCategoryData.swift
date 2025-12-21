//
//  ProductCategoryData.swift
//  Env
//
//  Created by Harro Krog on 18.11.25.
//

public struct ProductCategoryData: Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let filter: CategoryFilter

    public init(id: Int, name: String, filter: CategoryFilter) {
        self.id = id
        self.name = name
        self.filter = filter
    }

    public static let categories: [ProductCategoryData] = [
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
        
        // Food Groups
        ProductCategoryData(id: 65, name: "Composite foods", filter: .foodGroup(id: 1)),
        ProductCategoryData(id: 66, name: "Sandwiches", filter: .foodGroup(id: 2)),
        ProductCategoryData(id: 67, name: "Fish‚ Meat‚ Eggs", filter: .foodGroup(id: 3)),
        ProductCategoryData(id: 68, name: "Processed meat", filter: .foodGroup(id: 4)),
        ProductCategoryData(id: 69, name: "Beverages", filter: .foodGroup(id: 5)),
        ProductCategoryData(id: 70, name: "Sweetened beverages", filter: .foodGroup(id: 6)),
        ProductCategoryData(id: 71, name: "Sugary snacks", filter: .foodGroup(id: 7)),
        ProductCategoryData(id: 72, name: "Sweets", filter: .foodGroup(id: 8)),
        ProductCategoryData(id: 73, name: "Fats and sauces", filter: .foodGroup(id: 9)),
        ProductCategoryData(id: 74, name: "Fats", filter: .foodGroup(id: 10)),
        ProductCategoryData(id: 75, name: "Cereals and potatoes", filter: .foodGroup(id: 11)),
        ProductCategoryData(id: 76, name: "Cereals", filter: .foodGroup(id: 12)),
        ProductCategoryData(id: 77, name: "Salty snacks", filter: .foodGroup(id: 13)),
        ProductCategoryData(id: 78, name: "Appetizers", filter: .foodGroup(id: 14)),
        ProductCategoryData(id: 79, name: "Eggs", filter: .foodGroup(id: 15)),
        ProductCategoryData(id: 80, name: "Dressings and sauces", filter: .foodGroup(id: 16)),
        ProductCategoryData(id: 81, name: "Fruit juices", filter: .foodGroup(id: 17)),
        ProductCategoryData(id: 82, name: "Fruits and vegetables", filter: .foodGroup(id: 18)),
        ProductCategoryData(id: 83, name: "Vegetables", filter: .foodGroup(id: 19)),
        ProductCategoryData(id: 84, name: "Artificially sweetened beverages", filter: .foodGroup(id: 20)),
        ProductCategoryData(id: 85, name: "Unsweetened beverages", filter: .foodGroup(id: 21)),
        ProductCategoryData(id: 86, name: "Nuts", filter: .foodGroup(id: 22)),
        ProductCategoryData(id: 87, name: "Fruits", filter: .foodGroup(id: 23)),
        ProductCategoryData(id: 88, name: "Soups", filter: .foodGroup(id: 24)),
        ProductCategoryData(id: 89, name: "One-dish meals", filter: .foodGroup(id: 25)),
        ProductCategoryData(id: 90, name: "Potatoes", filter: .foodGroup(id: 26)),
        ProductCategoryData(id: 91, name: "Biscuits and cakes", filter: .foodGroup(id: 27)),
        ProductCategoryData(id: 92, name: "Chocolate products", filter: .foodGroup(id: 28)),
        ProductCategoryData(id: 93, name: "Fish and seafood", filter: .foodGroup(id: 29)),
        ProductCategoryData(id: 94, name: "Dried fruits", filter: .foodGroup(id: 30)),
        ProductCategoryData(id: 95, name: "Milk and dairy products", filter: .foodGroup(id: 31)),
        ProductCategoryData(id: 96, name: "Milk and yogurt", filter: .foodGroup(id: 32)),
        ProductCategoryData(id: 97, name: "Cheese", filter: .foodGroup(id: 33)),
        ProductCategoryData(id: 98, name: "Alcoholic beverages", filter: .foodGroup(id: 34)),
        ProductCategoryData(id: 99, name: "Waters and flavored waters", filter: .foodGroup(id: 35)),
        ProductCategoryData(id: 100, name: "Meat", filter: .foodGroup(id: 42)),
        ProductCategoryData(id: 101, name: "Meat other than poultry", filter: .foodGroup(id: 43)),
        ProductCategoryData(id: 102, name: "Bread", filter: .foodGroup(id: 45)),
        ProductCategoryData(id: 103, name: "Poultry", filter: .foodGroup(id: 46)),
        ProductCategoryData(id: 104, name: "Pizza pies and quiches", filter: .foodGroup(id: 53)),
        ProductCategoryData(id: 105, name: "Breakfast cereals", filter: .foodGroup(id: 54)),
        ProductCategoryData(id: 106, name: "Ice cream", filter: .foodGroup(id: 78)),
        ProductCategoryData(id: 107, name: "Plant-based milk substitutes", filter: .foodGroup(id: 88)),
        ProductCategoryData(id: 108, name: "Fatty fish", filter: .foodGroup(id: 97)),
        ProductCategoryData(id: 109, name: "Salty and fatty products", filter: .foodGroup(id: 98)),
        ProductCategoryData(id: 110, name: "Legumes", filter: .foodGroup(id: 132)),
        ProductCategoryData(id: 111, name: "Fruit nectars", filter: .foodGroup(id: 138)),
        ProductCategoryData(id: 112, name: "Pastries", filter: .foodGroup(id: 160)),
        ProductCategoryData(id: 113, name: "Teas and herbal teas and coffees", filter: .foodGroup(id: 183)),
        ProductCategoryData(id: 114, name: "Dairy desserts", filter: .foodGroup(id: 307)),
        ProductCategoryData(id: 115, name: "Lean fish", filter: .foodGroup(id: 387)),
        ProductCategoryData(id: 116, name: "Offals", filter: .foodGroup(id: 441)),
    ]
}
