// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphQl",
    platforms: [
        .iOS(.v17),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "GraphQl",
            targets: ["GraphQl"]
        )
    ],
    dependencies: [.package(path: "../Models")],
    targets: [
        .target(
            name: "GraphQl",
            dependencies: [
                .product(name: "Models", package: "Models")
            ]
        )

    ]
)
