import ComposableArchitecture
import Domain
import SharedUI
import SwiftUI

/// Form for creating a new sport record.
///
/// Presented as a sheet from the records list screen.
/// Uses `AddSportRecordFeature` as its TCA store.
public struct AddSportRecordView: View {
    private static let minDurationMinutes = 5
    private static let maxDurationMinutes = 1_440 // 24 hours
    private static let durationStepMinutes = 5
    private static let descriptionLineLimit = 3...6

    @Environment(\.appTheme) private var theme

    @Bindable var store: StoreOf<AddSportRecordFeature>

    public init(store: StoreOf<AddSportRecordFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGapLarge) {
                    activityDetailsSection
                    descriptionSection
                }
                .screenPadding()
            }
            .navigationTitle("records.add.title")
            .navigationBarTitleDisplayMode(.inline)
            .background(theme.colors.background)
            .toolbar { saveToolbarItem }
            .disabled(store.isSaving)
            .loadingOverlay(isPresented: store.isSaving)
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

// MARK: - Subviews

private extension AddSportRecordView {
    var activityDetailsSection: some View {
        AppSection("records.add.activityDetails", isSeparated: true) {
            nameTextField
            categoryPicker
            durationStepper
            datePicker
            placeTextField
            sourcePicker
        }
    }

    var descriptionSection: some View {
        AppSection("records.add.description") {
            TextField(
                "records.add.descriptionPlaceholder",
                text: $store.description,
                axis: .vertical
            )
            .lineLimit(Self.descriptionLineLimit)
            .textStyleBody()
        }
    }

    var saveToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("records.add.save") {
                store.send(.onSaveTapped)
            }
            .textStyleCallout(color: theme.colors.onAppTint)
            .buttonShadow()
            .disabled(store.isSaving)
            .buttonStyle(.borderedProminent)
            .accessibilityHint("records.add.accessibility.saveHint")
        }
    }
}

// MARK: - ActivitySection Subviews

private extension AddSportRecordView {
    var nameTextField: some View {
        TextField("records.add.name", text: $store.name)
            .textStyleBody()
            .padding(.vertical, AppSpacing.extraSmall)
            .shake(trigger: store.nameShakeTrigger)
    }

    var categoryPicker: some View {
        HStack(spacing: AppSpacing.medium) {
            Text("records.add.category")
                .textStyleBody()

            Spacer()

            Picker("records.add.category", selection: $store.category) {
                ForEach(SportCategory.allCases, id: \.self) { category in
                    Text(category.displayName)
                        .textStyleBody()
                        .tag(category)
                }
            }
            .textStyleBody()
        }
    }

    var durationStepper: some View {
        Stepper(
            "records.add.duration \(store.durationMinutes)",
            value: $store.durationMinutes,
            in: Self.minDurationMinutes...Self.maxDurationMinutes,
            step: Self.durationStepMinutes
        )
        .textStyleBody()
    }

    var datePicker: some View {
        DatePicker("records.add.date", selection: $store.date, in: ...Date.now, displayedComponents: .date)
            .textStyleBody()
    }

    var placeTextField: some View {
        TextField("records.add.place", text: $store.place)
            .padding(.vertical, AppSpacing.extraSmall)
            .textStyleBody()
    }

    var sourcePicker: some View {
        HStack {
            Text("records.add.source")
                .textStyleBody()

            Spacer()

            HStack(spacing: AppSpacing.small) {
                ForEach(RecordSource.allCases, id: \.self) { source in
                    AppChip(
                        label: source.displayName,
                        isSelected: store.source == source,
                        icon: source.icon
                    ) {
                        store.send(.sourceSelected(source))
                    }
                    .badgeTint(source.badgeTint(theme: theme))
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Form") {
    AddSportRecordView(
        store: Store(
            initialState: AddSportRecordFeature.State()
        ) {
            AddSportRecordFeature()
        } withDependencies: {
            $0.sportRecordsClient.add = { _ in }
        }
    )
}
