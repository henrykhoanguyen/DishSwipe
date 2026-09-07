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
}
