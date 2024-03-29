// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "WolfAPI",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "WolfAPI",
            targets: ["WolfAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wolfmcnally/WolfBase", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "WolfAPI",
            dependencies: ["WolfBase"]),
        .testTarget(
            name: "WolfAPITests",
            dependencies: ["WolfAPI"]),
    ]
)
