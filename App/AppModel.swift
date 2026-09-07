import Combine
import DishSwipeCore
import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var deck: SwipeDeck

    init(bundle: Bundle = .main) {
        deck = SwipeDeck(dishes: Self.makeDishes(bundle: bundle))
    }

    var currentDish: Dish? { deck.currentDish }
    var savedDishes: [Dish] { deck.savedDishes }
    var progress: Double { deck.progress }
    var reviewedCount: Int { deck.reviewedCount }
    var totalCount: Int { deck.dishes.count }
    var isComplete: Bool { deck.isComplete }

    func decide(_ decision: SwipeDecision) {
        deck.decide(decision)
    }

    func reset() {
        deck.reset()
    }

    private static func makeDishes(bundle: Bundle) -> [Dish] {
        let details: [(String, String, Int, String)] = [
            ("Tonkotsu Ramen", "Japanese", 35, "ramen"),
            ("Margherita Pizza", "Italian", 28, "pizza"),
            ("Street Tacos", "Mexican", 22, "tacos"),
            ("Herb Butter Steak", "Modern", 30, "steak"),
            ("Golden Curry", "Indian", 40, "curry")
        ]

        return details.compactMap { name, cuisine, minutes, resource in
            guard let url = bundle.url(forResource: resource, withExtension: "mp4") else { return nil }
            return Dish(name: name, cuisine: cuisine, durationMinutes: minutes, videoURL: url)
        }
    }
}
