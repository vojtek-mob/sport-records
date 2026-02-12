import Domain
import SharedUI
import SwiftUI

extension SportCategory {
    var displayName: LocalizedStringKey {
        switch self {
        case .running:  "sportCategory.running"
        case .cycling:  "sportCategory.cycling"
        case .swimming: "sportCategory.swimming"
        case .gym:      "sportCategory.gym"
        case .hiking:   "sportCategory.hiking"
        case .other:    "sportCategory.other"
        }
    }

    var icon: Assets {
        switch self {
        case .running: .runningFigure
        case .cycling: .cyclingFigure
        case .swimming: Assets.swimmingFigure
        case .gym: .dumbbellFilled
        case .hiking: .hikingFigure
        case .other: .trophyFilled
        }
    }
}

extension RecordSource {
    var displayName: LocalizedStringKey {
        switch self {
        case .local:  "recordSource.local"
        case .remote: "recordSource.remote"
        }
    }

    var icon: Assets {
        switch self {
        case .local:  .mobile
        case .remote: .cloud
        }
    }

    func badgeTint(theme: AppTheme) -> BadgeTint {
        switch self {
        case .local:
            BadgeTint(foreground: theme.colors.localAccent, background: theme.colors.localBadge)
        case .remote:
            BadgeTint(foreground: theme.colors.remoteAccent, background: theme.colors.remoteBadge)
        }
    }
}
