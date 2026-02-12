import SwiftUI

/// Reusable shadow style view modifier.
struct AppShadowStyle: ViewModifier {
    @Environment(\.appTheme) private var theme

    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: theme.colors.shadow, radius: radius, x: x, y: y)
    }
}

// MARK: - View Extensions

public extension View {
    /// Elevated shadow for activity grid cards, sections, ect.
    func elevatedShadow() -> some View {
        modifier(AppShadowStyle(radius: 12, x: 0, y: 4))
    }

    /// Button shadow for primary buttons
    func buttonShadow() -> some View {
        modifier(AppShadowStyle(radius: 8, x: 0, y: 4))
    }
}
