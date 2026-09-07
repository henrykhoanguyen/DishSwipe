import Foundation
import XCTest
@testable import DishSwipeCore

final class SwipeDeckTests: XCTestCase {
    private let dishes = [
        Dish(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, name: "Ramen", cuisine: "Japanese", durationMinutes: 25, videoURL: URL(string: "https://example.com/ramen.mp4")!),
        Dish(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, name: "Tacos", cuisine: "Mexican", durationMinutes: 20, videoURL: URL(string: "https://example.com/tacos.mp4")!)
    ]

    func testPassingDishAdvancesWithoutSaving() {
        var deck = SwipeDeck(dishes: dishes)
        deck.decide(.pass)
        XCTAssertEqual(deck.currentDish?.name, "Tacos")
        XCTAssertTrue(deck.savedDishes.isEmpty)
        XCTAssertEqual(deck.reviewedCount, 1)
    }

    func testLikingDishSavesItOnceAndAdvances() {
        var deck = SwipeDeck(dishes: dishes)
        deck.decide(.like)
        deck.reset()
        deck.decide(.like)
        XCTAssertEqual(deck.savedDishes.map(\.name), ["Ramen"])
        XCTAssertEqual(deck.currentDish?.name, "Tacos")
    }

    func testFinishingDeckShowsCompletionAndResetStartsOver() {
        var deck = SwipeDeck(dishes: dishes)
        deck.decide(.pass)
        deck.decide(.like)
        XCTAssertNil(deck.currentDish)
        XCTAssertTrue(deck.isComplete)
        XCTAssertEqual(deck.progress, 1)
        deck.reset()
        XCTAssertEqual(deck.currentDish?.name, "Ramen")
        XCTAssertFalse(deck.isComplete)
        XCTAssertEqual(deck.reviewedCount, 0)
    }

    func testDragThresholdMapsDirectionToDecision() {
        XCTAssertEqual(SwipeDecision(horizontalTranslation: 130, threshold: 110), .like)
        XCTAssertEqual(SwipeDecision(horizontalTranslation: -130, threshold: 110), .pass)
        XCTAssertNil(SwipeDecision(horizontalTranslation: 109, threshold: 110))
    }

    func testRemovingACravingOnlyRemovesTheSelectedDish() {
        var deck = SwipeDeck(dishes: dishes)
        deck.decide(.like)
        deck.decide(.like)

        deck.removeSavedDish(id: dishes[0].id)

        XCTAssertEqual(deck.savedDishes.map(\.name), ["Tacos"])
    }

    func testAddingDishIngredientsToCartIsIdempotent() {
        let ingredients = [
            Ingredient(id: "noodles", name: "Ramen noodles", amount: "12 oz", priceInCents: 249),
            Ingredient(id: "broth", name: "Pork broth", amount: "32 oz", priceInCents: 398)
        ]
        let ramen = Dish(
            name: "Ramen",
            cuisine: "Japanese",
            durationMinutes: 25,
            videoURL: URL(string: "https://example.com/ramen.mp4")!,
            ingredients: ingredients
        )
        var cart = ShoppingCart()

        cart.addIngredients(for: ramen)
        cart.addIngredients(for: ramen)

        XCTAssertEqual(cart.items, ingredients)
        XCTAssertEqual(cart.totalInCents, 647)
        XCTAssertTrue(cart.containsIngredients(for: ramen))
    }

    func testCartCombinesSharedIngredientsAndKeepsTheirDishAmounts() {
        let salt = Ingredient(id: "salt", name: "Kosher salt", amount: "1 tsp", priceInCents: 129)
        let lime = Ingredient(id: "lime", name: "Limes", amount: "3 ct", priceInCents: 198)
        let tacos = Dish(
            name: "Tacos",
            cuisine: "Mexican",
            durationMinutes: 20,
            videoURL: URL(string: "https://example.com/tacos.mp4")!,
            ingredients: [salt, lime]
        )
        let steak = Dish(
            name: "Steak",
            cuisine: "American",
            durationMinutes: 30,
            videoURL: URL(string: "https://example.com/steak.mp4")!,
            ingredients: [salt]
        )
        var cart = ShoppingCart()

        cart.addIngredients(for: tacos)
        cart.addIngredients(for: steak)

        XCTAssertEqual(cart.items, [salt, lime])
        XCTAssertEqual(cart.totalInCents, 327)
    }
}
