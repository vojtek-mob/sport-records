// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Presentation",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(name: "SharedUI", targets: ["SharedUI"]),
        .library(name: "SharedFeatures", targets: ["SharedFeatures"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.17.0"
        ),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.58.0"),
    ],
    targets: [
        // Theme, typography, reusable UI components. No feature dependencies.
        .target(
            name: "SharedUI",
            dependencies: [],
            path: "Sources/SharedUI",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),

        // Reusable TCA features (e.g. collapsible sections). Depends on SharedUI + TCA.
        .target(
            name: "SharedFeatures",
            dependencies: [
                "SharedUI",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/SharedFeatures",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
    ]
)
