// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DishSwipe",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "DishSwipeCore", targets: ["DishSwipeCore"]),
        .executable(name: "DishSwipeCoreChecks", targets: ["DishSwipeCoreChecks"])
    ],
    targets: [
        .target(name: "DishSwipeCore"),
        .executableTarget(name: "DishSwipeCoreChecks", dependencies: ["DishSwipeCore"]),
        .testTarget(name: "DishSwipeCoreTests", dependencies: ["DishSwipeCore"])
    ]
)
