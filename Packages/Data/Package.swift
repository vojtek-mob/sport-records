// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Data",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "DataKit", targets: ["DataKit"]),
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.58.0"),
    ],
    targets: [
        // API client, DTOs, remote data sources. Depends on Domain for models only.
        .target(
            name: "Networking",
            dependencies: [
                .product(name: "Domain", package: "Core"),
            ],
            path: "Sources/Networking",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),

        // Repository implementations, local data sources, SwiftData stack.
        // Coordinates local vs remote.
        .target(
            name: "DataKit",
            dependencies: [
                .product(name: "Domain", package: "Core"),
                "Networking",
            ],
            path: "Sources/DataKit",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),

        // MARK: - Test Targets

        .testTarget(
            name: "NetworkingTests",
            dependencies: [
                "Networking",
                .product(name: "Domain", package: "Core"),
            ],
            path: "Tests/NetworkingTests",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),

        .testTarget(
            name: "DataKitTests",
            dependencies: [
                "DataKit",
                "Networking",
                .product(name: "Domain", package: "Core"),
            ],
            path: "Tests/DataKitTests",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
    ]
)
