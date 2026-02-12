import SwiftUI

/// App-wide labeled-content wrapper providing consistent, centralized styling.
///
/// Wraps the native SwiftUI `LabeledContent` and applies design-token–based
/// typography to both the label and the value.
///
/// - The label receives the theme's `primaryText` color (default).
/// - The value always receives `secondaryText`.
///
/// Usage:
/// ```swift
/// // Plain string value
/// AppLabeledContent("settings.version", value: "1.0.0")
///
/// // Custom content (e.g. dates)
/// AppLabeledContent("record.date") {
///     Text(date, style: .date)
/// }
///
/// // Override font (e.g. for de-emphasised metadata)
/// AppLabeledContent("record.id", value: id, font: AppTypography.footnote)
/// ```
public struct AppLabeledContent<Content: View>: View {
    @Environment(\.appTheme) private var theme

    private let label: LocalizedStringKey
    private let font: Font
    private let tracking: CGFloat
    private let content: Content

    /// Creates a labeled content view with a custom content builder.
    public init(
        _ label: LocalizedStringKey,
        font: Font = AppTypography.bodyRegular,
        tracking: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.font = font
        self.tracking = tracking
        self.content = content()
    }

    public var body: some View {
        LabeledContent {
            content
                .textStyle(font, color: theme.colors.secondaryText)
        } label: {
            Text(label)
                .textStyleBody(color: theme.colors.primaryText)
        }
    }
}

// MARK: - Convenience Init

extension AppLabeledContent where Content == Text {
    /// Creates a labeled content view with a plain string value.
    public init(
        _ label: LocalizedStringKey,
        value: String,
        font: Font = AppTypography.body,
        tracking: CGFloat = 0
    ) {
        self.label = label
        self.font = font
        self.tracking = tracking
        self.content = Text(value)
    }

    /// Creates a labeled content view with a localized value.
    public init(
        _ label: LocalizedStringKey,
        value: LocalizedStringKey,
        font: Font = AppTypography.body,
        tracking: CGFloat = 0
    ) {
        self.label = label
        self.font = font
        self.tracking = tracking
        self.content = Text(value)
    }
}

// MARK: - Previews

#Preview("In AppSection") {
    AppSection("About") {
        AppLabeledContent("Version", value: "1.0.0")
        Divider().appDividerStyle()
        AppLabeledContent("Build", value: "42")
        Divider().appDividerStyle()
        AppLabeledContent("Date") {
            Text(Date.now, style: .date)
                .textStyleBodyRegular()
        }
    }
    .padding()
}
