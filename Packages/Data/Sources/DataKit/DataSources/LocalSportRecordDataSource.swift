import Domain
import Foundation

/// Contract for local sport record persistence.
public protocol LocalSportRecordDataSource: Sendable {
    func fetchAll() async throws -> [SportRecord]
    func add(_ record: SportRecord) async throws
    func delete(id: UUID) async throws
}
