import Foundation

/// Core domain model representing a single sport activity record.
///
/// This is a pure value type with no framework dependencies.
/// All properties are immutable -- updates create new instances.
public struct SportRecord: Identifiable, Equatable, Sendable, Codable {
    public let id: UUID
    public let name: String
    public let description: String
    public let place: String?
    public let category: SportCategory
    public let duration: TimeInterval
    public let date: Date
    public let createdAt: Date
    public let source: RecordSource

    public init(
        id: UUID,
        name: String,
        description: String,
        place: String? = nil,
        category: SportCategory,
        duration: TimeInterval,
        date: Date,
        createdAt: Date,
        source: RecordSource
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.place = place
        self.category = category
        self.duration = duration
        self.date = date
        self.createdAt = createdAt
        self.source = source
    }
}
