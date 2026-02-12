import ComposableArchitecture
import Domain
import Foundation

// This is the navigation coordinator for the Sport Records tab.
// It owns the NavigationStack (via StackState) and the presented sheets (via @Presents).
// All navigation decisions flow through here -- child features emit delegate actions,
// and this coordinator responds by pushing/presenting.

@Reducer
public struct SportRecordsCoordinatorFeature: Sendable {
    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.sportRecordsList, action: \.sportRecordsList) {
            SportRecordsListFeature()
        }

        Reduce { state, action in
            switch action {
            case let .sportRecordsList(.delegate(.showDetail(record))):
                onShowDetail(&state, record: record)
            case .sportRecordsList(.delegate(.showAddRecord)):
                onShowAddRecord(&state)
            case let .sportRecordsList(.delegate(.showFilter(filter, sort))):
                onShowFilter(&state, filter: filter, sort: sort)
            case .sportRecordsList:
                .none
            case .filter(.presented(.delegate(.apply))):
                onFilterApply(&state)
            case .filter(.presented(.delegate(.dismiss))):
                onFilterDismiss(&state)
            case .filter(.presented(.delegate(.reset))):
                onFilterReset(&state)
            case .filter(.dismiss):
                .none
            case .filter:
                .none
            case let .addSportRecord(.presented(.delegate(.recordAdded(record)))):
                onRecordAdded(&state, record: record)
            case .addSportRecord:
                .none
            case let .path(.element(id: id, action: .detail(.delegate(.recordDeleted(recordID))))):
                onRecordDeleted(&state, pathID: id, recordID: recordID)
            case .path:
                .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$filter, action: \.filter) {
            SportRecordsFilterFeature()
        }
        .ifLet(\.$addSportRecord, action: \.addSportRecord) {
            AddSportRecordFeature()
        }
    }
}

// MARK: - Reducer Logic

private extension SportRecordsCoordinatorFeature {
    func onShowDetail(_ state: inout State, record: SportRecord) -> Effect<Action> {
        state.path.append(.detail(.init(record: record)))
        return .none
    }

    func onShowAddRecord(_ state: inout State) -> Effect<Action> {
        state.addSportRecord = AddSportRecordFeature.State()
        return .none
    }

    func onShowFilter(_ state: inout State, filter: SportRecordFilter, sort: SportRecordSort) -> Effect<Action> {
        state.filter = SportRecordsFilterFeature.State(filter: filter, sort: sort)
        return .none
    }

    func onFilterApply(_ state: inout State) -> Effect<Action> {
        guard let filterState = state.filter else { return .none }
        state.sportRecordsList.filter = filterState.filter
        state.sportRecordsList.sort = filterState.sort
        state.filter = nil
        return .none
    }

    func onFilterDismiss(_ state: inout State) -> Effect<Action> {
        state.filter = nil
        return .none
    }

    func onFilterReset(_ state: inout State) -> Effect<Action> {
        state.filter = nil
        state.sportRecordsList.filter = .init()
        state.sportRecordsList.sort = .byDate
        return .none
    }

    func onRecordAdded(_ state: inout State, record: SportRecord) -> Effect<Action> {
        state.addSportRecord = nil
        state.sportRecordsList.records.append(record)
        return .none
    }

    func onRecordDeleted(_ state: inout State, pathID: StackElementID, recordID: UUID) -> Effect<Action> {
        state.sportRecordsList.records.remove(id: recordID)
        state.path.pop(from: pathID)
        return .none
    }
}

// MARK: - State

extension SportRecordsCoordinatorFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents public var filter: SportRecordsFilterFeature.State?
        @Presents public var addSportRecord: AddSportRecordFeature.State?

        public var sportRecordsList: SportRecordsListFeature.State
        public var path = StackState<Path.State>()

        public init(
            sportRecordsList: SportRecordsListFeature.State = .init()
        ) {
            self.sportRecordsList = sportRecordsList
        }
    }
}

// MARK: - Action

extension SportRecordsCoordinatorFeature {
    @CasePathable
    public enum Action: Sendable {
        case sportRecordsList(SportRecordsListFeature.Action)
        case path(StackActionOf<Path>)
        case filter(PresentationAction<SportRecordsFilterFeature.Action>)
        case addSportRecord(PresentationAction<AddSportRecordFeature.Action>)
    }
}

// MARK: - Path

extension SportRecordsCoordinatorFeature {
    @Reducer
    public enum Path {
        case detail(SportRecordDetailFeature)
    }
}

// The @Reducer macro on Path does not auto-synthesize Sendable and/or Equatable for the generated
// State and Action enum. StackAction conditionally conforms to Sendable only when both State and Action
// are Sendable, so this explicit conformance is required to satisfy Swift 6 strict concurrency checking.
extension SportRecordsCoordinatorFeature.Path.State: Equatable {}
extension SportRecordsCoordinatorFeature.Path.State: Sendable {}
extension SportRecordsCoordinatorFeature.Path.Action: Sendable {}
