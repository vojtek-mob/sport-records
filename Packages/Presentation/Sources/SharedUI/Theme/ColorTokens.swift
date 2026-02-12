import SwiftUI
import UIKit

/// Semantic color definitions for the app.
///
/// Every token is an adaptive `Color` that automatically switches
/// between a hand-picked light and dark variant based on the current
/// `UIUserInterfaceStyle`.
///
/// Many tokens are defined for future use — they establish the full
/// design-token vocabulary so new views can adopt them immediately.
public struct ColorTokens: Sendable {
    // MARK: - Backgrounds

    /// Main screen background — warm gray in light, deep navy in dark
    public let background: Color
    /// Card and section surface color
    public let sectionBackground: Color
    /// Input field background — subtle tint, never pure white/black
    public let inputBackground: Color

    // MARK: - Text

    /// Primary text — near-black in light, near-white in dark
    public let primaryText: Color
    /// Secondary text — muted for labels, metadata
    public let secondaryText: Color
    /// Tertiary text — placeholders, disabled states
    public let tertiaryText: Color

    // MARK: - Brand / Tint

    /// Primary app tint — emerald green
    public let appTint: Color
    /// Light tint for backgrounds behind tinted elements
    public let appTintLight: Color
    /// Text/icon color rendered on top of `appTint`
    public let onAppTint: Color

    // MARK: - Semantic

    /// Error / destructive action color
    public let error: Color
    /// Light error background for delete-style buttons
    public let errorLight: Color

    // MARK: - Borders & Separators

    /// Standard border color
    public let border: Color

    // MARK: - Local Source Gradients

    /// Local activity gradient — top color (darker emerald)
    public let localGradientTop: Color
    /// Local activity gradient — bottom color (lighter emerald)
    public let localGradientBottom: Color
    /// Local accent for badges and labels
    public let localAccent: Color
    /// Local badge background — soft emerald tint
    public let localBadge: Color

    // MARK: - Remote Source Gradients

    /// Remote activity gradient — top color (darker blue)
    public let remoteGradientTop: Color
    /// Remote activity gradient — bottom color (lighter blue)
    public let remoteGradientBottom: Color
    /// Remote accent for badges and labels
    public let remoteAccent: Color
    /// Remote badge background — soft blue tint
    public let remoteBadge: Color

    // MARK: - Overlay & Shadow

    /// Modal overlay — semi-transparent dark
    public let overlay: Color
    /// Shadow color for cards
    public let shadow: Color

    // MARK: - Invariant

    /// Pure white — identical in light and dark mode
    public let alwaysWhite: Color
    /// White at 20 % opacity — identical in light and dark mode
    public let alwaysWhiteTransparent20: Color
    /// White at 50 % opacity — identical in light and dark mode
    public let alwaysWhiteTransparent50: Color
    /// White at 80 % opacity — identical in light and dark mode
    public let alwaysWhiteTransparent80: Color
}

// MARK: - Default Palette

extension ColorTokens {
    public static let `default` = Self(
        // Backgrounds
        background: adaptive(light: "#F2F5F9", dark: "#0A0E14"),
        sectionBackground: adaptive(light: "#FFFFFF", dark: "#151A23"),
        inputBackground: adaptive(light: "#F5F7FA", dark: "#1A2030"),

        // Text
        primaryText: adaptive(light: "#0F1A2E", dark: "#F0F2F5"),
        secondaryText: adaptive(light: "#5A6578", dark: "#8B95A8"),
        tertiaryText: adaptive(light: "#8E99AB", dark: "#5A6578"),

        // Brand / Tint
        appTint: adaptive(light: "#0EA47A", dark: "#34D399"),
        appTintLight: adaptive(
            light: "#E8F8F3",
            dark: "#34D399",
            darkOpacity: 0.12
        ),
        onAppTint: adaptive(light: "#FFFFFF", dark: "#0A0E14"),

        // Semantic
        error: adaptive(light: "#E5484D", dark: "#F87171"),
        errorLight: adaptive(
            light: "#FFF0F0",
            dark: "#F87171",
            darkOpacity: 0.12
        ),

        // Borders & Separators
        border: adaptive(light: "#E2E6ED", dark: "#1F2937"),

        // Local Source Gradients
        localGradientTop: adaptive(light: "#0EA47A", dark: "#059669"),
        localGradientBottom: adaptive(light: "#06C48D", dark: "#10B981"),
        localAccent: adaptive(light: "#0EA47A", dark: "#34D399"),
        localBadge: adaptive(
            light: "#E8F8F3",
            dark: "#34D399",
            darkOpacity: 0.15
        ),

        // Remote Source Gradients
        remoteGradientTop: adaptive(light: "#3B82F6", dark: "#2563EB"),
        remoteGradientBottom: adaptive(light: "#60A5FA", dark: "#3B82F6"),
        remoteAccent: adaptive(light: "#3B82F6", dark: "#60A5FA"),
        remoteBadge: adaptive(
            light: "#EEF4FF",
            dark: "#60A5FA",
            darkOpacity: 0.15
        ),

        // Overlay & Shadow
        overlay: adaptive(
            light: "#0F1A2E",
            lightOpacity: 0.4,
            dark: "#000000",
            darkOpacity: 0.6
        ),
        shadow: adaptive(
            light: "#0F1A2E",
            lightOpacity: 0.08,
            dark: "#000000",
            darkOpacity: 0.3
        ),

        // Invariant
        alwaysWhite: Color.white,
        alwaysWhiteTransparent20: Color.white.opacity(0.2),
        alwaysWhiteTransparent50: Color.white.opacity(0.5),
        alwaysWhiteTransparent80: Color.white.opacity(0.8)
    )
}

// MARK: - Adaptive Hex Helpers

extension ColorTokens {
    /// Creates an adaptive color with independent opacities for each scheme.
    private static func adaptive(
        light: String,
        lightOpacity: CGFloat = 1,
        dark: String,
        darkOpacity: CGFloat = 1
    ) -> Color {
        let lightRGB = hexToRGB(light)
        let darkRGB = hexToRGB(dark)

        return Color(UIColor { traits in
            let isDark = traits.userInterfaceStyle == .dark
            let (red, green, blue) = isDark ? darkRGB : lightRGB
            let alpha = isDark ? darkOpacity : lightOpacity
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        })
    }

    /// Parses a hex string (`"#RRGGBB"` or `"RRGGBB"`) into normalised RGB components.
    private static func hexToRGB(_ hex: String) -> (CGFloat, CGFloat, CGFloat) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let red = CGFloat((int >> 16) & 0xFF) / 255
        let green = CGFloat((int >> 8) & 0xFF) / 255
        let blue = CGFloat(int & 0xFF) / 255
        return (red, green, blue)
    }
}
