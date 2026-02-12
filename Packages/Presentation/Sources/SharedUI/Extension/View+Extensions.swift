import SwiftUI

// MARK: - Convenience frame

public extension View {
    func frame(side: CGFloat) -> some View {
        self.frame(width: side, height: side)
    }
}

// MARK: - Convenience Padding Modifiers

public extension View {
    /// Standard screen horizontal padding (20pt)
    func screenPadding() -> some View {
        padding(
            EdgeInsets(
                top: AppSpacing.sectionGapLarge,
                leading: AppSpacing.screenHorizontal,
                bottom: AppSpacing.sectionGapLarge,
                trailing: AppSpacing.screenHorizontal
            )
        )
    }
}
