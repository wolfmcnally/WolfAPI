// swift-tools-version:5.5

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
        .package(url: "https://github.com/wolfmcnally/WolfBase", from: "3.0.0"),
        .package(url: "https://github.com/wolfmcnally/WolfKeychain.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "WolfAPI",
            dependencies: ["WolfBase", "WolfKeychain"]),
        .testTarget(
            name: "WolfAPITests",
            dependencies: ["WolfAPI"]),
    ]
)
