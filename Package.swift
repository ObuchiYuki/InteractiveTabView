// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InteractiveTabView",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "InteractiveTabView",
            targets: ["InteractiveTabView"]
        ),
    ],
    targets: [
        .target(name: "InteractiveTabView"),
    ]
)
