import ComposableArchitecture
import Domain
@testable import SportRecordsFeature
import XCTest

// Coordinator tests use `exhaustivity = .off` intentionally.
//
// Navigation coordinators manage StackState and PresentationAction, which produce
// internal TCA system actions (.dismiss confirmations, presentation lifecycle events)
// that are not relevant to the coordinator's business logic. Exhaustively matching
// these actions couples tests to TCA internals and makes them brittle across TCA
// version upgrades. The trade-off is accepted: we test the coordinator's response
// to delegate actions (state mutations and navigation decisions), not the plumbing.

@MainActor
final class SportRecordsCoordinatorFeatureTests: XCTestCase {
    // MARK: - Navigation: Show Detail

    func testShowDetailPushesToPath() async {
        let record = SportRecord.stubRecords[0]
        let store = makeSut()
        store.exhaustivity = .off

        await store.send(.sportRecordsList(.delegate(.showDetail(record)))) { state in
            state.path[id: 0] = .detail(.init(record: record))
        }
    }

    // MARK: - Navigation: Add Record

    func testShowAddRecordPresentsSheet() async {
        let store = makeSut()
        store.exhaustivity = .off

        await store.send(.sportRecordsList(.delegate(.showAddRecord)))
        XCTAssertNotNil(store.state.addSportRecord)
        XCTAssertEqual(store.state.addSportRecord?.name, "")
        XCTAssertEqual(store.state.addSportRecord?.category, .running)
        XCTAssertEqual(store.state.addSportRecord?.durationMinutes, 30)
        XCTAssertEqual(store.state.addSportRecord?.source, .local)
    }

    // MARK: - Navigation: Filter

    func testShowFilterPresentsSheetWithCurrentFilterAndSort() async {
        let filter = SportRecordFilter(categories: [.running], searchText: "morning")
        let sort = SportRecordSort.byName
        let store = makeSut()
        store.exhaustivity = .off

        await store.send(.sportRecordsList(.delegate(.showFilter(filter, sort)))) { state in
            state.filter = SportRecordsFilterFeature.State(filter: filter, sort: sort)
        }
    }

    func testFilterDismissDoesNotSyncToList() async {
        let filter = SportRecordFilter(categories: [.cycling])
        let sort = SportRecordSort.byDuration
        var initialState = SportRecordsCoordinatorFeature.State()
        initialState.filter = SportRecordsFilterFeature.State(filter: filter, sort: sort)
        initialState.sportRecordsList.filter = .init()
        initialState.sportRecordsList.sort = .byDate

        let store = makeSut(state: initialState)
        store.exhaustivity = .off

        await store.send(.filter(.dismiss)) { state in
            state.filter = nil
        }
        XCTAssertEqual(store.state.sportRecordsList.filter, .init())
        XCTAssertEqual(store.state.sportRecordsList.sort, .byDate)
    }

    func testFilterApplySyncsFilterAndSortAndDismisses() async {
        let filter = SportRecordFilter(categories: [.cycling])
        let sort = SportRecordSort.byDuration
        var initialState = SportRecordsCoordinatorFeature.State()
        initialState.filter = SportRecordsFilterFeature.State(filter: filter, sort: sort)
        initialState.sportRecordsList.filter = .init()
        initialState.sportRecordsList.sort = .byDate

        let store = makeSut(state: initialState)
        store.exhaustivity = .off

        await store.send(.filter(.presented(.delegate(.apply)))) { state in
            state.sportRecordsList.filter = filter
            state.sportRecordsList.sort = sort
            state.filter = nil
        }
    }

    func testFilterDelegateDismissOnlyDismisses() async {
        let filter = SportRecordFilter(categories: [.cycling])
        let sort = SportRecordSort.byDuration
        var initialState = SportRecordsCoordinatorFeature.State()
        initialState.filter = SportRecordsFilterFeature.State(filter: filter, sort: sort)
        initialState.sportRecordsList.filter = .init()
        initialState.sportRecordsList.sort = .byDate

        let store = makeSut(state: initialState)
        store.exhaustivity = .off

        await store.send(.filter(.presented(.delegate(.dismiss)))) { state in
            state.filter = nil
        }
        XCTAssertEqual(store.state.sportRecordsList.filter, .init())
        XCTAssertEqual(store.state.sportRecordsList.sort, .byDate)
    }

    func testFilterResetClearsFilterAndSort() async {
        var initialState = SportRecordsCoordinatorFeature.State()
        initialState.filter = SportRecordsFilterFeature.State(
            filter: .init(categories: [.cycling], searchText: "bike"),
            sort: .byName
        )

        let store = makeSut(state: initialState)
        store.exhaustivity = .off

        await store.send(.filter(.presented(.delegate(.reset)))) { state in
            state.filter = nil
            state.sportRecordsList.filter = SportRecordFilter()
            state.sportRecordsList.sort = .byDate
        }
    }

    // MARK: - Optimistic Updates

    func testRecordAddedInsertsIntoListAndClosesSheet() async {
        let newRecord = SportRecord(
            id: TestUUID.id99,
            name: "New Record",
            description: "",
            category: .gym,
            duration: 3600,
            date: Date(timeIntervalSince1970: 1_700_000_000),
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            source: .local
        )

        var initialState = SportRecordsCoordinatorFeature.State()
        initialState.addSportRecord = AddSportRecordFeature.State()

        let store = makeSut(state: initialState)
        store.exhaustivity = .off

        await store.send(.addSportRecord(.presented(.delegate(.recordAdded(newRecord))))) { state in
            state.addSportRecord = nil
            state.sportRecordsList.records.append(newRecord)
        }
    }

    func testRecordDeletedRemovesFromListAndPopsPath() async {
        let record = SportRecord.stubRecords[0]
        var listState = SportRecordsListFeature.State()
        listState.records = IdentifiedArrayOf(uniqueElements: SportRecord.stubRecords)

        var initialState = SportRecordsCoordinatorFeature.State(sportRecordsList: listState)
        initialState.path.append(.detail(.init(record: record)))

        let store = makeSut(state: initialState)
        store.exhaustivity = .off

        await store.send(
            .path(.element(id: 0, action: .detail(.delegate(.recordDeleted(record.id)))))
        ) { state in
            state.sportRecordsList.records.remove(id: record.id)
            state.path = StackState<SportRecordsCoordinatorFeature.Path.State>()
        }
    }

    // MARK: - Helpers

    private func makeSut(
        state: SportRecordsCoordinatorFeature.State = .init()
    ) -> TestStoreOf<SportRecordsCoordinatorFeature> {
        TestStore(
            initialState: state,
            reducer: SportRecordsCoordinatorFeature.init
        ) {
            $0.sportRecordsClient.fetchAll = { SportRecordFetchResult(records: []) }
            $0.sportRecordsClient.add = { _ in }
            $0.sportRecordsClient.delete = { _ in }
        }
    }
}
