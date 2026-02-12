import Domain
import SharedUI
import SwiftUI

/// A compact tile that displays a sport record's category icon, name, date, and duration.
///
/// Used inside a `LazyVGrid` on the records list screen.
/// The tile's background gradient varies based on the record's ``RecordSource``.
struct SportRecordTile: View {
    private static let categoryIconSize: CGFloat = 40
    private static let sourceIconSize: CGFloat = 22
    private static let iconScale: CGFloat = 0.55
    private static let nameLineLimit: Int = 2
    private static let dotCircleSize: CGFloat = 3
    private static let minCardHeight: CGFloat = 140

    @Environment(\.appTheme) private var theme

    let record: SportRecord

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            topRow
            Spacer()
            nameView
            bottomRow
        }
        .padding(AppSpacing.large)
        .frame(minHeight: Self.minCardHeight)
        .background(tileBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large))
        .elevatedShadow()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            Text(record.category.displayName) +
            Text(": \(record.name)")
        )
    }
}

// MARK: - Subviews

private extension SportRecordTile {
    var tileBackground: some View {
        LinearGradient(
            colors: gradientColors(for: record.source),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var topRow: some View {
        HStack {
            categoryIcon
            Spacer()
            sourceIcon
        }
    }

    var nameView: some View {
        Text(record.name)
            .textStyleHeadline(color: theme.colors.alwaysWhite)
            .lineLimit(Self.nameLineLimit)
    }

    var bottomRow: some View {
        HStack(spacing: AppSpacing.small) {
            dateView
            dotSeparator
            durationView
        }
        .padding(.top, AppSpacing.extraSmall)
    }

    var categoryIcon: some View {
        record.category.icon.image
            .font(.system(size: Self.categoryIconSize * Self.iconScale, weight: .semibold))
            .foregroundStyle(theme.colors.alwaysWhite)
            .frame(side: Self.categoryIconSize)
            .background(theme.colors.alwaysWhiteTransparent20)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
            .accessibilityHidden(true)
    }

    var sourceIcon: some View {
        record.source.icon.image
            .font(.system(size: Self.sourceIconSize * Self.iconScale))
            .foregroundStyle(theme.colors.alwaysWhite)
            .frame(side: Self.sourceIconSize)
            .background(theme.colors.alwaysWhiteTransparent20)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }

    var dateView: some View {
        Text(record.date.relativeDescription.capitalized)
            .textStyleCaption2(color: theme.colors.alwaysWhiteTransparent80)
    }

    var dotSeparator: some View {
        Circle()
            .fill(theme.colors.alwaysWhiteTransparent50)
            .frame(side: Self.dotCircleSize)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    var durationView: some View {
        if let formattedDuration = record.formattedDuration {
            Text(formattedDuration)
                .textStyleCaption2(color: theme.colors.alwaysWhiteTransparent80)
        }
    }
}

// MARK: - Helpers

private extension SportRecordTile {
    func gradientColors(for source: RecordSource) -> [Color] {
        switch source {
        case .local:
            [
                theme.colors.localGradientTop,
                theme.colors.localGradientBottom,
            ]
        case .remote:
            [
                theme.colors.remoteGradientTop,
                theme.colors.remoteGradientBottom,
            ]
        }
    }
}

// MARK: - Preview

#Preview("Sport Record Tile") {
    SportRecordTile(
        record: SportRecord(
            id: UUID(),
            name: "Morning Run",
            description: "Easy 5K through the park",
            category: .running,
            duration: 1_845,
            date: .now,
            createdAt: .now,
            source: .local
        )
    )
    .padding()
    .frame(width: 250, height: 240)
}
