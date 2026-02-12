import ComposableArchitecture

/// Reusable TCA feature for a collapsible section containing selectable items.
///
/// Supports both single-select and multi-select modes. Emits a delegate
/// action whenever the selection changes so the parent can react.
///
/// Usage (parent reducer):
/// ```swift
/// Scope(state: \.sourceSection, action: \.sourceSection) {
///     SelectSectionFeature()
/// }
/// ```
@Reducer
public struct SelectSectionFeature: Sendable {
    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case let .itemTapped(id):
                onItemTapped(&state, id: id)
            case .binding:
                .none
            case .delegate:
                .none
            }
        }
    }
}

// MARK: - Reducer Logic

private extension SelectSectionFeature {
    func onItemTapped(_ state: inout State, id: SelectItem.ID) -> Effect<Action> {
        switch state.selectionMode {
        case .single:
            for index in state.items.indices {
                state.items[index].isSelected = (state.items[index].id == id)
            }
        case .multi:
            guard let index = state.items.index(id: id) else { return .none }
            state.items[index].isSelected.toggle()
        }

        let selectedIDs = Set(state.items.filter(\.isSelected).map(\.id))
        return .send(.delegate(.selectionChanged(selectedIDs)))
    }
}

// MARK: - State

extension SelectSectionFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        public var items: IdentifiedArrayOf<SelectItem>
        public var selectionMode: SelectionMode
        public var isExpanded: Bool

        public init(
            items: IdentifiedArrayOf<SelectItem>,
            selectionMode: SelectionMode = .single,
            isExpanded: Bool = true
        ) {
            self.items = items
            self.selectionMode = selectionMode
            self.isExpanded = isExpanded
        }
    }

    public enum SelectionMode: Equatable, Sendable {
        case single
        case multi
    }
}

// MARK: - Action

extension SelectSectionFeature {
    @CasePathable
    public enum Action: Sendable, BindableAction {
        /// Carries state mutations from SwiftUI bindings (e.g. `$store.isExpanded`).
        case binding(BindingAction<State>)
        case itemTapped(SelectItem.ID)
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Sendable {
            /// Emitted after every selection change with the full set of selected IDs.
            case selectionChanged(Set<SelectItem.ID>)
        }
    }
}
