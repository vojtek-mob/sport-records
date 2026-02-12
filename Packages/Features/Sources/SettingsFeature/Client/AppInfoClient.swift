import ComposableArchitecture
import Foundation

/// TCA dependency client for reading app bundle info (version, build).
@DependencyClient
public struct AppInfoClient: Sendable {
    public var appVersion: @Sendable () -> String = { "–" }
    public var buildNumber: @Sendable () -> String = { "–" }
}

// MARK: - DependencyKey

extension AppInfoClient: DependencyKey {
    public static var liveValue: AppInfoClient {
        AppInfoClient(
            appVersion: {
                Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–"
            },
            buildNumber: {
                Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "–"
            }
        )
    }
}

extension DependencyValues {
    public var appInfoClient: AppInfoClient {
        get { self[AppInfoClient.self] }
        set { self[AppInfoClient.self] = newValue }
    }
}
