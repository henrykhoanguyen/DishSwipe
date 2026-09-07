import Foundation

public struct Dish: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let cuisine: String
    public let durationMinutes: Int
    public let videoURL: URL

    public init(id: UUID = UUID(), name: String, cuisine: String, durationMinutes: Int, videoURL: URL) {
        self.id = id
        self.name = name
        self.cuisine = cuisine
        self.durationMinutes = durationMinutes
        self.videoURL = videoURL
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
}
