import Foundation
import Models

@available(iOS 15.0, *)
final class MockGraphQLStore: @unchecked Sendable {
    static let shared = MockGraphQLStore()

    private struct HistoryEntry {
        let id: Int
        let productCode: Int
        let scannedAt: String
    }

    private var favoriteProductCodes: Set<Int> = []
    private var historyEntries: [HistoryEntry] = []
    private var nextHistoryId = 1
    private let lock = NSLock()

    private let records = GeneratedMockProducts.records

    private init() {}

    func fetchProducts(
        first: Int,
        after: String?,
        categoryId: Int?,
        labelId: Int?,
        labelIds: [Int]?,
        countryId: Int?,
        foodGroup: Int?,
        sortAscending: Bool?,
        searchQuery: String?,
        productCodeForAlternatives: Int?,
        nutrientFieldName: String?,
        nutrientMinValue: Double?,
        nutrientMaxValue: Double?,
        nutrientConditions: [(fieldName: String, minValue: Double?, maxValue: Double?)]?
    ) -> PaginatedResult<Product> {
        var filtered = records

        if let searchQuery = normalizedSearchText(searchQuery), !searchQuery.isEmpty {
            filtered = filtered.filter {
                $0.name.lowercased().hasPrefix(searchQuery)
                    || ($0.brand?.lowercased().hasPrefix(searchQuery) ?? false)
            }
        }

        if let categoryId, let categoryName = Self.categoryNamesById[categoryId] {
            filtered = filtered.filter { record in
                matchesAny(record.categories, query: categoryName)
                    || matchesAny(record.categoryTags, query: categoryName)
                    || record.name.localizedCaseInsensitiveContains(categoryName)
            }
        }

        if let foodGroup, let foodGroupName = Self.foodGroupNamesById[foodGroup] {
            filtered = filtered.filter { record in
                matchesAny(record.foodGroups, query: foodGroupName)
                    || matchesAny(record.foodGroupTags, query: foodGroupName)
            }
        }

        let allLabelIds = ([labelId].compactMap { $0 } + (labelIds ?? []))
        for labelId in Set(allLabelIds) {
            filtered = filtered.filter { matchesLabel($0, labelId: labelId) }
        }

        if let productCodeForAlternatives,
            let base = records.first(where: { $0.code == productCodeForAlternatives })
        {
            let baseCategories = Set(base.categories.map(normalizedToken))
            let baseGroups = Set(base.foodGroups.map(normalizedToken))
            let alternatives = filtered.filter { candidate in
                candidate.code != productCodeForAlternatives
                    && (!baseCategories.isDisjoint(with: candidate.categories.map(normalizedToken))
                        || !baseGroups.isDisjoint(with: candidate.foodGroups.map(normalizedToken)))
            }
            if !alternatives.isEmpty {
                filtered = alternatives
            }
        }

        let conditions = normalizedNutrientConditions(
            fieldName: nutrientFieldName,
            minValue: nutrientMinValue,
            maxValue: nutrientMaxValue,
            extraConditions: nutrientConditions
        )
        for condition in conditions {
            filtered = filtered.filter { record in
                guard let value = nutrientValue(for: condition.fieldName, in: record) else {
                    return false
                }
                if let minValue = condition.minValue, value < minValue {
                    return false
                }
                if let maxValue = condition.maxValue, value > maxValue {
                    return false
                }
                return true
            }
        }

        if sortAscending == true {
            filtered.sort {
                if $0.score == $1.score { return $0.name < $1.name }
                return $0.score > $1.score
            }
        }

        if countryId != nil {
            filtered = filtered.filter { $0.imageUrl != nil }
        }

        return page(records: filtered, first: first, after: after)
    }

    func fetchProductByCode(_ code: String) -> Product? {
        if let productCode = Int(code),
            let record = records.first(where: { $0.code == productCode })
        {
            return Self.makeProduct(from: record)
        }

        return fetchRandomProduct()
    }

    func fetchRandomProduct() -> Product? {
        records.randomElement().map(Self.makeProduct(from:))
    }

    func fetchCategories() -> PaginatedResult<CategoryNode> {
        let categories = records
            .flatMap(\.categories)
            .reduce(into: [String: Int]()) { counts, name in
                counts[name, default: 0] += 1
            }
            .sorted {
                if $0.value == $1.value { return $0.key < $1.key }
                return $0.value > $1.value
            }
            .prefix(500)
            .enumerated()
            .map { index, item in
                CategoryNode(id: stableId(for: item.key, offset: 10_000), name: item.key)
            }

        return PaginatedResult(items: Array(categories), pageInfo: Self.singlePageInfo)
    }

    func fetchFoodGroups() -> PaginatedResult<FoodGroupNode> {
        let groups = records
            .flatMap(\.foodGroups)
            .reduce(into: [String: Int]()) { counts, name in
                counts[name, default: 0] += 1
            }
            .sorted {
                if $0.value == $1.value { return $0.key < $1.key }
                return $0.value > $1.value
            }
            .enumerated()
            .map { index, item in
                FoodGroupNode(id: stableId(for: item.key, offset: 20_000), name: item.key)
            }

        return PaginatedResult(items: groups, pageInfo: Self.singlePageInfo)
    }

    func fetchCompletions(prefix: String) -> CompletionsData {
        let normalizedPrefix = prefix.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedPrefix.isEmpty else {
            return CompletionsData(productNames: [], categoryNames: [], foodGroups: [])
        }

        let products = records
            .filter { $0.name.lowercased().hasPrefix(normalizedPrefix) }
            .prefix(10)
            .map { CompletionItem(id: $0.code, name: $0.name) }

        let categories = uniqueNames(records.flatMap(\.categories), prefix: normalizedPrefix)
            .prefix(10)
            .map { CompletionItem(id: stableId(for: $0, offset: 10_000), name: $0) }

        let foodGroups = uniqueNames(records.flatMap(\.foodGroups), prefix: normalizedPrefix)
            .prefix(10)
            .map { CompletionItem(id: stableId(for: $0, offset: 20_000), name: $0) }

        return CompletionsData(
            productNames: Array(products),
            categoryNames: Array(categories),
            foodGroups: Array(foodGroups)
        )
    }

    func authPayload() -> AuthPayload {
        AuthPayload(
            accessToken: "mock-access-token",
            refreshToken: "mock-refresh-token",
            user: Self.makeMockUser()
        )
    }

    func logoutPayload() -> LogoutPayload {
        LogoutPayload(success: true, message: "Logged out")
    }

    func fetchFavoriteProducts(first: Int, after: String?) -> PaginatedResult<Product> {
        let favoriteProductCodes = withLock { self.favoriteProductCodes }
        let favoriteRecords = records.filter { favoriteProductCodes.contains($0.code) }
        return page(records: favoriteRecords, first: first, after: after)
    }

    func isProductFavoritedByMe(productCode: Int) -> Bool {
        withLock {
            favoriteProductCodes.contains(productCode)
        }
    }

    func addFavoriteProduct(productCode: Int) -> FavoriteProductPayload {
        _ = withLock {
            favoriteProductCodes.insert(productCode)
        }
        return FavoriteProductPayload(success: true, message: "Product added to favorites")
    }

    func removeFavoriteProduct(productCode: Int) -> FavoriteProductPayload {
        _ = withLock {
            favoriteProductCodes.remove(productCode)
        }
        return FavoriteProductPayload(success: true, message: "Product removed from favorites")
    }

    func fetchProductHistory(first: Int, after: String?) -> PaginatedResult<ProductHistory> {
        let entries = withLock { historyEntries }
        let startIndex = min(startIndex(after: after), entries.count)
        let safeFirst = max(0, first)
        let endIndex = min(entries.count, startIndex + safeFirst)
        let items = entries[startIndex..<endIndex].map { entry in
            ProductHistory(
                id: entry.id,
                productCode: entry.productCode,
                scannedAt: entry.scannedAt,
                product: records
                    .first(where: { $0.code == entry.productCode })
                    .map(Self.makeProduct(from:))
            )
        }

        return PaginatedResult(
            items: Array(items),
            pageInfo: pageInfo(totalCount: entries.count, startIndex: startIndex, endIndex: endIndex)
        )
    }

    func addProductHistoryItem(productCode: Int) -> AddProductHistoryItemPayload {
        let scannedAt = Self.iso8601String(from: Date())
        let entry = withLock {
            let entry = HistoryEntry(id: nextHistoryId, productCode: productCode, scannedAt: scannedAt)
            nextHistoryId += 1
            historyEntries.insert(entry, at: 0)
            return entry
        }

        return AddProductHistoryItemPayload(
            id: entry.id,
            productCode: entry.productCode,
            scannedAt: entry.scannedAt
        )
    }

    func removeProductHistoryItem(historyId: Int) -> RemoveProductHistoryItemPayload {
        withLock {
            historyEntries.removeAll { $0.id == historyId }
        }
        return RemoveProductHistoryItemPayload(success: true, message: "History item removed")
    }

    private func withLock<T>(_ work: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return work()
    }

    private func page(records: [MockProductRecord], first: Int, after: String?) -> PaginatedResult<Product> {
        let startIndex = min(startIndex(after: after), records.count)
        let safeFirst = max(0, first)
        let endIndex = min(records.count, startIndex + safeFirst)
        let products = records[startIndex..<endIndex].map(Self.makeProduct(from:))

        return PaginatedResult(
            items: Array(products),
            pageInfo: pageInfo(totalCount: records.count, startIndex: startIndex, endIndex: endIndex)
        )
    }

    private func startIndex(after: String?) -> Int {
        guard let after, let cursor = Int(after) else { return 0 }
        return max(0, cursor + 1)
    }

    private func pageInfo(totalCount: Int, startIndex: Int, endIndex: Int) -> PageInfo {
        PageInfo(
            hasNextPage: endIndex < totalCount,
            hasPreviousPage: startIndex > 0,
            startCursor: startIndex < endIndex ? String(startIndex) : nil,
            endCursor: startIndex < endIndex ? String(endIndex - 1) : nil
        )
    }

    private func normalizedSearchText(_ text: String?) -> String? {
        text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func matchesAny(_ values: [String], query: String) -> Bool {
        let normalizedQuery = normalizedToken(query)
        return values.contains { normalizedToken($0).contains(normalizedQuery) }
    }

    private func matchesLabel(_ record: MockProductRecord, labelId: Int) -> Bool {
        let labels = record.labelTags.map(normalizedToken)
        switch labelId {
        case 3:
            return labels.contains { $0.contains("vegetarian") }
        case 4:
            return labels.contains { $0.contains("vegan") }
        default:
            return true
        }
    }

    private func normalizedToken(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "en:", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizedNutrientConditions(
        fieldName: String?,
        minValue: Double?,
        maxValue: Double?,
        extraConditions: [(fieldName: String, minValue: Double?, maxValue: Double?)]?
    ) -> [(fieldName: String, minValue: Double?, maxValue: Double?)] {
        var conditions = extraConditions ?? []
        if let fieldName {
            conditions.append((fieldName: fieldName, minValue: minValue, maxValue: maxValue))
        }
        return conditions
    }

    private func nutrientValue(for fieldName: String, in record: MockProductRecord) -> Double? {
        switch fieldName {
        case "energyKcal100g", "energy-kcal_100g":
            return record.energyKcal100g
        case "fat100g", "fat_100g":
            return record.fat100g
        case "saturatedFat100g", "saturated-fat_100g":
            return record.saturatedFat100g
        case "sugars100g", "sugars_100g":
            return record.sugars100g
        case "fiber100g", "fiber_100g":
            return record.fiber100g
        case "proteins100g", "proteins_100g":
            return record.proteins100g
        case "salt100g", "salt_100g":
            return record.salt100g
        default:
            return nil
        }
    }

    private func uniqueNames(_ names: [String], prefix: String) -> [String] {
        Array(Set(names.filter { $0.lowercased().hasPrefix(prefix) })).sorted()
    }

    private func stableId(for value: String, offset: Int) -> Int {
        let hash = value.unicodeScalars.reduce(0) { partial, scalar in
            (partial * 31 + Int(scalar.value)) % 900_000
        }
        return offset + hash
    }

    private static func makeProduct(from record: MockProductRecord) -> Product {
        Product(
            code: record.code,
            name: record.name,
            brand: record.brand,
            imageUrl: record.imageUrl,
            nutriScore: record.score,
            positiveNutrientRatings: positiveRatings(for: record),
            negativeNutrientRatings: negativeRatings(for: record),
            additivesRatings: additiveRating(for: record)
        )
    }

    private static func positiveRatings(for record: MockProductRecord) -> [NutrientRating] {
        [
            nutrientRating(
                nutrientType: "PROTEINS",
                name: "Protein",
                value: record.proteins100g,
                unit: "g",
                rating: positiveRating(record.proteins100g, good: 10, veryGood: 20)
            ),
            nutrientRating(
                nutrientType: "FIBER",
                name: "Fiber",
                value: record.fiber100g,
                unit: "g",
                rating: positiveRating(record.fiber100g, good: 3, veryGood: 6)
            ),
        ].compactMap { $0 }
    }

    private static func negativeRatings(for record: MockProductRecord) -> [NutrientRating] {
        [
            nutrientRating(
                nutrientType: "ENERGY_KCAL",
                name: "Calories",
                value: record.energyKcal100g,
                unit: "kcal",
                rating: negativeRating(record.energyKcal100g, good: 200, bad: 450)
            ),
            nutrientRating(
                nutrientType: "FAT",
                name: "Fat",
                value: record.fat100g,
                unit: "g",
                rating: negativeRating(record.fat100g, good: 3, bad: 20)
            ),
            nutrientRating(
                nutrientType: "SATURATED_FAT",
                name: "Saturated fat",
                value: record.saturatedFat100g,
                unit: "g",
                rating: negativeRating(record.saturatedFat100g, good: 1.5, bad: 5)
            ),
            nutrientRating(
                nutrientType: "SUGARS",
                name: "Sugars",
                value: record.sugars100g,
                unit: "g",
                rating: negativeRating(record.sugars100g, good: 5, bad: 22.5)
            ),
            nutrientRating(
                nutrientType: "SALT",
                name: "Salt",
                value: record.salt100g,
                unit: "g",
                rating: negativeRating(record.salt100g, good: 0.3, bad: 1.5)
            ),
        ].compactMap { $0 }
    }

    private static func nutrientRating(
        nutrientType: String,
        name: String,
        value: Double?,
        unit: String,
        rating: String?
    ) -> NutrientRating? {
        guard let value, let rating else { return nil }

        return NutrientRating(
            nutrientType: nutrientType,
            name: name,
            value: value,
            unit: unit,
            rating: rating,
            text: ratingText(for: rating),
            ratingSections: nil
        )
    }

    private static func positiveRating(_ value: Double?, good: Double, veryGood: Double) -> String? {
        guard let value else { return nil }
        if value >= veryGood { return "VERY_GOOD" }
        if value >= good { return "GOOD" }
        if value > 0 { return "MEDIUM" }
        return "BAD"
    }

    private static func negativeRating(_ value: Double?, good: Double, bad: Double) -> String? {
        guard let value else { return nil }
        if value <= good { return "VERY_GOOD" }
        if value >= bad { return "BAD" }
        return "MEDIUM"
    }

    private static func ratingText(for rating: String) -> String {
        switch rating {
        case "VERY_GOOD":
            return "Very good"
        case "GOOD":
            return "Good"
        case "MEDIUM":
            return "Moderate"
        case "BAD":
            return "High"
        default:
            return "Unknown"
        }
    }

    private static func additiveRating(for record: MockProductRecord) -> AdditiveRating? {
        guard let count = record.additivesCount, count > 0 else { return nil }
        return AdditiveRating(
            rating: count <= 1 ? "MEDIUM" : "BAD",
            description: "\(count) additive\(count == 1 ? "" : "s") listed in OpenFoodFacts.",
            numberOfAdditives: count,
            additives: []
        )
    }

    private static func makeMockUser() -> User {
        User(
            id: 1,
            username: "mock_user",
            email: "mock.user@cibrus.local",
            appleId: "mock-apple-id",
            isPremium: true,
            createdAt: Date(timeIntervalSince1970: 1_704_067_200),
            updatedAt: Date(timeIntervalSince1970: 1_704_067_200),
            lastLoginAt: Date(timeIntervalSince1970: 1_704_067_200)
        )
    }

    private static let singlePageInfo = PageInfo(
        hasNextPage: false,
        hasPreviousPage: false,
        startCursor: nil,
        endCursor: nil
    )

    private static func iso8601String(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }

    private static let categoryNamesById: [Int: String] = [
        45: "Eggs",
        46: "Chicken eggs",
        102: "Pancakes",
        110: "Onions",
        116: "Carrots",
        146: "Chocolate bars",
        180: "Milk",
        206: "Penne",
        319: "Spaghetti",
        335: "Cookies",
        375: "Ice cream tubs",
        448: "Chicken breasts",
        520: "Tortelloni",
        523: "Salmon fillets",
        527: "Milk chocolates",
        566: "Cheddar cheese",
        572: "Garlic",
        615: "Chicken wings",
        678: "Butter",
        963: "Mozzarella",
        1016: "Ground beef steaks",
        1038: "Rice long grain",
        1085: "Rice japonica",
        1113: "Broccoli",
        1205: "Fusilli",
        1326: "Rice basmati",
        1537: "Chicken drumsticks",
        1539: "Chicken cutlets",
        1547: "Meat balls",
        1662: "Pork sausages",
        1724: "Bananas",
        1769: "Madeleines",
        1802: "Bread rolls",
        3402: "Apples",
        3901: "Half-salted butter",
        4268: "Gummy bears",
        4927: "Salmon steaks",
        4928: "Tuna chunks",
        4939: "Tuna fillets",
        4846: "Chocolate chip cookies",
        7501: "Avocados",
        10683: "Tagliatelle",
        11721: "Penne rigate",
        11743: "Pasteurised milks",
        19107: "Cow camemberts",
        21588: "Cherry tomatoes",
        25255: "Whole milks",
    ]

    private static let foodGroupNamesById: [Int: String] = [
        1: "Composite foods",
        2: "Sandwiches",
        3: "Fish Meat Eggs",
        4: "Processed meat",
        5: "Beverages",
        6: "Sweetened beverages",
        7: "Sugary snacks",
        8: "Sweets",
        9: "Fats and sauces",
        10: "Fats",
        11: "Cereals and potatoes",
        12: "Cereals",
        13: "Salty snacks",
        14: "Appetizers",
        15: "Eggs",
        16: "Dressings and sauces",
        17: "Fruit juices",
        18: "Fruits and vegetables",
        19: "Vegetables",
        20: "Artificially sweetened beverages",
        21: "Unsweetened beverages",
        22: "Nuts",
        23: "Fruits",
        24: "Soups",
        25: "One-dish meals",
        26: "Potatoes",
        27: "Biscuits and cakes",
        28: "Chocolate products",
        29: "Fish and seafood",
        30: "Dried fruits",
        31: "Milk and dairy products",
        32: "Milk and yogurt",
        33: "Cheese",
        34: "Alcoholic beverages",
        35: "Waters and flavored waters",
        42: "Meat",
        43: "Meat other than poultry",
        45: "Bread",
        46: "Poultry",
        53: "Pizza pies and quiches",
        54: "Breakfast cereals",
        78: "Ice cream",
        88: "Plant-based milk substitutes",
        97: "Fatty fish",
        98: "Salty and fatty products",
        132: "Legumes",
        138: "Fruit nectars",
        160: "Pastries",
        183: "Teas and herbal teas and coffees",
        307: "Dairy desserts",
        387: "Lean fish",
        441: "Offals",
    ]
}
