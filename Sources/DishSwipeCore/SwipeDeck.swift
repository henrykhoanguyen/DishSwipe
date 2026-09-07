import Foundation

public struct Ingredient: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let amount: String
    public let priceInCents: Int

    public init(id: String, name: String, amount: String, priceInCents: Int) {
        self.id = id
        self.name = name
        self.amount = amount
        self.priceInCents = priceInCents
    }
}

public struct Dish: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let cuisine: String
    public let durationMinutes: Int
    public let videoURL: URL
    public let ingredients: [Ingredient]

    public init(
        id: UUID = UUID(),
        name: String,
        cuisine: String,
        durationMinutes: Int,
        videoURL: URL,
        ingredients: [Ingredient] = []
    ) {
        self.id = id
        self.name = name
        self.cuisine = cuisine
        self.durationMinutes = durationMinutes
        self.videoURL = videoURL
        self.ingredients = ingredients
    }
}

public struct ShoppingCart: Sendable {
    public private(set) var items: [Ingredient] = []

    public init() {}

    public var totalInCents: Int {
        items.reduce(0) { $0 + $1.priceInCents }
    }

    public mutating func addIngredients(for dish: Dish) {
        let existingIDs = Set(items.map(\.id))
        items.append(contentsOf: dish.ingredients.filter { !existingIDs.contains($0.id) })
    }

    public func containsIngredients(for dish: Dish) -> Bool {
        let itemIDs = Set(items.map(\.id))
        return !dish.ingredients.isEmpty && dish.ingredients.allSatisfy { itemIDs.contains($0.id) }
    }
}

public enum SwipeDecision: Equatable, Sendable {
    case pass
    case like

    public init?(horizontalTranslation: Double, threshold: Double) {
        guard abs(horizontalTranslation) >= threshold else { return nil }
        self = horizontalTranslation > 0 ? .like : .pass
    }
}

public struct SwipeDeck: Sendable {
    public private(set) var dishes: [Dish]
    public private(set) var currentIndex = 0
    public private(set) var savedDishes: [Dish] = []

    public init(dishes: [Dish]) {
        self.dishes = dishes
    }

    public var currentDish: Dish? {
        dishes.indices.contains(currentIndex) ? dishes[currentIndex] : nil
    }

    public var reviewedCount: Int {
        min(currentIndex, dishes.count)
    }

    public var isComplete: Bool {
        currentDish == nil
    }

    public var progress: Double {
        guard !dishes.isEmpty else { return 1 }
        return Double(reviewedCount) / Double(dishes.count)
    }

    public mutating func decide(_ decision: SwipeDecision) {
        guard let dish = currentDish else { return }
        if decision == .like, !savedDishes.contains(where: { $0.id == dish.id }) {
            savedDishes.append(dish)
        }
        currentIndex += 1
    }

    public mutating func reset() {
        currentIndex = 0
    }

    public mutating func removeSavedDish(id: UUID) {
        savedDishes.removeAll { $0.id == id }
    }
}
