import Domain
@testable import Networking
import XCTest

final class SportRecordDTOTests: XCTestCase {
    // MARK: - toDomain — valid input

    func testToDomainMapsAllFieldsCorrectly() throws {
        let dto = SportRecordDTO(
            id: "00000000-0000-0000-0000-000000000001",
            name: "Morning Run",
            description: "Easy 5K",
            place: "Central Park",
            category: "running",
            durationSeconds: 1800,
            date: "2023-11-14T22:13:20.000Z",
            createdAt: "2023-11-14T22:13:20.000Z"
        )

        let record = try XCTUnwrap(dto.toDomain())

        XCTAssertEqual(record.id, TestUUID.id1)
        XCTAssertEqual(record.name, "Morning Run")
        XCTAssertEqual(record.description, "Easy 5K")
        XCTAssertEqual(record.place, "Central Park")
        XCTAssertEqual(record.category, .running)
        XCTAssertEqual(record.duration, 1800)
        XCTAssertEqual(record.source, .remote)
        XCTAssertEqual(record.date.timeIntervalSince1970, 1_700_000_000, accuracy: 1.0)
        XCTAssertEqual(record.createdAt.timeIntervalSince1970, 1_700_000_000, accuracy: 1.0)
    }

    func testToDomainWithUnknownCategoryFallsBackToOther() throws {
        let dto = SportRecordDTO(
            id: "00000000-0000-0000-0000-000000000001",
            name: "Unknown Sport",
            description: "",
            category: "quidditch",
            durationSeconds: 3600,
            date: "2023-11-14T22:13:20.000Z",
            createdAt: "2023-11-14T22:13:20.000Z"
        )

        let record = try XCTUnwrap(dto.toDomain())
        XCTAssertEqual(record.category, .other)
    }

    func testToDomainParsesDateWithoutFractionalSeconds() throws {
        let dto = SportRecordDTO(
            id: "00000000-0000-0000-0000-000000000001",
            name: "Test",
            description: "",
            category: "running",
            durationSeconds: 0,
            date: "2023-11-14T22:13:20+00:00",
            createdAt: "2023-11-14T22:13:20+00:00"
        )

        let record = try XCTUnwrap(dto.toDomain())
        XCTAssertEqual(record.date.timeIntervalSince1970, 1_700_000_000, accuracy: 1.0)
    }

    func testToDomainNilPlacePreserved() throws {
        let dto = SportRecordDTO(
            id: "00000000-0000-0000-0000-000000000001",
            name: "Test",
            description: "",
            place: nil,
            category: "running",
            durationSeconds: 0,
            date: "2023-11-14T22:13:20.000Z",
            createdAt: "2023-11-14T22:13:20.000Z"
        )

        let record = try XCTUnwrap(dto.toDomain())
        XCTAssertNil(record.place)
    }

    // MARK: - toDomain — invalid input returns nil

    func testToDomainWithInvalidUUIDReturnsNil() {
        let dto = SportRecordDTO(
            id: "not-a-uuid",
            name: "Test",
            description: "",
            category: "running",
            durationSeconds: 0,
            date: "2023-11-14T22:13:20.000Z",
            createdAt: "2023-11-14T22:13:20.000Z"
        )

        XCTAssertNil(dto.toDomain())
    }

    func testToDomainWithEmptyNameReturnsNil() {
        let dto = SportRecordDTO(
            id: "00000000-0000-0000-0000-000000000001",
            name: "",
            description: "",
            category: "running",
            durationSeconds: 0,
            date: "2023-11-14T22:13:20.000Z",
            createdAt: "2023-11-14T22:13:20.000Z"
        )

        XCTAssertNil(dto.toDomain())
    }

    func testToDomainWithInvalidDateReturnsNil() {
        let dto = SportRecordDTO(
            id: "00000000-0000-0000-0000-000000000001",
            name: "Test",
            description: "",
            category: "running",
            durationSeconds: 0,
            date: "not-a-date",
            createdAt: "2023-11-14T22:13:20.000Z"
        )

        XCTAssertNil(dto.toDomain())
    }

    func testToDomainWithInvalidCreatedAtReturnsNil() {
        let dto = SportRecordDTO(
            id: "00000000-0000-0000-0000-000000000001",
            name: "Test",
            description: "",
            category: "running",
            durationSeconds: 0,
            date: "2023-11-14T22:13:20.000Z",
            createdAt: "not-a-date"
        )

        XCTAssertNil(dto.toDomain())
    }

    // MARK: - Round-trip

    func testDomainToDTOToDomainRoundTrip() throws {
        let original = SportRecord(
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

        let dto = SportRecordDTO(from: original)
        let roundTripped = try XCTUnwrap(dto.toDomain())

        XCTAssertEqual(roundTripped.id, original.id)
        XCTAssertEqual(roundTripped.name, original.name)
        XCTAssertEqual(roundTripped.description, original.description)
        XCTAssertEqual(roundTripped.place, original.place)
        XCTAssertEqual(roundTripped.category, original.category)
        XCTAssertEqual(roundTripped.duration, original.duration, accuracy: 0.001)
        XCTAssertEqual(roundTripped.source, .remote)
        XCTAssertEqual(
            roundTripped.date.timeIntervalSince1970,
            original.date.timeIntervalSince1970,
            accuracy: 1.0
        )
    }

    // MARK: - Codable

    func testJSONDecodeAndEncode() throws {
        let json = Data("""
        {
            "id": "00000000-0000-0000-0000-000000000001",
            "name": "Morning Run",
            "description": "Easy 5K",
            "place": "Central Park",
            "category": "running",
            "duration_seconds": 1800.0,
            "date": "2023-11-14T22:13:20.000Z",
            "created_at": "2023-11-14T22:13:20.000Z"
        }
        """.utf8)

        let decoder = JSONDecoder()
        let dto = try decoder.decode(SportRecordDTO.self, from: json)

        XCTAssertEqual(dto.id, "00000000-0000-0000-0000-000000000001")
        XCTAssertEqual(dto.name, "Morning Run")
        XCTAssertEqual(dto.place, "Central Park")
        XCTAssertEqual(dto.category, "running")
        XCTAssertEqual(dto.durationSeconds, 1800.0)

        // Re-encode and verify roundtrip
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(dto)
        let decoded = try decoder.decode(SportRecordDTO.self, from: encoded)
        XCTAssertEqual(decoded.id, dto.id)
        XCTAssertEqual(decoded.name, dto.name)
    }
}
