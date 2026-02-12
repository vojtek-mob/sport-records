import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct SportRecordsListFeature: Sendable {
    @Dependency(\.sportRecordsClient) private var client

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                onAppear(&state)
            case let .recordsLoaded(.success(result)):
                onRecordsLoaded(&state, result: result)
            case let .recordsLoaded(.failure(error)):
                onRecordsLoadFailed(&state, error: error)
            case let .onRecordTapped(record):
                onRecordTapped(&state, record: record)
            case .onAddTapped:
                onAddTapped(&state)
            case .onFilterTapped:
                onFilterTapped(&state)
            case let .filterUpdated(filter):
                onFilterUpdated(&state, filter: filter)
            case let .sortUpdated(sort):
                onSortUpdated(&state, sort: sort)
            case .alert:
                .none
            case .delegate:
                .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Reducer Logic

private extension SportRecordsListFeature {
    func onAppear(_ state: inout State) -> Effect<Action> {
        state.isLoading = true
        return .run { send in
            await send(.recordsLoaded(
                Result { try await client.fetchAll() }
            ))
        }
    }

    func onRecordsLoaded(_ state: inout State, result: SportRecordFetchResult) -> Effect<Action> {
        state.isLoading = false
        state.records = IdentifiedArrayOf(uniqueElements: result.records)
        state.isRemoteUnavailable = result.isRemoteUnavailable
        return .none
    }

    func onRecordsLoadFailed(_ state: inout State, error: Error) -> Effect<Action> {
        state.isLoading = false
        state.alert = .error(error.localizedDescription)
        return .none
    }

    func onRecordTapped(_ state: inout State, record: SportRecord) -> Effect<Action> {
        .send(.delegate(.showDetail(record)))
    }

    func onAddTapped(_ state: inout State) -> Effect<Action> {
        .send(.delegate(.showAddRecord))
    }

    func onFilterTapped(_ state: inout State) -> Effect<Action> {
        .send(.delegate(.showFilter(state.filter, state.sort)))
    }

    func onFilterUpdated(_ state: inout State, filter: SportRecordFilter) -> Effect<Action> {
        state.filter = filter
        return .none
    }

    func onSortUpdated(_ state: inout State, sort: SportRecordSort) -> Effect<Action> {
        state.sort = sort
        return .none
    }
}

// MARK: - State

extension SportRecordsListFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents public var alert: AlertState<Action.Alert>?

        public var records: IdentifiedArrayOf<SportRecord> = []
        public var isLoading = false
        public var isRemoteUnavailable = false
        public var filter: SportRecordFilter = .init()
        public var sort: SportRecordSort = .byDate

        public init() {}

        /// Records after applying the current filter and sort.
        public var filteredRecords: IdentifiedArrayOf<SportRecord> {
            var result = Array(records)

            // Apply category filter
            if filter.categories != Set(SportCategory.allCases) {
                result = result.filter { filter.categories.contains($0.category) }
            }

            // Apply source filter
            if filter.sources != Set(RecordSource.allCases) {
                result = result.filter { filter.sources.contains($0.source) }
            }

            // Apply search text filter
            if !filter.searchText.isEmpty {
                let lowered = filter.searchText.lowercased()
                result = result.filter {
                    $0.name.lowercased().contains(lowered)
                    || $0.description.lowercased().contains(lowered)
                }
            }

            // Apply sort
            switch sort {
            case .byDate:
                result.sort { $0.date > $1.date }
            case .byName:
                result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            case .byDuration:
                result.sort { $0.duration > $1.duration }
            }

            return IdentifiedArrayOf(uniqueElements: result)
        }
    }
}

// MARK: - Action

extension SportRecordsListFeature {
    @CasePathable
    public enum Action: Sendable {
        case onAppear
        case recordsLoaded(Result<SportRecordFetchResult, Error>)
        case onRecordTapped(SportRecord)
        case onAddTapped
        case onFilterTapped
        case filterUpdated(SportRecordFilter)
        case sortUpdated(SportRecordSort)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        @CasePathable
        public enum Alert: Sendable, Equatable {}

        @CasePathable
        public enum Delegate: Sendable {
            case showDetail(SportRecord)
            case showAddRecord
            case showFilter(SportRecordFilter, SportRecordSort)
        }
    }
}
