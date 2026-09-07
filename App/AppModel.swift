import Combine
import DishSwipeCore
import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var deck: SwipeDeck
    @Published private(set) var cart = ShoppingCart()

    init(bundle: Bundle = .main) {
        deck = SwipeDeck(dishes: Self.makeDishes(bundle: bundle))
    }

    var currentDish: Dish? { deck.currentDish }
    var savedDishes: [Dish] { deck.savedDishes }
    var cartItems: [Ingredient] { cart.items }
    var cartTotalInCents: Int { cart.totalInCents }
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

    func removeFromCravings(_ dish: Dish) {
        deck.removeSavedDish(id: dish.id)
    }

    func addIngredientsToCart(for dish: Dish) {
        cart.addIngredients(for: dish)
    }

    func cartContainsIngredients(for dish: Dish) -> Bool {
        cart.containsIngredients(for: dish)
    }

    private static func makeDishes(bundle: Bundle) -> [Dish] {
        let details: [(String, String, Int, String, [Ingredient])] = [
            (
                "Tonkotsu Ramen", "Japanese", 35, "ramen",
                [
                    Ingredient(id: "ramen-noodles", name: "Fresh ramen noodles", amount: "12 oz", priceInCents: 349),
                    Ingredient(id: "pork-broth", name: "Pork bone broth", amount: "32 oz", priceInCents: 498),
                    Ingredient(id: "pork-belly", name: "Pork belly", amount: "1 lb", priceInCents: 899),
                    Ingredient(id: "eggs", name: "Large eggs", amount: "6 ct", priceInCents: 279),
                    Ingredient(id: "green-onions", name: "Green onions", amount: "1 bunch", priceInCents: 98)
                ]
            ),
            (
                "Margherita Pizza", "Italian", 28, "pizza",
                [
                    Ingredient(id: "pizza-dough", name: "Fresh pizza dough", amount: "16 oz", priceInCents: 298),
                    Ingredient(id: "tomatoes", name: "Crushed tomatoes", amount: "28 oz", priceInCents: 228),
                    Ingredient(id: "mozzarella", name: "Fresh mozzarella", amount: "8 oz", priceInCents: 448),
                    Ingredient(id: "basil", name: "Fresh basil", amount: "1 bunch", priceInCents: 248),
                    Ingredient(id: "olive-oil", name: "Extra virgin olive oil", amount: "17 oz", priceInCents: 798)
                ]
            ),
            (
                "Street Tacos", "Mexican", 22, "tacos",
                [
                    Ingredient(id: "corn-tortillas", name: "Corn tortillas", amount: "20 ct", priceInCents: 248),
                    Ingredient(id: "skirt-steak", name: "Beef skirt steak", amount: "1.5 lb", priceInCents: 1498),
                    Ingredient(id: "white-onion", name: "White onion", amount: "1 ct", priceInCents: 88),
                    Ingredient(id: "cilantro", name: "Cilantro", amount: "1 bunch", priceInCents: 48),
                    Ingredient(id: "limes", name: "Limes", amount: "4 ct", priceInCents: 198)
                ]
            ),
            (
                "Herb Butter Steak", "American", 30, "steak",
                [
                    Ingredient(id: "ribeye", name: "Boneless ribeye steaks", amount: "2 steaks", priceInCents: 2398),
                    Ingredient(id: "butter", name: "Unsalted butter", amount: "4 sticks", priceInCents: 498),
                    Ingredient(id: "garlic", name: "Fresh garlic", amount: "1 bulb", priceInCents: 68),
                    Ingredient(id: "rosemary", name: "Fresh rosemary", amount: "0.5 oz", priceInCents: 198),
                    Ingredient(id: "thyme", name: "Fresh thyme", amount: "0.5 oz", priceInCents: 198)
                ]
            ),
            (
                "Golden Curry", "Indian", 40, "curry",
                [
                    Ingredient(id: "chicken-thighs", name: "Boneless chicken thighs", amount: "1.5 lb", priceInCents: 749),
                    Ingredient(id: "coconut-milk", name: "Coconut milk", amount: "13.5 oz", priceInCents: 248),
                    Ingredient(id: "curry-powder", name: "Curry powder", amount: "2 oz", priceInCents: 398),
                    Ingredient(id: "basmati-rice", name: "Basmati rice", amount: "2 lb", priceInCents: 548),
                    Ingredient(id: "white-onion", name: "White onion", amount: "1 ct", priceInCents: 88)
                ]
            )
        ]

        return details.compactMap { name, cuisine, minutes, resource, ingredients in
            guard let url = bundle.url(forResource: resource, withExtension: "mp4") else { return nil }
            return Dish(
                name: name,
                cuisine: cuisine,
                durationMinutes: minutes,
                videoURL: url,
                ingredients: ingredients
            )
        }
    }
}
