import SwiftUI

/// Reusable view modifier that applies the standard Divider appearance
struct AppDividerStyle: ViewModifier {
    @Environment(\.appTheme) private var theme

    func body(content: Content) -> some View {
        content
            .overlay(theme.colors.tertiaryText)
    }
}

// MARK: - View Extensions

public extension View {
    func appDividerStyle() -> some View {
        modifier(AppDividerStyle())
    }
}
