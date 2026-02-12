import SharedUI
import SwiftUI

/// A selectable row inside a `SelectSectionFeature`.
///
/// `Equatable` is implemented manually because `LocalizedStringKey`
/// does not conform to `Equatable`. Since `title` is immutable and
/// derived from `id`, comparing `id` + `isSelected` is sufficient.
///
/// Marked `@unchecked Sendable` because `LocalizedStringKey` is a
/// frozen, value-type struct that is thread-safe but lacks the
/// conformance annotation.
public struct SelectItem: Identifiable, @unchecked Sendable {
    public let id: String
    public let title: LocalizedStringKey
    public let icon: Assets
    public var isSelected: Bool

    public init(
        id: String,
        title: LocalizedStringKey,
        icon: Assets,
        isSelected: Bool = false
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
    }
}

extension SelectItem: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.isSelected == rhs.isSelected
    }
}
