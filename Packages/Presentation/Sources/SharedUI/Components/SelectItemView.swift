import SwiftUI

public struct SelectItemView: View {
    private static let optionIconSize: CGFloat = 32

    @Environment(\.appTheme) private var theme
    @Environment(\.badgeTint) private var badgeTint

    private let title: LocalizedStringKey
    private let isSelected: Bool
    private let icon: Assets
    private let onTap: @MainActor @Sendable () -> Void

    public init(
        title: LocalizedStringKey,
        isSelected: Bool = false,
        icon: Assets,
        onTap: @escaping @MainActor @Sendable () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.icon = icon
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.medium) {
                badgeIconView
                titleView
                Spacer()
                checkmarkIconView
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Subviews

private extension SelectItemView {
    var titleView: some View {
        Text(title)
            .textStyleBody(color: titleColor())
    }

    @ViewBuilder
    var checkmarkIconView: some View {
        if isSelected {
            Assets.checkmark.image
                .textStyleCallout(color: theme.colors.appTint)
        }
    }

    var badgeIconView: some View {
        icon.image
            .textStyleBody(color: badgeForegroundColor())
            .frame(side: Self.optionIconSize)
            .background(badgeBackgroundColor())
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
            .accessibilityHidden(true)
    }
}

// MARK: - Helpers

private extension SelectItemView {
    func titleColor() -> Color {
        if let badgeTint = badgeTint {
            badgeTint.foreground
        } else {
            isSelected ? theme.colors.appTint : theme.colors.primaryText
        }
    }

    func badgeForegroundColor() -> Color {
        if let badgeTint = badgeTint {
            badgeTint.foreground
        } else {
            isSelected ? theme.colors.appTint : theme.colors.tertiaryText
        }
    }

    func badgeBackgroundColor() -> Color {
        if let badgeTint = badgeTint {
            badgeTint.background
        } else {
            isSelected ? theme.colors.appTintLight : theme.colors.inputBackground
        }
    }
}

// MARK: - Previews

#Preview("Default") {
    VStack(spacing: 16) {
        SelectItemView(
            title: "Local",
            isSelected: true,
            icon: .mobile,
            onTap: {}
        )

        Divider()
            .appDividerStyle()

        SelectItemView(
            title: "Remote",
            isSelected: false,
            icon: .cloud,
            onTap: {}
        )
    }
    .padding()
    .environment(\.appTheme, AppTheme(colors: .default))
}
