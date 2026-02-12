import ComposableArchitecture
import Domain
import SharedFeatures
import SharedUI
import SwiftUI

public struct SportRecordsFilterView: View {
    @Bindable var store: StoreOf<SportRecordsFilterFeature>

    @Environment(\.appTheme) private var theme

    public init(store: StoreOf<SportRecordsFilterFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGapLarge) {
                    sourceSection
                    categorySection
                    sortBySection
                    searchSection
                    buttonsSections
                }
                .screenPadding()
            }
            .navigationTitle("filter.title")
            .navigationBarTitleDisplayMode(.inline)
            .background(theme.colors.background)
            .toolbar { doneToolbarItem }
        }
    }
}

// MARK: - Subviews

private extension SportRecordsFilterView {
    var sourceSection: some View {
        SelectSectionView(
            "filter.source",
            store: store.scope(state: \.sourceSection, action: \.sourceSection),
            badgeTintForItem: { item in
                // Resolve badge tint in the view layer: theme is only available here via @Environment,
                // while reducer state (sourceSection items) is built without theme. Keeping theme-derived
                // appearance out of state keeps the reducer pure and testable; the view owns presentation.
                guard let source = RecordSource(rawValue: item.id) else { return nil }
                return source.badgeTint(theme: theme)
            }
        )
    }

    var categorySection: some View {
        AppSection("filter.category", style: .plain) {
            FlowLayout(spacing: AppSpacing.small) {
                ForEach(SportCategory.allCases) { category in
                    AppChip(
                        label: category.displayName,
                        isSelected: store.filter.categories.contains(category),
                        icon: category.icon
                    ) {
                        store.send(.categoryTapped(category))
                    }
                }
            }
        }
    }

    var sortBySection: some View {
        AppSection("filter.sortBy", style: .plain) {
            HStack(spacing: AppSpacing.small) {
                ForEach(SportRecordSort.allCases) { sort in
                    AppChip(
                        label: sort.displayName,
                        isSelected: store.sort == sort,
                        style: .segment
                    ) {
                        store.send(.sortTapped(sort))
                    }
                }
            }
        }
    }

    var searchSection: some View {
        AppSection("filter.search") {
            let localizedPlaceholder = String(localized: "filter.searchPlaceholder", bundle: .main)
            TextField("\(Assets.magnifyingglass.image) \(localizedPlaceholder)", text: $store.filter.searchText)
                .textStyleSubheadline()
                .textInputAutocapitalization(.never)
        }
    }

    var buttonsSections: some View {
        VStack(spacing: AppSpacing.small) {
            AppButton(title: "filter.apply", style: .tint) {
                store.send(.onApplyTapped)
            }

            AppButton(title: "filter.reset", style: .destructive) {
                store.send(.onResetTapped)
            }
        }
    }

    var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                store.send(.onDismissTapped)
            } label: {
                Assets.close.image
                    .accessibilityHidden(true)
            }
            .accessibilityLabel("filter.accessibility.close")
        }
    }
}

// MARK: - Helpers

extension SportRecordSort {
    var displayName: LocalizedStringKey {
        switch self {
        case .byDate: "filter.sort.date"
        case .byName: "filter.sort.name"
        case .byDuration: "filter.sort.duration"
        }
    }
}

// MARK: - Previews

#Preview("Filters") {
    SportRecordsFilterView(
        store: Store(
            initialState: SportRecordsFilterFeature.State()
        ) {
            SportRecordsFilterFeature()
        }
    )
}
