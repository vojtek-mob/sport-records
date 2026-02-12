import SwiftUI

/// App-wide theme configuration accessible via SwiftUI environment.
///
/// Colors are injected via environment (not static) so they can adapt to light/dark
/// and so we can override the palette in previews or tests. Layout tokens (spacing,
/// radii, dimensions) stay static in ``AppSpacing``, ``AppRadius``, and ``AppDimensions``
/// since we have no need today to vary layout per hierarchy.
public struct AppTheme: Sendable {
    public let colors: ColorTokens

    public init(colors: ColorTokens = .default) {
        self.colors = colors
    }

    public static let `default` = Self()
}

// MARK: - Environment Key

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme.default
}

extension EnvironmentValues {
    public var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}
