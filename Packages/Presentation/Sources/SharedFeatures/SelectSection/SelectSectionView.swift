import ComposableArchitecture
import SharedUI
import SwiftUI

/// View for a collapsible section of selectable items, driven by `SelectSectionFeature`.
///
/// Usage:
/// ```swift
/// SelectSectionView(
///     "filter.source",
///     store: store.scope(state: \.sourceSection, action: \.sourceSection)
/// )
/// ```
public struct SelectSectionView: View {
    @Bindable var store: StoreOf<SelectSectionFeature>

    @Environment(\.appTheme) private var theme

    private let header: LocalizedStringKey
    private let badgeTintForItem: ((SelectItem) -> BadgeTint?)?

    public init(
        _ header: LocalizedStringKey,
        store: StoreOf<SelectSectionFeature>,
        badgeTintForItem: ((SelectItem) -> BadgeTint?)? = nil
    ) {
        self.header = header
        self.store = store
        self.badgeTintForItem = badgeTintForItem
    }

    public var body: some View {
        AppSection(header, isExpanded: $store.isExpanded, isSeparated: true) {
            ForEach(store.items) { item in
                selectItemView(item)
            }
        }
    }
}

// MARK: - Subviews

private extension SelectSectionView {
    @ViewBuilder
    func selectItemView(_ item: SelectItem) -> some View {
        let selectItemView = SelectItemView(
            title: item.title,
            isSelected: item.isSelected,
            icon: item.icon,
            onTap: { store.send(.itemTapped(item.id)) }
        )

        if let badgeTint = badgeTintForItem?(item) {
            selectItemView
                .badgeTint(foreground: badgeTint.foreground, background: badgeTint.background)
        } else {
            selectItemView
        }
    }
}

// MARK: - Previews

#Preview("Single Select") {
    SelectSectionView(
        "Appearance",
        store: Store(
            initialState: SelectSectionFeature.State(
                items: [
                    SelectItem(id: "system", title: "System", icon: .mobile, isSelected: true),
                    SelectItem(id: "light", title: "Light", icon: .sun),
                    SelectItem(id: "dark", title: "Dark", icon: .moon),
                ],
                selectionMode: .single
            )
        ) {
            SelectSectionFeature()
        }
    )
    .padding()
}

#Preview("Multi Select") {
    SelectSectionView(
        "Sources",
        store: Store(
            initialState: SelectSectionFeature.State(
                items: [
                    SelectItem(id: "local", title: "Local", icon: .mobile, isSelected: true),
                    SelectItem(id: "remote", title: "Remote", icon: .cloud, isSelected: true),
                ],
                selectionMode: .multi
            )
        ) {
            SelectSectionFeature()
        }
    )
    .padding()
}
