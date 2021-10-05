// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Turnstate",
    products: [
        .library(
            name: "Turnstate",
            targets: ["Turnstate"]),
    ],
    targets: [
        .target(
            name: "Turnstate",
            dependencies: []),
        .testTarget(
            name: "TurnstateTests",
            dependencies: ["Turnstate"]),
    ]
)
