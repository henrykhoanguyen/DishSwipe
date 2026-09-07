import XCTest

final class DishSwipeUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testCravingCanAddIngredientsAndCompleteDemoCheckout() {
        XCTAssertTrue(app.buttons["Crave"].waitForExistence(timeout: 5))
        app.buttons["Crave"].tap()

        let cravings = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Cravings'"))
            .firstMatch
        XCTAssertTrue(cravings.waitForExistence(timeout: 3))
        cravings.tap()

        XCTAssertTrue(app.navigationBars["Your cravings"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Tonkotsu Ramen"].exists)
        app.buttons["Add ingredients"].tap()
        XCTAssertTrue(app.buttons["Added to cart"].exists)

        let cartLink = app.buttons["View cart"]
        XCTAssertTrue(cartLink.exists)
        cartLink.tap()

        XCTAssertTrue(app.navigationBars["Your cart"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Fresh ramen noodles"].exists)
        XCTAssertTrue(app.staticTexts["12 oz"].exists)
        XCTAssertTrue(app.staticTexts["$21.23"].exists)
        attachScreenshot(named: "Cart")

        let checkout = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Check out'"))
            .firstMatch
        XCTAssertTrue(checkout.exists)
        checkout.tap()

        XCTAssertTrue(app.staticTexts["Thank you for your purchase!"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["This is a demo checkout. No order was placed."].exists)
        attachScreenshot(named: "Checkout confirmation")
    }

    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testCravingCanBeRemoved() {
        XCTAssertTrue(app.buttons["Crave"].waitForExistence(timeout: 5))
        app.buttons["Crave"].tap()

        let cravings = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Cravings'"))
            .firstMatch
        XCTAssertTrue(cravings.waitForExistence(timeout: 3))
        cravings.tap()

        let remove = app.buttons["Remove Tonkotsu Ramen from cravings"]
        XCTAssertTrue(remove.waitForExistence(timeout: 3))
        remove.tap()

        XCTAssertTrue(app.staticTexts["No cravings yet"].waitForExistence(timeout: 3))
    }
}
