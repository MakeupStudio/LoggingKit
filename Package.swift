// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "LoggingKit",
    products: [
        .library(
            name: "LoggingKit",
            targets: ["LoggingKit"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-log.git",
            .upToNextMajor(from: "1.2.0")
        )
    ],
    targets: [
        .target(
            name: "LoggingKit",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "LoggingKitTests",
            dependencies: ["LoggingKit"]),
    ]
)
