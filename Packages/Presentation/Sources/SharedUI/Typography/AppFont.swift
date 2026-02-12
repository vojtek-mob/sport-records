import SwiftUI

// MARK: - Typography System
// Defines the complete type scale for the Sport Records app.
// Uses SF Pro (system font) with carefully chosen weights and sizes.
//
// Hierarchy:
//   title       → Hero titles on detail screens, empty states
//   headline    → Card names, section headers
//   subheadline → Secondary info (dates, durations on cards)
//   body        → Form row labels, detail content
//   callout     → Button text, badge labels
//   caption     → Section titles (uppercased), metadata
//   footnote    → Smallest text (IDs, fine print)

public struct AppTypography {
    // MARK: - Title (Hero / Detail Headers)
    /// 28pt, ExtraBold (-0.5 tracking)
    /// Used for: activity name on detail hero gradient
    public static let title = Font.system(size: 28, weight: .heavy)
    public static let titleTracking: CGFloat = -0.5

    // MARK: - Headline (Card Titles)
    /// 17pt, Bold (-0.3 tracking)
    /// Used for: activity name on grid cards
    public static let headline = Font.system(size: 17, weight: .bold)
    public static let headlineTracking: CGFloat = -0.3

    // MARK: - Subheadline (Supporting Info)
    /// 15pt, Medium
    /// Used for: category labels, hero metadata, subtitle counts
    public static let subheadline = Font.system(size: 15, weight: .medium)

    // MARK: - Body (Primary Content)
    /// 16pt, Medium
    /// Used for: form row labels, detail section rows, option labels
    public static let body = Font.system(size: 16, weight: .medium)

    // MARK: - Body Regular (Secondary Content)
    /// 16pt, Regular
    /// Used for: form row values, descriptions, settings values
    public static let bodyRegular = Font.system(size: 16, weight: .regular)

    // MARK: - Callout (Actions & Badges)
    /// 15pt, SemiBold
    /// Used for: save button, apply/reset buttons, badge text
    public static let callout = Font.system(size: 15, weight: .semibold)

    // MARK: - Caption (Section Headers)
    /// 13pt, SemiBold (0.8 tracking, uppercased)
    /// Used for: "ACTIVITY DETAILS", "SOURCE", "APPEARANCE"
    public static let caption = Font.system(size: 13, weight: .semibold)
    public static let captionTracking: CGFloat = 0.8

    // MARK: - Caption 2 (Small Labels)
    /// 13pt, Medium
    /// Used for: card date/duration, chip text, small inline labels
    public static let caption2 = Font.system(size: 13, weight: .medium)

    // MARK: - Footnote (Fine Print)
    /// 11pt, SemiBold
    /// Used for: small badge labels, tab bar labels
    public static let footnote = Font.system(size: 11, weight: .semibold)
}
