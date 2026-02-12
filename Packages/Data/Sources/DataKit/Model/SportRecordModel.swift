import Domain
import Foundation
import SwiftData

/// SwiftData persistence model mirroring the domain `SportRecord`.
///
/// Enum properties (`SportCategory`) are stored as raw `String`
/// values so the persistence format stays decoupled from domain types.
@Model
public final class SportRecordModel {
    // Justification: Usage of Self.id leads to `Fatal error: could not demangle keypath`
    // swiftlint:disable:next prefer_self_in_static_references
    #Unique([\SportRecordModel.id])

    public var id: UUID
    public var name: String
    // Named `recordDescription` to avoid collision with `CustomStringConvertible.description`
    public var recordDescription: String
    public var place: String?
    public var categoryRaw: String
    public var duration: TimeInterval
    public var date: Date
    public var createdAt: Date

    public init(
        id: UUID,
        name: String,
        recordDescription: String,
        place: String?,
        categoryRaw: String,
        duration: TimeInterval,
        date: Date,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.recordDescription = recordDescription
        self.place = place
        self.categoryRaw = categoryRaw
        self.duration = duration
        self.date = date
        self.createdAt = createdAt
    }
}

// MARK: - Domain Mapping

extension SportRecordModel {
    /// Creates a new persistence model from a domain value.
    static func from(_ record: SportRecord) -> SportRecordModel {
        SportRecordModel(
            id: record.id,
            name: record.name,
            recordDescription: record.description,
            place: record.place,
            categoryRaw: record.category.rawValue,
            duration: record.duration,
            date: record.date,
            createdAt: record.createdAt
        )
    }

    /// Converts this persistence model to the domain value type.
    func toDomain() -> SportRecord {
        SportRecord(
            id: id,
            name: name,
            description: recordDescription,
            place: place,
            category: SportCategory(rawValue: categoryRaw) ?? .other,
            duration: duration,
            date: date,
            createdAt: createdAt,
            source: .local
        )
    }
}
