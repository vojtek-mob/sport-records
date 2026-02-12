@testable import DataKit
import Domain
import Foundation
import XCTest

final class SportRecordModelMappingTests: XCTestCase {
    // MARK: - from(_:)

    func testFromDomainMapsAllFields() {
        let record = SportRecord(
            id: TestUUID.id1,
            name: "Morning Run",
            description: "Easy 5K",
            place: "Central Park",
            category: .running,
            duration: 1800,
            date: Date(timeIntervalSince1970: 1_700_000_000),
            createdAt: Date(timeIntervalSince1970: 1_700_100_000),
            source: .local
        )

        let model = SportRecordModel.from(record)

        XCTAssertEqual(model.id, record.id)
        XCTAssertEqual(model.name, "Morning Run")
        XCTAssertEqual(model.recordDescription, "Easy 5K")
        XCTAssertEqual(model.place, "Central Park")
        XCTAssertEqual(model.categoryRaw, "running")
        XCTAssertEqual(model.duration, 1800)
        XCTAssertEqual(model.date.timeIntervalSince1970, 1_700_000_000, accuracy: 0.001)
        XCTAssertEqual(model.createdAt.timeIntervalSince1970, 1_700_100_000, accuracy: 0.001)
    }

    func testFromDomainHandlesNilPlace() {
        let record = SportRecord(
            id: UUID(),
            name: "Test",
            description: "",
            category: .cycling,
            duration: 0,
            date: Date(),
            createdAt: Date(),
            source: .local
        )

        let model = SportRecordModel.from(record)
        XCTAssertNil(model.place)
    }

    // MARK: - toDomain()

    func testToDomainMapsAllFields() {
        let model = SportRecordModel(
            id: TestUUID.id1,
            name: "Morning Run",
            recordDescription: "Easy 5K",
            place: "Central Park",
            categoryRaw: "running",
            duration: 1800,
            date: Date(timeIntervalSince1970: 1_700_000_000),
            createdAt: Date(timeIntervalSince1970: 1_700_100_000)
        )

        let record = model.toDomain()

        XCTAssertEqual(record.id, model.id)
        XCTAssertEqual(record.name, "Morning Run")
        XCTAssertEqual(record.description, "Easy 5K")
        XCTAssertEqual(record.place, "Central Park")
        XCTAssertEqual(record.category, .running)
        XCTAssertEqual(record.duration, 1800)
        XCTAssertEqual(record.source, .local)
        XCTAssertEqual(record.date.timeIntervalSince1970, 1_700_000_000, accuracy: 0.001)
        XCTAssertEqual(record.createdAt.timeIntervalSince1970, 1_700_100_000, accuracy: 0.001)
    }

    func testToDomainFallsBackToOtherForInvalidCategory() {
        let model = SportRecordModel(
            id: UUID(),
            name: "Test",
            recordDescription: "",
            place: nil,
            categoryRaw: "quidditch",
            duration: 0,
            date: Date(),
            createdAt: Date()
        )

        XCTAssertEqual(model.toDomain().category, .other)
    }

    func testToDomainPreservesNilPlace() {
        let model = SportRecordModel(
            id: UUID(),
            name: "Test",
            recordDescription: "",
            place: nil,
            categoryRaw: "running",
            duration: 0,
            date: Date(),
            createdAt: Date()
        )

        XCTAssertNil(model.toDomain().place)
    }
}
