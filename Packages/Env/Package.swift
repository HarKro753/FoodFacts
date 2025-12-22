// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Env",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Env",
            targets: ["Env"]
        )
    ],
    dependencies: [
        .package(path: "../Models"),
        .package(path: "../GraphQl"),
        .package(
            url: "https://github.com/RevenueCat/purchases-ios.git",
            from: "5.16.1"
        ),
    ],
    targets: [
        .target(
            name: "Env",
            dependencies: [
                "Models",
                "GraphQl",
                .product(name: "RevenueCat", package: "purchases-ios"),
            ]
        )

    ]
)
