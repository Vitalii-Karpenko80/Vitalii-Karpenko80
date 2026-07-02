// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FieldDocsCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "FieldDocsCore",
            targets: ["FieldDocsCore"]),
    ],
    targets: [
        .target(
            name: "FieldDocsCore",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "FieldDocsCoreTests",
            dependencies: ["FieldDocsCore"]
        ),
    ]
)
