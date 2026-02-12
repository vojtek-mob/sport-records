import SwiftUI

// MARK: - Spacing Tokens

/// Consistent spacing scale (margins, padding, gaps) based on a 4pt grid.
/// Every margin, padding, and gap in the app references these values.
///
/// Kept as static constants (not environment) because layout is a single global system
/// and we have no current need to override spacing per hierarchy (e.g. compact vs regular).
/// Corner radii and icon/container sizes live in ``AppRadius`` and ``AppDimensions``.
public struct AppSpacing {
    // MARK: - Base Grid (4pt)

    /// 4pt — Icon-to-text gaps inside tight badges
    public static let extraSmall: CGFloat = 4

    /// 8pt — Standard small gap (between related elements)
    public static let small: CGFloat = 8

    /// 12pt — Grid gap between cards, list item spacing
    public static let medium: CGFloat = 12

    /// 16pt — Standard horizontal padding, section padding
    public static let large: CGFloat = 16

    /// 20pt — Screen horizontal margins, header padding
    public static let screenHorizontal: CGFloat = 20

    /// 28pt — Extra spacing between major sections
    public static let sectionGapLarge: CGFloat = 28
}
