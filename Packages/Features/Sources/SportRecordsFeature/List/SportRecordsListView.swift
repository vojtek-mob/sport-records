import ComposableArchitecture
import Domain
import SharedUI
import SwiftUI

public struct SportRecordsListView: View {
    private static let gridItemMinWidth: CGFloat = 160
    private static let gridItemMaxWidth: CGFloat = 200
    private static let dotIndicatorSize: CGFloat = 8
    private static let staggerDelayPerItem: Double = 0.06
    private static let cascadeDuration: Double = 0.45
    private static let initialOffsetY: CGFloat = 20

    @Bindable var store: StoreOf<SportRecordsListFeature>
    /// Drives the animation: when false, tiles are hidden; when true, they animate in with stagger.
    @State private var hasAppeared = false

    @Environment(\.appTheme) private var theme

    private let columns = [
        GridItem(.adaptive(minimum: gridItemMinWidth, maximum: gridItemMaxWidth), spacing: AppSpacing.medium)
    ]

    public init(store: StoreOf<SportRecordsListFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if store.filteredRecords.isEmpty && !store.isLoading {
                emptyState
            } else {
                recordsGrid
            }
        }
        .safeAreaInset(edge: .bottom) {
            if store.isRemoteUnavailable {
                offlineBanner
            }
        }
        .loadingOverlay(
            isPresented: store.isLoading && store.records.isEmpty,
            message: "records.loading"
        )
        .navigationTitle("records.title")
        .background(theme.colors.background)
        .toolbar {
            addToolbarItem
            filterToolbarItem
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        // When the list screen appears with data (e.g. user navigated back), run the cascade.
        .onAppear {
            store.send(.onAppear)
            if !store.filteredRecords.isEmpty {
                hasAppeared = false
                Task { hasAppeared = true }
            }
        }
        // When the set of displayed records changes (first load, filter change, or count change), run the cascade.
        // Observing ids catches 0→N, N→M, and same count but different records (e.g. different filter).
        // We defer hasAppeared = true so one frame is drawn with tiles hidden; then the transition animates.
        .onChange(of: Array(store.filteredRecords.map(\.id))) { oldIds, newIds in
            if !newIds.isEmpty && oldIds != newIds {
                hasAppeared = false
                Task { hasAppeared = true }
            }
        }
        // When the list becomes empty, reset so the next time we have records the cascade can run again.
        .onChange(of: store.filteredRecords.isEmpty) { _, isEmpty in
            if isEmpty { hasAppeared = false }
        }
    }
}

// MARK: - Subviews

private extension SportRecordsListView {
    var recordsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
                ForEach(Array(store.filteredRecords.enumerated()), id: \.element.id) { index, record in
                    Button {
                        store.send(.onRecordTapped(record))
                    } label: {
                        SportRecordTile(record: record)
                    }
                    .buttonStyle(.plain)
                    // Entrance: start hidden (below and transparent), then animate to visible
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : Self.initialOffsetY)
                    // Stagger: each tile’s animation is delayed by index so they cascade in one by one
                    .animation(
                        .easeOut(duration: Self.cascadeDuration)
                        .delay(Double(index) * Self.staggerDelayPerItem),
                        value: hasAppeared
                    )
                }
            }
            .screenPadding()
        }
    }

    var offlineBanner: some View {
        HStack(spacing: AppSpacing.small) {
            Assets.offline.image
                .foregroundStyle(theme.colors.alwaysWhiteTransparent80)

            Text("records.offlineBanner")
                .textStyleCaption2(color: theme.colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.large)
        .background(theme.colors.sectionBackground)
    }

    @ViewBuilder
    var emptyState: some View {
        let hasNoActiveFilter = store.filter.isEmpty

        EmptyStateView(
            icon: hasNoActiveFilter ? .runningFigure : . gearshape,
            title: "records.empty.title",
            message: hasNoActiveFilter
                ? "records.empty.message"
                : "records.empty.filteredMessage",
            actionTitle: hasNoActiveFilter ? "records.add" : nil,
            action: hasNoActiveFilter ? { store.send(.onAddTapped) } : nil
        )
        .frame(maxHeight: .infinity)
    }

    var addToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            let button = Button {
                store.send(.onAddTapped)
            } label: {
                if #available(iOS 26.0, *) {
                    Assets.plus.image
                        .foregroundStyle(theme.colors.onAppTint)
                        .frame(side: AppDimensions.iconButtonSize)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                        .accessibilityHidden(true)
                        .buttonShadow()
                } else {
                    Assets.plus.image
                        .foregroundStyle(theme.colors.onAppTint)
                        .frame(side: AppDimensions.iconButtonSize)
                        .background(theme.colors.appTint)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                        .accessibilityHidden(true)
                        .buttonShadow()
                }
            }
            .accessibilityLabel("records.accessibility.addRecord")

            if #available(iOS 26.0, *) {
                button
                    .buttonStyle(.borderedProminent)
            } else {
                button
            }
        }
    }

    var filterToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                store.send(.onFilterTapped)
            } label: {
                ZStack(alignment: .topTrailing) {
                    Assets.filter.image
                        .foregroundStyle(theme.colors.primaryText)
                        .frame(side: AppDimensions.iconButtonSize)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                        .buttonShadow()

                    if !store.filter.isEmpty {
                        Circle()
                            .fill(theme.colors.appTint)
                            .frame(side: Self.dotIndicatorSize)
                            .offset(x: -5, y: 5)
                    }
                }
                .accessibilityHidden(true)
            }
            .buttonStyle(.plain)
            .disabled(store.records.isEmpty)
            .accessibilityLabel("records.accessibility.filter")
        }
    }
}

// MARK: - Previews

#Preview("With Records") {
    NavigationStack {
        SportRecordsListView(
            store: Store(
                initialState: SportRecordsListFeature.State()
            ) {
                SportRecordsListFeature()
            } withDependencies: {
                $0.sportRecordsClient.fetchAll = {
                    SportRecordFetchResult(records: SportRecord.getMocks())
                }
            }
        )
    }
}

#Preview("Empty State") {
    NavigationStack {
        SportRecordsListView(
            store: Store(
                initialState: SportRecordsListFeature.State()
            ) {
                SportRecordsListFeature()
            } withDependencies: {
                $0.sportRecordsClient.fetchAll = {
                    SportRecordFetchResult(records: [])
                }
            }
        )
    }
}

#Preview("Offline Banner") {
    NavigationStack {
        SportRecordsListView(
            store: Store(
                initialState: SportRecordsListFeature.State()
            ) {
                SportRecordsListFeature()
            } withDependencies: {
                $0.sportRecordsClient.fetchAll = {
                    SportRecordFetchResult(records: SportRecord.getMocks(), isRemoteUnavailable: true)
                }
            }
        )
    }
}

fileprivate extension SportRecord {
    static func getMocks() -> [SportRecord] {
        [
            SportRecord(
                id: UUID(),
                name: "Morning Run",
                description: "Easy 5K through the park",
                category: .running,
                duration: 1_845,
                date: .now,
                createdAt: .now,
                source: .local
            ),
            SportRecord(
                id: UUID(),
                name: "Cycling Session",
                description: "50 km ride",
                category: .cycling,
                duration: 7_380,
                date: .now.addingTimeInterval(-86_400),
                createdAt: .now,
                source: .remote
            ),
            SportRecord(
                id: UUID(),
                name: "Pool Laps",
                description: "Swimming at the local pool",
                category: .swimming,
                duration: 2_700,
                date: .now.addingTimeInterval(-172_800),
                createdAt: .now,
                source: .local
            ),
        ]
    }
}
