// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VoicePocket",
    defaultLocalization: "ru",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "VoicePocket",
            targets: ["VoicePocket"])
    ],
    dependencies: [
        .package(url: "https://github.com/MacPaw/OpenAI.git", from: "0.2.9")
    ],
    targets: [
        .target(
            name: "VoicePocket",
            dependencies: [
                .product(name: "OpenAI", package: "OpenAI")
            ],
            path: "VoicePocket"
        )
    ]
)
