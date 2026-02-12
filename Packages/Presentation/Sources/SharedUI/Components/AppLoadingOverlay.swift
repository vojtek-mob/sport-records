import SwiftUI

/// Semi-transparent overlay with a centered spinner.
///
/// Use as a standalone view inside `.overlay { }` or, preferably,
/// through the convenience modifier:
/// ```swift
/// .loadingOverlay(isPresented: store.isSaving)
/// ```
public struct AppLoadingOverlay: View {
    @Environment(\.appTheme) private var theme

    private let message: LocalizedStringKey?

    public init(message: LocalizedStringKey? = nil) {
        self.message = message
    }

    public var body: some View {
        ZStack {
            theme.colors.overlay
                .ignoresSafeArea()
                .accessibilityHidden(true)

            ProgressView {
                if let message {
                    Text(message)
                        .textStyleCaption2(color: theme.colors.secondaryText)
                }
            }
            .controlSize(.large)
            .tint(theme.colors.appTint)
            .padding(AppSpacing.sectionGapLarge)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .fill(theme.colors.sectionBackground)
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("accessibility.loading")
        .onAppear {
            UIAccessibility.post(
                notification: .announcement,
                argument: NSLocalizedString("accessibility.loading", comment: "")
            )
        }
    }
}

// MARK: - View Extension

public extension View {
    /// Conditionally overlays a loading spinner with a dimmed backdrop.
    func loadingOverlay(
        isPresented: Bool,
        message: LocalizedStringKey? = nil
    ) -> some View {
        overlay {
            if isPresented {
                AppLoadingOverlay(message: message)
            }
        }
    }
}

// MARK: - Previews

#Preview("Without Message") {
    Color.clear
        .loadingOverlay(isPresented: true)
}

#Preview("With Message") {
    Color.clear
        .loadingOverlay(isPresented: true, message: "Saving…")
}
