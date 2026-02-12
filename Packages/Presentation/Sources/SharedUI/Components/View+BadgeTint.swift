import SwiftUI

// MARK: - Badge Tint

/// Overrides the badge icon colors in ``SelectItemView``.
///
/// When no tint is provided via the environment, the view falls back to
/// `theme.colors.localAccent` for the foreground and `.clear` for the background.
///
/// Apply with the convenience modifier:
/// ```swift
/// SelectItemView(title: "Local", icon: .mobile, onTap: { })
///     .badgeTint(foreground: .white, background: .blue)
/// ```
public struct BadgeTint: Sendable {
    public let foreground: Color
    public let background: Color

    public init(foreground: Color, background: Color) {
        self.foreground = foreground
        self.background = background
    }
}

// MARK: - Environment Key

private struct BadgeTintKey: EnvironmentKey {
    static let defaultValue: BadgeTint? = nil
}

extension EnvironmentValues {
    public var badgeTint: BadgeTint? {
        get { self[BadgeTintKey.self] }
        set { self[BadgeTintKey.self] = newValue }
    }
}

// MARK: - View Modifier

/// Sets the badge tint for any `View` in this view hierarchy
extension View {
    public func badgeTint(foreground: Color, background: Color) -> some View {
        environment(\.badgeTint, BadgeTint(foreground: foreground, background: background))
    }

    public func badgeTint(_ badgeTint: BadgeTint) -> some View {
        environment(\.badgeTint, badgeTint)
    }
}
