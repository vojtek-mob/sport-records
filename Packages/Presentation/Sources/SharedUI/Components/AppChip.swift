import SwiftUI

// MARK: - Filter Chip
// A selectable pill used in category and sort filters.
// Toggles between selected (tinted) and deselected (neutral) states.
public struct AppChip: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.badgeTint) private var badgeTint

    private static let borderWidth: CGFloat = 1.5

    private let label: LocalizedStringKey
    private let isSelected: Bool
    private let icon: Assets?
    private let style: ChipVariant
    private let onTap: () -> Void

    public init(
        label: LocalizedStringKey,
        isSelected: Bool,
        icon: Assets? = nil,
        style: ChipVariant = .capsule,
        onTap: @escaping () -> Void
    ) {
        self.label = label
        self.isSelected = isSelected
        self.icon = icon
        self.style = style
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            switch style {
            case .capsule:
                capsuleChip
            case .segment:
                segmentChip
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Subviews

private extension AppChip {
    var capsuleChip: some View {
        HStack(spacing: AppSpacing.extraSmall) {
            iconView
            labelView
        }
        .padding(.horizontal, AppSpacing.medium)
        .padding(.vertical, AppSpacing.small)
        .background(capsuleBackgroundColor())
        .overlay(
            Capsule()
                .strokeBorder(capsuleStrokeColor(), lineWidth: Self.borderWidth)
        )
        .clipShape(Capsule())
    }

    var segmentChip: some View {
        Text(label)
            .textStyleCallout(color: segmentForegroundColor())
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding(.vertical, AppSpacing.medium)
            .padding(.horizontal, AppSpacing.large)
            .background(segmentBackgroundColor())
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .buttonShadow()
    }

    @ViewBuilder
    var iconView: some View {
        if let icon {
            icon.image
                .font(.system(size: 14))
                .foregroundStyle(capsuleIconForegroundColor())
        }
    }

    var labelView: some View {
        Text(label)
            .textStyleCaption2(color: capsuleTextForegroundColor())
    }
}

// MARK: - Helpers

private extension AppChip {
    func capsuleBackgroundColor() -> Color {
        let selectedColor = badgeTint?.background ?? theme.colors.appTintLight
        return isSelected ? selectedColor : theme.colors.sectionBackground
    }

    func capsuleStrokeColor() -> Color {
        let selectedColor = badgeTint?.foreground ?? theme.colors.appTint
        return isSelected ? selectedColor : theme.colors.border
    }

    func capsuleIconForegroundColor() -> Color {
        let selectedColor = badgeTint?.foreground ?? theme.colors.appTint
        return isSelected ? selectedColor : theme.colors.tertiaryText
    }

    func capsuleTextForegroundColor() -> Color {
        let selectedColor = badgeTint?.foreground ?? theme.colors.appTint
        return isSelected ? selectedColor : theme.colors.primaryText
    }

    func segmentForegroundColor() -> Color {
        let selectedColor = badgeTint?.foreground ?? theme.colors.onAppTint
        return isSelected ? selectedColor : theme.colors.primaryText
    }

    func segmentBackgroundColor() -> Color {
        let selectedColor = badgeTint?.background ?? theme.colors.appTint
        return isSelected ? selectedColor : theme.colors.sectionBackground
    }
}

// MARK: - Variant

public extension AppChip {
    enum ChipVariant {
        case capsule
        case segment
    }
}

// MARK: - Previews

#Preview("Default") {
    VStack(spacing: AppSpacing.large) {
        AppChip(label: "Capsule", isSelected: true) {}
        AppChip(label: "Capsule", isSelected: true, icon: .runningFigure) {}
        AppChip(label: "Capsule", isSelected: false) {}
        AppChip(label: "Capsule", isSelected: false, icon: .dumbbellFilled) {}

        HStack(spacing: AppSpacing.small) {
            AppChip(label: "Segment long", isSelected: true, style: .segment) {}
            AppChip(label: "Segment", isSelected: false, style: .segment) {}
            AppChip(label: "Segment longer", isSelected: false, style: .segment) {}
        }
    }
    .padding()
}
