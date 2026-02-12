import Domain
import Foundation
import OSLog

/// Data Transfer Object for sport records as received from the API.
///
/// Shape matches the API response. Mapped to/from `SportRecord` domain model
/// at the boundary -- API shape never leaks into Domain.
public struct SportRecordDTO: Codable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let place: String?
    public let category: String
    public let durationSeconds: Double
    public let date: String
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, description, place, category, date
        case durationSeconds = "duration_seconds"
        case createdAt = "created_at"
    }

    public init(
        id: String,
        name: String,
        description: String,
        place: String? = nil,
        category: String,
        durationSeconds: Double,
        date: String,
        createdAt: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.place = place
        self.category = category
        self.durationSeconds = durationSeconds
        self.date = date
        self.createdAt = createdAt
    }
}

// MARK: - Domain Mapping

extension SportRecordDTO {
    /// Maps DTO to domain model.
    ///
    /// Returns `nil` when required fields (`id`, `name`, `date`, `createdAt`) cannot be
    /// parsed into valid domain types — callers should use `compactMap` to discard invalid records.
    /// Falls back to `.other` for unknown categories.
    public func toDomain() -> SportRecord? {
        guard let uuid = UUID(uuidString: id) else {
            logger.warning("Dropped record: invalid UUID '\(self.id, privacy: .public)'")
            return nil
        }
        guard !name.isEmpty else {
            logger.warning("Dropped record \(self.id, privacy: .public): empty name")
            return nil
        }
        guard let parsedDate = ISO8601DateCoder.parse(date) else {
            logger.warning("Dropped record \(self.id, privacy: .public): invalid date '\(self.date, privacy: .public)'")
            return nil
        }
        guard let parsedCreatedAt = ISO8601DateCoder.parse(createdAt) else {
            logger.warning(
                "Dropped record \(self.id, privacy: .public): invalid createdAt '\(self.createdAt, privacy: .public)'"
            )
            return nil
        }

        return SportRecord(
            id: uuid,
            name: name,
            description: description,
            place: place,
            category: SportCategory(rawValue: category) ?? .other,
            duration: durationSeconds,
            date: parsedDate,
            createdAt: parsedCreatedAt,
            source: .remote
        )
    }

    /// Creates a DTO from a domain model (for sending to API).
    public init(from record: SportRecord) {
        self.id = record.id.uuidString
        self.name = record.name
        self.description = record.description
        self.place = record.place
        self.category = record.category.rawValue
        self.durationSeconds = record.duration
        self.date = ISO8601DateCoder.string(from: record.date)
        self.createdAt = ISO8601DateCoder.string(from: record.createdAt)
    }
}

private let logger = Logger(subsystem: "com.sporttracker", category: "Networking.DTO")
