// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SimplScenes",
    platforms: [
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "SimplScenes",
            targets: ["SimplScenes"]
        )
    ],
    targets: [
        .target(
            name: "SimplScenes",
            dependencies: [],
            path: "Sources/SimplScenes"
        ),
        .testTarget(
            name: "SimplScenesTests",
            dependencies: ["SimplScenes"],
            path: "Tests/SimplScenesTests"
        )
    ]
)
