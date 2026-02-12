import ComposableArchitecture
import Foundation
import SettingsFeature

// Settings are persisted via UserDefaults. For the PoC this is sufficient.
// For a production app, consider migrating to a more robust solution if needed.

extension SettingsClient: @retroactive DependencyKey {
    public static var liveValue: SettingsClient {
        let appearanceKey = "app_appearance"

        return SettingsClient(
            getAppearance: {
                guard let raw = UserDefaults.standard.string(forKey: appearanceKey) else { return .system }
                return AppAppearance(rawValue: raw) ?? .system
            },
            setAppearance: { appearance in
                UserDefaults.standard.set(appearance.rawValue, forKey: appearanceKey)
            }
        )
    }
}
