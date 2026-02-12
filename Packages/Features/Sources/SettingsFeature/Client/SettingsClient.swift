import ComposableArchitecture
import Foundation

/// TCA dependency client for user preferences.
@DependencyClient
public struct SettingsClient: Sendable {
    public var getAppearance: @Sendable () -> AppAppearance = { .system }
    public var setAppearance: @Sendable (AppAppearance) async -> Void
}

// MARK: - TestDependencyKey

extension SettingsClient: TestDependencyKey {
    public static let testValue = SettingsClient()
}

extension DependencyValues {
    public var settingsClient: SettingsClient {
        get { self[SettingsClient.self] }
        set { self[SettingsClient.self] = newValue }
    }
}
