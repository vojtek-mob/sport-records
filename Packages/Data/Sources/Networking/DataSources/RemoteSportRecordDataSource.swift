import Domain
import Foundation

/// Contract for fetching sport records from a remote API.
public protocol RemoteSportRecordDataSource: Sendable {
    func fetchAll() async throws -> [SportRecord]
    func add(_ record: SportRecord) async throws
    func delete(id: UUID) async throws
}
