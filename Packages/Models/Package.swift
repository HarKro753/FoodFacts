// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [
        .iOS(.v17),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Models",
            targets: ["Models"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/RevenueCat/purchases-ios.git",
            from: "5.16.0"
        )
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios")
            ]
        )
    ]
)
