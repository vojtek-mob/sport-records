import SwiftUI
import UIKit

// MARK: - Shake Effect

/// Applies a horizontal shake / jiggle using `.offset(x:)`.
///
/// `animatableData` is interpolated by SwiftUI's animation system,
/// producing a sine-wave oscillation that returns to centre.
struct ShakeEffect: ViewModifier, Animatable {
    var animatableData: CGFloat
    var amount: CGFloat = 6
    var shakesPerUnit: Int = 3

    func body(content: Content) -> some View {
        content
            .offset(x: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)))
    }
}

// MARK: - Trigger Modifier

/// Fires a shake + error-color pulse every time `trigger` is incremented.
struct ShakeTriggerModifier: ViewModifier {
    @Environment(\.appTheme) private var theme
    @State private var attempts: CGFloat = 0
    @State private var showPulse = false

    var trigger: Int

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(animatableData: attempts))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.small)
                    .fill(showPulse ? theme.colors.error.opacity(0.15) : Color.clear)
                    .allowsHitTesting(false)
            )
            .onChange(of: trigger) { _, newValue in
                guard newValue > 0 else { return }

                // Haptic feedback for non-visual error perception
                UINotificationFeedbackGenerator().notificationOccurred(.error)

                // Shake
                withAnimation(.easeInOut(duration: 0.4)) {
                    attempts += 1
                }

                // Color pulse: flash in, then fade out
                withAnimation(.easeIn(duration: 0.1)) {
                    showPulse = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.easeOut(duration: 0.35)) {
                        showPulse = false
                    }
                }
            }
    }
}

// MARK: - View Extension

public extension View {
    /// Shakes (jiggles) the view horizontally with an error-color pulse
    /// each time `trigger` is incremented.
    func shake(trigger: Int) -> some View {
        modifier(ShakeTriggerModifier(trigger: trigger))
    }
}

// MARK: - Previews

#Preview("Shake Effect") {
    ShakeEffectPreview()
}

private struct ShakeEffectPreview: View {
    @State private var trigger = 0

    var body: some View {
        VStack(spacing: AppSpacing.sectionGapLarge) {
            TextField("Shake me", text: .constant(""))
                .textFieldStyle(.roundedBorder)
                .shake(trigger: trigger)
                .padding(.horizontal)

            Button("Trigger Shake") {
                trigger += 1
            }
        }
        .padding()
    }
}
