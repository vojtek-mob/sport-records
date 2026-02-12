import ComposableArchitecture
import Domain
@testable import SportRecordsFeature
import XCTest

@MainActor
final class SportRecordsListFeatureTests: XCTestCase {
    // MARK: - Loading

    func testOnAppearLoadsRecords() async {
        let mockRecords = SportRecord.stubRecords
        let store = makeSut(fetchResult: .success(SportRecordFetchResult(records: mockRecords)))

        await store.send(.onAppear) { state in
            state.isLoading = true
        }

        await store.receive(\.recordsLoaded.success) { state in
            state.isLoading = false
            state.records = IdentifiedArrayOf(uniqueElements: mockRecords)
        }
    }

    func testOnAppearSetsRemoteUnavailableWhenRemoteFails() async {
        let localRecords = [SportRecord.stubRecords[0]]
        let store = makeSut(fetchResult: .success(
            SportRecordFetchResult(records: localRecords, isRemoteUnavailable: true)
        ))

        await store.send(.onAppear) { state in
            state.isLoading = true
        }

        await store.receive(\.recordsLoaded.success) { state in
            state.isLoading = false
            state.records = IdentifiedArrayOf(uniqueElements: localRecords)
            state.isRemoteUnavailable = true
        }
    }

    func testOnAppearHandlesError() async {
        let store = makeSut(fetchResult: .failure(TestError.networkFailed))

        await store.send(.onAppear) { state in
            state.isLoading = true
        }

        await store.receive(\.recordsLoaded.failure) { state in
            state.isLoading = false
            state.alert = .error(TestError.networkFailed.localizedDescription)
        }
    }

    // MARK: - Navigation Delegates

    func testOnRecordTappedDelegatesShowDetail() async {
        let record = SportRecord.stubRecords[0]
        let store = makeSut()

        await store.send(.onRecordTapped(record))
        await store.receive(\.delegate.showDetail)
    }

    func testOnAddTappedDelegatesShowAddRecord() async {
        let store = makeSut()

        await store.send(.onAddTapped)
        await store.receive(\.delegate.showAddRecord)
    }

    func testOnFilterTappedDelegatesShowFilter() async {
        let store = makeSut()

        await store.send(.onFilterTapped)
        await store.receive(\.delegate.showFilter)
    }

    // MARK: - Filter & Sort

    func testFilterUpdatedChangesState() async {
        let store = makeSut()
        let filter = SportRecordFilter(categories: [.running])

        await store.send(.filterUpdated(filter)) { state in
            state.filter = filter
        }
    }

    func testSortUpdatedChangesState() async {
        let store = makeSut()

        await store.send(.sortUpdated(.byName)) { state in
            state.sort = .byName
        }
    }

    // MARK: - filteredRecords Computed Property

    func testFilterByCategory() {
        var state = makeStateWithRecords()
        state.filter = SportRecordFilter(categories: [.running])

        let result = state.filteredRecords
        XCTAssertTrue(result.allSatisfy { $0.category == .running })
        XCTAssertEqual(result.count, 1)
    }

    func testFilterBySource() {
        var state = makeStateWithRecords()
        state.filter = SportRecordFilter(sources: [.local])

        let result = state.filteredRecords
        XCTAssertTrue(result.allSatisfy { $0.source == .local })
        XCTAssertEqual(result.count, 2)
    }

    func testFilterBySearchText() {
        var state = makeStateWithRecords()
        state.filter = SportRecordFilter(searchText: "swim")

        let result = state.filteredRecords
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].name, "Evening Swim")
    }

    func testFilterBySearchTextIsCaseInsensitive() {
        var state = makeStateWithRecords()
        state.filter = SportRecordFilter(searchText: "MORNING")

        let result = state.filteredRecords
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].name, "Morning Run")
    }

    func testFilterBySearchTextMatchesDescription() {
        var state = makeStateWithRecords()
        state.filter = SportRecordFilter(searchText: "squats")

        let result = state.filteredRecords
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].name, "Leg Day")
    }

    func testCombinedFilters() {
        var state = makeStateWithRecords()
        state.filter = SportRecordFilter(categories: [.running], searchText: "morning")

        let result = state.filteredRecords
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].name, "Morning Run")
    }

    func testEmptySourcesFilterReturnsNoRecords() {
        var state = makeStateWithRecords()
        state.filter = SportRecordFilter(sources: [])

        let result = state.filteredRecords
        XCTAssertTrue(result.isEmpty)
    }

    func testSortByDateDescending() {
        var state = makeStateWithRecords()
        state.sort = .byDate

        let result = state.filteredRecords
        // Records should be sorted by date descending
        for i in 0..<(result.count - 1) {
            XCTAssertGreaterThanOrEqual(result[i].date, result[i + 1].date)
        }
    }

    func testSortByNameAscending() {
        var state = makeStateWithRecords()
        state.sort = .byName

        let result = state.filteredRecords
        let names = result.map(\.name)
        XCTAssertEqual(names, ["Evening Swim", "Leg Day", "Morning Run", "Pool Session"])
    }

    func testSortByDurationDescending() {
        var state = makeStateWithRecords()
        state.sort = .byDuration

        let result = state.filteredRecords
        for i in 0..<(result.count - 1) {
            XCTAssertGreaterThanOrEqual(result[i].duration, result[i + 1].duration)
        }
    }

    // MARK: - State Builders

    /// Creates a state pre-loaded with diverse records for filter/sort testing.
    private func makeStateWithRecords() -> SportRecordsListFeature.State {
        var state = SportRecordsListFeature.State()
        state.records = IdentifiedArrayOf(uniqueElements: [
            SportRecord(
                id: TestUUID.id1,
                name: "Morning Run",
                description: "Easy 5K run around the park",
                place: "Central Park",
                category: .running,
                duration: 1800,
                date: Date(timeIntervalSince1970: 1_700_000_000),
                createdAt: Date(timeIntervalSince1970: 1_700_000_000),
                source: .local
            ),
            SportRecord(
                id: TestUUID.id2,
                name: "Evening Swim",
                description: "Laps at the pool",
                category: .swimming,
                duration: 2700,
                date: Date(timeIntervalSince1970: 1_700_100_000),
                createdAt: Date(timeIntervalSince1970: 1_700_100_000),
                source: .remote
            ),
            SportRecord(
                id: TestUUID.id3,
                name: "Pool Session",
                description: "50 laps in the Olympic pool",
                place: "Olympic Aquatic Center",
                category: .swimming,
                duration: 2700,
                date: Date(timeIntervalSince1970: 1_700_200_000),
                createdAt: Date(timeIntervalSince1970: 1_700_200_000),
                source: .remote
            ),
            SportRecord(
                id: TestUUID.id4,
                name: "Leg Day",
                description: "Squats, lunges, and deadlifts",
                place: "City Gym",
                category: .gym,
                duration: 3600,
                date: Date(timeIntervalSince1970: 1_700_300_000),
                createdAt: Date(timeIntervalSince1970: 1_700_300_000),
                source: .local
            ),
        ])
        return state
    }

    // MARK: - Helpers

    private func makeSut(
        state: SportRecordsListFeature.State = .init(),
        fetchResult: Result<SportRecordFetchResult, Error> = .success(
            SportRecordFetchResult(records: SportRecord.stubRecords)
        )
    ) -> TestStoreOf<SportRecordsListFeature> {
        TestStore(initialState: state, reducer: SportRecordsListFeature.init) {
            $0.sportRecordsClient.fetchAll = {
                try fetchResult.get()
            }
        }
    }
}

// MARK: - Test Helpers

private enum TestError: Error, LocalizedError {
    case networkFailed

    var errorDescription: String? {
        switch self {
        case .networkFailed: "Network request failed"
        }
    }
}
