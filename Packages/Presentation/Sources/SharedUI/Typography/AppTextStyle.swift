import SwiftUI

/// Reusable text style view modifier.
///
/// Applies font, foreground color, and tracking in one call.
/// When no color is provided, defaults to the theme's `primaryText`.
struct AppTextStyle: ViewModifier {
    @Environment(\.appTheme) private var theme

    let font: Font
    let color: Color?
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(color ?? theme.colors.primaryText)
            .tracking(tracking)
    }
}

// MARK: - View Extension

public extension View {
    /// Applies a unified text style (font + color + tracking).
    ///
    /// Usage:
    /// ```swift
    /// Text("Sport Records")
    ///     .textStyle(AppTypography.title, tracking: AppTypography.titleTracking)
    ///
    /// Text("ACTIVITY DETAILS")
    ///     .textStyle(
    ///         AppTypography.caption,
    ///         color: theme.colors.secondaryText,
    ///         tracking: AppTypography.captionTracking
    ///     )
    /// ```
    func textStyle(
        _ font: Font,
        color: Color? = nil,
        tracking: CGFloat = 0
    ) -> some View {
        modifier(
            AppTextStyle(
                font: font,
                color: color,
                tracking: tracking
            )
        )
    }

    func textStyleTitle(color: Color? = nil) -> some View {
        textStyle(AppTypography.title, color: color, tracking: AppTypography.titleTracking)
    }

    func textStyleHeadline(color: Color? = nil) -> some View {
        textStyle(AppTypography.headline, color: color, tracking: AppTypography.headlineTracking)
    }

    func textStyleSubheadline(color: Color? = nil) -> some View {
        textStyle(AppTypography.subheadline, color: color, tracking: 0)
    }

    func textStyleBody(color: Color? = nil) -> some View {
        textStyle(AppTypography.body, color: color, tracking: 0)
    }

    func textStyleBodyRegular(color: Color? = nil) -> some View {
        textStyle(AppTypography.bodyRegular, color: color, tracking: 0)
    }

    func textStyleCallout(color: Color? = nil) -> some View {
        textStyle(AppTypography.callout, color: color, tracking: 0)
    }

    func textStyleCaption(color: Color? = nil) -> some View {
        textStyle(AppTypography.caption, color: color, tracking: AppTypography.captionTracking)
    }

    func textStyleCaption2(color: Color? = nil) -> some View {
        textStyle(AppTypography.caption2, color: color, tracking: 0)
    }

    func textStyleFootnote(color: Color? = nil) -> some View {
        textStyle(AppTypography.footnote, color: color, tracking: 0)
    }
}
