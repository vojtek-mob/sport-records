import SharedUI
import SwiftUI

extension AppAppearance {
    public var displayName: LocalizedStringKey {
        switch self {
        case .system: "appearance.system"
        case .light: "appearance.light"
        case .dark: "appearance.dark"
        }
    }

    /// Maps to SwiftUI `ColorScheme`. Returns `nil` for `.system` so the
    /// OS default is used.
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    public var icon: Assets {
        switch self {
        case .system: .mobile
        case .light: .sun
        case .dark: .moon
        }
    }
}
