import Domain
import Foundation

/// Test-only stub data for `SportRecord`.
extension SportRecord {
    static let stubRecords: [SportRecord] = [
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
    ]
}
