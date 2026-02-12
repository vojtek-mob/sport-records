import ComposableArchitecture
import ConcurrencyExtras
import Domain
@testable import SportRecordsFeature
import XCTest

@MainActor
final class AddSportRecordFeatureTests: XCTestCase {
    // MARK: - Validation

    func testSaveWithEmptyNameIncrementsShakeTrigger() async {
        let store = makeSut(name: "")

        await store.send(.onSaveTapped) { state in
            state.nameShakeTrigger = 1
        }
    }

    func testSaveWithWhitespaceOnlyNameIncrementsShakeTrigger() async {
        let store = makeSut(name: "   ")

        await store.send(.onSaveTapped) { state in
            state.nameShakeTrigger = 1
        }
    }

    func testSourceSelectedUpdatesSource() async {
        let store = makeSut()

        await store.send(.sourceSelected(.remote)) { state in
            state.source = .remote
        }

        await store.send(.sourceSelected(.local)) { state in
            state.source = .local
        }
    }

    func testNameEditClearsShakeTrigger() async {
        var state = AddSportRecordFeature.State()
        state.nameShakeTrigger = 2
        let store = makeSut(state: state)

        await store.send(.binding(.set(\.name, "Running"))) { state in
            state.name = "Running"
            state.nameShakeTrigger = 0
        }
    }

    // MARK: - Save Success

    func testSaveSuccessDelegatesRecordAdded() async {
        let testUUID = TestUUID.id99
        let testDate = Date(timeIntervalSince1970: 1_700_000_000)
        let activityDate = Date(timeIntervalSince1970: 1_699_900_000)

        var state = AddSportRecordFeature.State()
        state.name = "Morning Run"
        state.description = "Easy 5K"
        state.place = "Central Park"
        state.category = .running
        state.durationMinutes = 30
        state.date = activityDate
        state.source = .local

        let store = makeSut(state: state, uuid: testUUID, now: testDate)

        await store.send(.onSaveTapped) { state in
            state.isSaving = true
        }

        await store.receive(\.saveResult.success) { state in
            state.isSaving = false
        }

        await store.receive(\.delegate.recordAdded)
    }

    func testRecordConstructionTrimsFieldsAndConvertsCorrectly() async throws {
        let testUUID = TestUUID.id99
        let testDate = Date(timeIntervalSince1970: 1_700_000_000)
        let activityDate = Date(timeIntervalSince1970: 1_699_900_000)

        var state = AddSportRecordFeature.State()
        state.name = "  Morning Run  "
        state.description = "  Easy 5K  "
        state.place = "   "
        state.category = .cycling
        state.durationMinutes = 45
        state.date = activityDate
        state.source = .local

        let addedRecord = LockIsolated<SportRecord?>(nil)
        let store = TestStore(
            initialState: state,
            reducer: AddSportRecordFeature.init
        ) {
            $0.sportRecordsClient.add = { record in
                addedRecord.withValue { $0 = record }
            }
            $0.uuid = .constant(testUUID)
            $0.date = .constant(testDate)
        }

        await store.send(.onSaveTapped) { state in
            state.isSaving = true
        }

        await store.receive(\.saveResult.success) { state in
            state.isSaving = false
        }

        await store.receive(\.delegate.recordAdded)

        // Verify record was constructed correctly
        let record = try XCTUnwrap(addedRecord.value)
        XCTAssertEqual(record.id, testUUID)
        XCTAssertEqual(record.name, "Morning Run", "Name should be trimmed")
        XCTAssertEqual(record.description, "Easy 5K", "Description should be trimmed")
        XCTAssertNil(record.place, "Whitespace-only place should become nil")
        XCTAssertEqual(record.category, .cycling)
        XCTAssertEqual(record.duration, 2700, "45 minutes * 60 = 2700 seconds")
        XCTAssertEqual(record.date, activityDate)
        XCTAssertEqual(record.createdAt, testDate)
        XCTAssertEqual(record.source, .local)
    }

    // MARK: - Save Failure

    func testSaveFailureShowsAlert() async {
        var state = AddSportRecordFeature.State()
        state.name = "Run"

        let store = TestStore(
            initialState: state,
            reducer: AddSportRecordFeature.init
        ) {
            $0.sportRecordsClient.add = { _ in throw TestError.saveFailed }
            $0.uuid = .constant(UUID())
            $0.date = .constant(Date(timeIntervalSince1970: 0))
        }

        await store.send(.onSaveTapped) { state in
            state.isSaving = true
        }

        await store.receive(\.saveResult.failure) { state in
            state.isSaving = false
            state.alert = .error(TestError.saveFailed.localizedDescription)
        }
    }

    // MARK: - Helpers

    private func makeSut(
        name: String = "Run",
        uuid: UUID = TestUUID.id99,
        now: Date = Date(timeIntervalSince1970: 1_700_000_000)
    ) -> TestStoreOf<AddSportRecordFeature> {
        var state = AddSportRecordFeature.State()
        state.name = name
        return makeSut(state: state, uuid: uuid, now: now)
    }

    private func makeSut(
        state: AddSportRecordFeature.State,
        uuid: UUID = TestUUID.id99,
        now: Date = Date(timeIntervalSince1970: 1_700_000_000)
    ) -> TestStoreOf<AddSportRecordFeature> {
        TestStore(initialState: state, reducer: AddSportRecordFeature.init) {
            $0.sportRecordsClient.add = { _ in }
            $0.uuid = .constant(uuid)
            $0.date = .constant(now)
        }
    }
}

// MARK: - Test Helpers

private enum TestError: Error, LocalizedError {
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed: "Failed to save record"
        }
    }
}
