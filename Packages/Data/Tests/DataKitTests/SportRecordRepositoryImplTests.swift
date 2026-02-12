@testable import DataKit
import Domain
import Networking
import XCTest

final class SportRecordRepositoryImplTests: XCTestCase {
    // MARK: - Fetch All

    func testFetchAllMergesLocalAndRemote() async throws {
        let localRecord = makeRecord(name: "Local Run", source: .local)
        let remoteRecord = makeRecord(name: "Remote Swim", source: .remote)

        let local = MockLocalDataSource(records: [localRecord])
        let remote = MockRemoteDataSource(records: [remoteRecord])
        let sut = SportRecordRepositoryImpl(local: local, remote: remote)

        let result = try await sut.fetchAll()

        XCTAssertEqual(result.records.count, 2)
        XCTAssertEqual(result.records[0].name, "Local Run")
        XCTAssertEqual(result.records[1].name, "Remote Swim")
        XCTAssertFalse(result.isRemoteUnavailable)
    }

    func testFetchAllReturnsLocalWhenRemoteFailsAndSignalsUnavailable() async throws {
        let localRecord = makeRecord(name: "Local Run", source: .local)

        let local = MockLocalDataSource(records: [localRecord])
        let remote = MockRemoteDataSource(fetchError: TestError.networkFailed)
        let sut = SportRecordRepositoryImpl(local: local, remote: remote)

        let result = try await sut.fetchAll()

        XCTAssertEqual(result.records.count, 1)
        XCTAssertEqual(result.records[0].name, "Local Run")
        XCTAssertTrue(result.isRemoteUnavailable)
    }

    func testFetchAllDeduplicatesByID() async throws {
        let sharedID = UUID()
        let localRecord = makeRecord(id: sharedID, name: "Local Version", source: .local)
        let remoteRecord = makeRecord(id: sharedID, name: "Remote Version", source: .remote)

        let local = MockLocalDataSource(records: [localRecord])
        let remote = MockRemoteDataSource(records: [remoteRecord])
        let sut = SportRecordRepositoryImpl(local: local, remote: remote)

        let result = try await sut.fetchAll()

        XCTAssertEqual(result.records.count, 1)
        XCTAssertEqual(result.records[0].name, "Local Version")
    }

    func testFetchAllPropagatesLocalError() async {
        let local = MockLocalDataSource(fetchError: TestError.localStoreFailed)
        let remote = MockRemoteDataSource(records: [])
        let sut = SportRecordRepositoryImpl(local: local, remote: remote)

        do {
            _ = try await sut.fetchAll()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is TestError)
        }
    }

    // MARK: - Add

    func testAddLocalRecordDelegatesToLocalDataSource() async throws {
        let record = makeRecord(name: "Morning Run", source: .local)
        let local = MockLocalDataSource()
        let remote = MockRemoteDataSource()
        let sut = SportRecordRepositoryImpl(local: local, remote: remote)

        try await sut.add(record)

        let addedLocal = await local.addedRecords
        let addedRemote = await remote.addedRecords
        XCTAssertEqual(addedLocal.count, 1)
        XCTAssertEqual(addedLocal.first?.name, "Morning Run")
        XCTAssertTrue(addedRemote.isEmpty)
    }

    func testAddRemoteRecordDelegatesToRemoteDataSource() async throws {
        let record = makeRecord(name: "Evening Swim", source: .remote)
        let local = MockLocalDataSource()
        let remote = MockRemoteDataSource()
        let sut = SportRecordRepositoryImpl(local: local, remote: remote)

        try await sut.add(record)

        let addedLocal = await local.addedRecords
        let addedRemote = await remote.addedRecords
        XCTAssertTrue(addedLocal.isEmpty)
        XCTAssertEqual(addedRemote.count, 1)
        XCTAssertEqual(addedRemote.first?.name, "Evening Swim")
    }

    // MARK: - Delete

    func testDeleteLocalRecordDelegatesToLocalDataSource() async throws {
        let record = makeRecord(name: "Old Run", source: .local)
        let local = MockLocalDataSource()
        let remote = MockRemoteDataSource()
        let sut = SportRecordRepositoryImpl(local: local, remote: remote)

        try await sut.delete(record)

        let deletedLocal = await local.deletedIDs
        let deletedRemote = await remote.deletedIDs
        XCTAssertEqual(deletedLocal, [record.id])
        XCTAssertTrue(deletedRemote.isEmpty)
    }

    func testDeleteRemoteRecordDelegatesToRemoteDataSource() async throws {
        let record = makeRecord(name: "Old Swim", source: .remote)
        let local = MockLocalDataSource()
        let remote = MockRemoteDataSource()
        let sut = SportRecordRepositoryImpl(local: local, remote: remote)

        try await sut.delete(record)

        let deletedLocal = await local.deletedIDs
        let deletedRemote = await remote.deletedIDs
        XCTAssertTrue(deletedLocal.isEmpty)
        XCTAssertEqual(deletedRemote, [record.id])
    }

    // MARK: - Helpers

    private func makeRecord(
        id: UUID = UUID(),
        name: String = "Test Record",
        source: RecordSource
    ) -> SportRecord {
        SportRecord(
            id: id,
            name: name,
            description: "",
            category: .running,
            duration: 1800,
            date: Date(timeIntervalSince1970: 1_700_000_000),
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            source: source
        )
    }
}

// MARK: - Test Doubles

private actor MockLocalDataSource: LocalSportRecordDataSource {
    var records: [SportRecord]
    var fetchError: Error?
    private(set) var addedRecords: [SportRecord] = []
    private(set) var deletedIDs: [UUID] = []

    init(records: [SportRecord] = [], fetchError: Error? = nil) {
        self.records = records
        self.fetchError = fetchError
    }

    func fetchAll() throws -> [SportRecord] {
        if let error = fetchError { throw error }
        return records
    }

    func add(_ record: SportRecord) throws {
        addedRecords.append(record)
    }

    func delete(id: UUID) throws {
        deletedIDs.append(id)
    }
}

private actor MockRemoteDataSource: RemoteSportRecordDataSource {
    var records: [SportRecord]
    var fetchError: Error?
    private(set) var addedRecords: [SportRecord] = []
    private(set) var deletedIDs: [UUID] = []

    init(records: [SportRecord] = [], fetchError: Error? = nil) {
        self.records = records
        self.fetchError = fetchError
    }

    func fetchAll() throws -> [SportRecord] {
        if let error = fetchError { throw error }
        return records
    }

    func add(_ record: SportRecord) throws {
        addedRecords.append(record)
    }

    func delete(id: UUID) throws {
        deletedIDs.append(id)
    }
}

private enum TestError: Error {
    case networkFailed
    case localStoreFailed
}
