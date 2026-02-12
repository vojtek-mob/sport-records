import SwiftUI

// MARK: - Corner Radius

/// Corner radius tokens for shapes (cards, buttons, chips, etc.).
/// Kept separate from spacing so layout semantics stay clear.
public struct AppRadius {
    /// 8pt — Small elements (option icons, duration buttons)
    public static let small: CGFloat = 8

    /// 12pt — Card icon containers, search fields, back buttons
    public static let medium: CGFloat = 12

    /// 16pt — Cards, section containers, buttons
    public static let large: CGFloat = 16
}
