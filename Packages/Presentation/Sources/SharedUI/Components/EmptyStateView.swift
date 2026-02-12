import SwiftUI

/// Empty state placeholder displayed when a list has no content.
public struct EmptyStateView: View {
    private static let iconSize: CGFloat = 80
    private static let iconScale: CGFloat = 0.5

    @Environment(\.appTheme) private var theme

    private let icon: Assets
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey
    private let actionTitle: LocalizedStringKey?
    private let action: (() -> Void)?

    public init(
        icon: Assets,
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        actionTitle: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: AppSpacing.medium) {
            iconView
            titleView
            messageView
            actionButton
        }
        .screenPadding()
        .background(theme.colors.background)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Subviews

private extension EmptyStateView {
    var iconView: some View {
        icon.image
            .font(.system(size: Self.iconSize * Self.iconScale))
            .foregroundStyle(theme.colors.appTint)
            .frame(side: Self.iconSize)
            .background(theme.colors.appTintLight)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    var titleView: some View {
        Text(title)
            .textStyleTitle()
    }

    var messageView: some View {
        Text(message)
            .textStyleSubheadline(color: theme.colors.secondaryText)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    var actionButton: some View {
        if let actionTitle, let action {
            AppButton(title: actionTitle, action: action)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}

// MARK: - Previews

#Preview("With Action") {
    EmptyStateView(
        icon: .runningFigure,
        title: "No Sport Records",
        message: "Start tracking your activities by adding your first record.",
        actionTitle: "Add Record",
        action: {}
    )
}

#Preview("Without Action") {
    EmptyStateView(
        icon: .gearshape,
        title: "No Results",
        message: "Try adjusting your filters."
    )
}
