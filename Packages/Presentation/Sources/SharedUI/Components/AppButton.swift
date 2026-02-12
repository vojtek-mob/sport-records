import SwiftUI

// MARK: - Primary Button
// Full-width CTA button with shadow and spring press animation.
public struct AppButton: View {
    @Environment(\.appTheme) private var theme

    private static let buttonIconSize: CGFloat = 18

    private let title: LocalizedStringKey
    private let icon: Assets?
    private let style: ButtonVariant
    private let action: () -> Void

    public init(
        title: LocalizedStringKey,
        icon: Assets? = nil,
        style: ButtonVariant = .tint,
        action: (@escaping () -> Void)
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                iconView
                titleView
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.large)
            .padding(.horizontal, AppSpacing.large)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        }
        .buttonStyle(ScaleButtonStyle())
        .buttonShadow()
    }
}

// MARK: - Subviews

private extension AppButton {
    @ViewBuilder
    var iconView: some View {
        if let icon {
            icon.image
                .font(.system(size: Self.buttonIconSize))
        }
    }

    var titleView: some View {
        Text(title)
            .textStyleBody(color: foregroundColor)
    }
}

// MARK: - Helpers

private extension AppButton {
    var foregroundColor: Color {
        switch style {
        case .tint:
            theme.colors.onAppTint
        case .destructive:
            theme.colors.error
        }
    }

    var backgroundColor: Color {
        switch style {
        case .tint:
            theme.colors.appTint
        case .destructive:
            theme.colors.errorLight
        }
    }
}

// MARK: - Variant

public extension AppButton {
    enum ButtonVariant {
        case tint
        case destructive
    }
}

// MARK: - Previews

#Preview("Default") {
    VStack(spacing: AppSpacing.large) {
        AppButton(title: "Save Record") {}

        AppButton(title: "Save with icon", icon: .clipboard) {}

        AppButton(title: "Fixed") {}
            .fixedSize(horizontal: true, vertical: false)

        AppButton(title: "Delete Record", style: .destructive) {}

        AppButton(title: "Delete with icon", icon: .bin, style: .destructive) {}
    }
    .padding()
}
