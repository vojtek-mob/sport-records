// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Features",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(name: "SportRecordsFeature", targets: ["SportRecordsFeature"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Presentation"),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.17.0"
        ),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.58.0"),
    ],
    targets: [
        // MARK: - SportRecordsFeature
        // TCA reducers + views for sport records management.
        // Note: liveValue wiring lives in the App target (composition root),
        // so this module does NOT depend on DataKit or Networking.
        .target(
            name: "SportRecordsFeature",
            dependencies: [
                .product(name: "Domain", package: "Core"),
                .product(name: "SharedUI", package: "Presentation"),
                .product(name: "SharedFeatures", package: "Presentation"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/SportRecordsFeature",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),

        // MARK: - SettingsFeature
        // TCA reducers + views for app settings.
        .target(
            name: "SettingsFeature",
            dependencies: [
                .product(name: "SharedUI", package: "Presentation"),
                .product(name: "SharedFeatures", package: "Presentation"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/SettingsFeature",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),

        // MARK: - Test Targets
        .testTarget(
            name: "SportRecordsFeatureTests",
            dependencies: [
                "SportRecordsFeature",
                .product(name: "SharedFeatures", package: "Presentation"),
                .product(name: "Domain", package: "Core"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Tests/SportRecordsFeatureTests",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
        .testTarget(
            name: "SettingsFeatureTests",
            dependencies: [
                "SettingsFeature",
                .product(name: "SharedFeatures", package: "Presentation"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Tests/SettingsFeatureTests",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
    ]
)
