import Domain
@testable import Networking
import XCTest

final class SupabaseRemoteSportRecordDataSourceTests: XCTestCase {
    private let tablePath = "/rest/v1/sport_records"

    // MARK: - fetchAll

    func testFetchAllUsesCorrectEndpointAndMethod() async throws {
        let mock = MockAPIClient(result: [makeSampleDTO()])
        let sut = SupabaseRemoteSportRecordDataSource(apiClient: mock, tablePath: tablePath)

        _ = try await sut.fetchAll()

        let lastEndpoint = await mock.lastEndpoint
        let lastMethod = await mock.lastMethod
        XCTAssertEqual(lastEndpoint, "\(tablePath)?select=*")
        XCTAssertEqual(lastMethod, .get)
    }

    func testFetchAllMapsDTOsToDomain() async throws {
        let dto = makeSampleDTO()
        let mock = MockAPIClient(result: [dto])
        let sut = SupabaseRemoteSportRecordDataSource(apiClient: mock, tablePath: tablePath)

        let records = try await sut.fetchAll()

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].name, "Morning Run")
        XCTAssertEqual(records[0].source, .remote)
    }

    func testFetchAllPropagatesAPIError() async {
        let mock = MockAPIClient(error: TestAPIError.serverDown)
        let sut = SupabaseRemoteSportRecordDataSource(apiClient: mock, tablePath: tablePath)

        do {
            _ = try await sut.fetchAll()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is TestAPIError)
        }
    }

    // MARK: - add

    func testAddUsesCorrectEndpointMethodAndHeaders() async throws {
        let mock = MockAPIClient(result: [makeSampleDTO()])
        let sut = SupabaseRemoteSportRecordDataSource(apiClient: mock, tablePath: tablePath)
        let record = makeDomainRecord()

        try await sut.add(record)

        let lastEndpoint = await mock.lastEndpoint
        let lastMethod = await mock.lastMethod
        let lastHeaders = await mock.lastHeaders
        XCTAssertEqual(lastEndpoint, tablePath)
        XCTAssertEqual(lastMethod, .post)
        XCTAssertEqual(lastHeaders["Prefer"], "return=representation")
    }

    func testAddPropagatesAPIError() async {
        let mock = MockAPIClient(error: TestAPIError.serverDown)
        let sut = SupabaseRemoteSportRecordDataSource(apiClient: mock, tablePath: tablePath)

        do {
            try await sut.add(makeDomainRecord())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is TestAPIError)
        }
    }

    // MARK: - delete

    func testDeleteUsesCorrectEndpointAndMethod() async throws {
        let mock = MockAPIClient()
        let sut = SupabaseRemoteSportRecordDataSource(apiClient: mock, tablePath: tablePath)
        let recordID = TestUUID.id1

        try await sut.delete(id: recordID)

        let lastEndpoint = await mock.lastEndpoint
        let lastMethod = await mock.lastMethod
        XCTAssertEqual(lastEndpoint, "\(tablePath)?id=eq.\(recordID.uuidString)")
        XCTAssertEqual(lastMethod, .delete)
    }

    func testDeletePropagatesAPIError() async throws {
        let mock = MockAPIClient(error: TestAPIError.serverDown)
        let sut = SupabaseRemoteSportRecordDataSource(apiClient: mock, tablePath: tablePath)
        let recordID = TestUUID.id1

        do {
            try await sut.delete(id: recordID)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is TestAPIError)
        }
    }

    // MARK: - Helpers

    private func makeSampleDTO() -> SportRecordDTO {
        SportRecordDTO(
            id: "00000000-0000-0000-0000-000000000001",
            name: "Morning Run",
            description: "Easy 5K",
            place: "Central Park",
            category: "running",
            durationSeconds: 1800,
            date: "2023-11-14T22:13:20.000Z",
            createdAt: "2023-11-14T22:13:20.000Z"
        )
    }

    private func makeDomainRecord() -> SportRecord {
        SportRecord(
            id: TestUUID.id1,
            name: "Morning Run",
            description: "Easy 5K",
            place: "Central Park",
            category: .running,
            duration: 1800,
            date: Date(timeIntervalSince1970: 1_700_000_000),
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            source: .remote
        )
    }
}

// MARK: - Test Doubles

/// Mock API client that captures request parameters and returns configurable results.
private actor MockAPIClient: APIClient {
    var lastEndpoint: String?
    var lastMethod: HTTPMethod?
    var lastHeaders: [String: String] = [:]
    private let result: Any?
    private let error: Error?

    init(result: Any? = nil, error: Error? = nil) {
        self.result = result
        self.error = error
    }

    func request<T: Decodable & Sendable>(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String],
        body: (any Encodable & Sendable)?
    ) async throws -> T {
        lastEndpoint = endpoint
        lastMethod = method
        lastHeaders = headers

        if let error { throw error }
        guard let typed = result as? T else {
            fatalError("MockAPIClient: result type mismatch — expected \(T.self)")
        }
        return typed
    }

    func requestVoid(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String],
        body: (any Encodable & Sendable)?
    ) async throws {
        lastEndpoint = endpoint
        lastMethod = method
        lastHeaders = headers

        if let error { throw error }
    }
}

private enum TestAPIError: Error {
    case serverDown
}
