// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ReduxSwift",
    products: [
        .library(
            name: "ReduxSwift",
            targets: ["ReduxSwift"]),
    ],
    targets: [
        .target(
            name: "ReduxSwift",
            dependencies: []),
        .testTarget(
            name: "ReduxSwiftTests",
            dependencies: ["ReduxSwift"]),
    ]
)
