import SwiftUI

/// A layout that arranges its children horizontally, wrapping to the next
/// row when the available width is exceeded.
///
/// Uses the `Layout` protocol (iOS 16+) for correct, measurable behaviour
/// inside `ScrollView`, sheets, and adaptive containers.
///
/// Usage:
/// ```swift
/// FlowLayout(spacing: 8) {
///     ForEach(tags) { tag in
///         AppChip(label: tag.name, isSelected: true) {}
///     }
/// }
/// ```
public struct FlowLayout: Layout {
    private let spacing: CGFloat

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    // MARK: - Layout

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let result = arrange(subviews: subviews, in: proposal.width ?? .infinity)
        return result.size
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let result = arrange(subviews: subviews, in: bounds.width)

        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(
                    x: bounds.minX + position.x,
                    y: bounds.minY + position.y
                ),
                proposal: ProposedViewSize(subviews[index].sizeThatFits(.unspecified))
            )
        }
    }
}

// MARK: - Arrangement

private extension FlowLayout {
    struct ArrangementResult {
        var positions: [CGPoint]
        var size: CGSize
    }

    func arrange(subviews: Subviews, in availableWidth: CGFloat) -> ArrangementResult {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            // Wrap to next row if this subview exceeds the available width.
            if currentX + size.width > availableWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))

            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }

        let totalHeight = currentY + rowHeight
        return ArrangementResult(
            positions: positions,
            size: CGSize(width: totalWidth, height: totalHeight)
        )
    }
}
