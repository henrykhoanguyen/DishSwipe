import Foundation
import DishSwipeCore

func require(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else {
        FileHandle.standardError.write(Data("FAIL: \(message)\n".utf8))
        exit(1)
    }
}

let dishes = [
    Dish(name: "Ramen", cuisine: "Japanese", durationMinutes: 25, videoURL: URL(string: "https://example.com/ramen.mp4")!),
    Dish(name: "Tacos", cuisine: "Mexican", durationMinutes: 20, videoURL: URL(string: "https://example.com/tacos.mp4")!)
]

var deck = SwipeDeck(dishes: dishes)
deck.decide(.pass)
require(deck.currentDish?.name == "Tacos", "pass advances to the next dish")
require(deck.savedDishes.isEmpty, "pass does not save a dish")
deck.decide(.like)
require(deck.isComplete, "last decision completes the deck")
require(deck.savedDishes.map(\.name) == ["Tacos"], "like saves the dish")
require(deck.progress == 1, "completed deck reports full progress")
deck.reset()
require(deck.currentDish?.name == "Ramen", "reset returns to the first dish")
require(SwipeDecision(horizontalTranslation: 130, threshold: 110) == .like, "right drag likes")
require(SwipeDecision(horizontalTranslation: -130, threshold: 110) == .pass, "left drag passes")
require(SwipeDecision(horizontalTranslation: 109, threshold: 110) == nil, "short drag cancels")

print("PASS: 9 DishSwipe core behavior checks")
