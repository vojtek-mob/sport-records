import ComposableArchitecture
import Domain
import SharedUI
import SwiftUI

public struct SportRecordDetailView: View {
    @Bindable var store: StoreOf<SportRecordDetailFeature>

    @Environment(\.appTheme) private var theme

    public init(store: StoreOf<SportRecordDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGapLarge) {
                activitySection
                descriptionSection
                metadataSection
                deleteButton
            }
            .screenPadding()
        }
        .navigationTitle(store.record.name)
        .background(theme.colors.background)
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Subviews

private extension SportRecordDetailView {
    var activitySection: some View {
        AppSection("records.detail.activity", isExpanded: $store.isActivityExpanded, isSeparated: true) {
            AppLabeledContent("records.detail.name", value: store.record.name)
            AppLabeledContent("records.detail.category", value: store.record.category.displayName)

            if let formattedDuration = store.record.formattedDuration {
                AppLabeledContent("records.detail.duration", value: formattedDuration)
            }

            AppLabeledContent("records.detail.date") {
                Text(store.record.date.relativeDescription.capitalized)
                    .textStyleBody(color: theme.colors.secondaryText)
            }

            if let place = store.record.place {
                AppLabeledContent("records.detail.place", value: place)
            }
        }
    }

    @ViewBuilder
    var descriptionSection: some View {
        if !store.record.description.isEmpty {
            AppSection("records.detail.description", isExpanded: $store.isDescriptionExpanded) {
                Text(store.record.description)
                    .textStyleBodyRegular()
            }
        }
    }

    var metadataSection: some View {
        AppSection("records.detail.metadata", isExpanded: $store.isMetadataExpanded, isSeparated: true) {
            AppLabeledContent("records.detail.created") {
                Text(store.record.createdAt, style: .date)
            }
            AppLabeledContent("records.detail.id", value: store.record.id.uuidString, font: AppTypography.footnote)
        }
    }

    var deleteButton: some View {
        AppButton(title: "records.detail.deleteRecord", icon: .bin, style: .destructive) {
            store.send(.onDeleteTapped)
        }
        .accessibilityHint("records.detail.accessibility.deleteHint")
    }
}

// MARK: - Previews

#Preview("Full Record") {
    NavigationStack {
        SportRecordDetailView(
            store: Store(
                initialState: SportRecordDetailFeature.State(
                    record: SportRecord(
                        id: UUID(),
                        name: "Morning Run",
                        description: "Easy 5K through Central Park. Weather was perfect — cool and sunny.",
                        place: "Central Park",
                        category: .running,
                        duration: 1_845,
                        date: .now,
                        createdAt: .now.addingTimeInterval(-3_600),
                        source: .local
                    )
                )
            ) {
                SportRecordDetailFeature()
            } withDependencies: {
                $0.sportRecordsClient.delete = { _ in }
            }
        )
    }
}
