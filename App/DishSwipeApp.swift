import SwiftUI

@main
struct DishSwipeApp: App {
    var body: some Scene {
        WindowGroup {
            DiscoverView()
                .preferredColorScheme(.dark)
        }
    }
}
