import ComposableArchitecture
import Domain
import Foundation
import SharedFeatures

@Reducer
public struct SportRecordsFilterFeature: Sendable {
    public init() {}

    public var body: some ReducerOf<Self> {
        // Handles incoming binding actions from $store bindings (e.g. TextField, Picker)
        // by automatically applying state mutations before the Reduce block runs.
        BindingReducer()

        Scope(state: \.sourceSection, action: \.sourceSection) {
            SelectSectionFeature()
        }

        Reduce { state, action in
            switch action {
            case .sourceSection(.delegate(.selectionChanged(let ids))):
                onSourceSelectionChanged(&state, ids: ids)
            case .categoryTapped(let category):
                onCategoryTapped(&state, category: category)
            case .binding:
                .none
            case .onApplyTapped:
                .send(.delegate(.apply))
            case .onDismissTapped:
                .send(.delegate(.dismiss))
            case .onResetTapped:
                .send(.delegate(.reset))
            case .sortTapped(let sort):
                onSortTapped(&state, sort: sort)
            case .delegate:
                .none
            case .sourceSection:
                .none
            }
        }
    }
}

// MARK: - Reducer Logic

private extension SportRecordsFilterFeature {
    func onSourceSelectionChanged(_ state: inout State, ids: Set<String>) -> Effect<Action> {
        state.filter.sources = Set(
            ids.compactMap { id in RecordSource.allCases.first { "\($0)" == id } }
        )
        return .none
    }

    func onCategoryTapped(_ state: inout State, category: SportCategory) -> Effect<Action> {
        if state.filter.categories.contains(category) {
            state.filter.categories.remove(category)
        } else {
            state.filter.categories.insert(category)
        }
        return .none
    }

    func onSortTapped(_ state: inout State, sort: SportRecordSort) -> Effect<Action> {
        state.sort = sort
        return .none
    }
}

// MARK: - State

extension SportRecordsFilterFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        public var filter: SportRecordFilter
        public var sort: SportRecordSort
        public var sourceSection: SelectSectionFeature.State

        public init(
            filter: SportRecordFilter = .init(),
            sort: SportRecordSort = .byDate,
            isSourceExpanded: Bool = true
        ) {
            self.filter = filter
            self.sort = sort
            self.sourceSection = SportRecordsFilterFeature.makeSourceSection(
                filter: filter,
                isExpanded: isSourceExpanded
            )
        }
    }
}

// MARK: - Action

extension SportRecordsFilterFeature {
    @CasePathable
    public enum Action: Sendable, BindableAction {
        case binding(BindingAction<State>)
        case sourceSection(SelectSectionFeature.Action)
        case categoryTapped(SportCategory)
        case onApplyTapped
        case onDismissTapped
        case onResetTapped
        case sortTapped(SportRecordSort)
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Sendable {
            case apply
            case dismiss
            case reset
        }
    }
}

// MARK: - Section Builders

extension SportRecordsFilterFeature {
    static func makeSourceSection(
        filter: SportRecordFilter = .init(),
        isExpanded: Bool = true
    ) -> SelectSectionFeature.State {
        let items = RecordSource.allCases.map { source in
            SelectItem(
                id: "\(source)",
                title: source.displayName,
                icon: source.icon,
                isSelected: filter.sources.contains(source)
            )
        }
        return .init(
            items: .init(uniqueElements: items),
            selectionMode: .multi,
            isExpanded: isExpanded
        )
    }
}
