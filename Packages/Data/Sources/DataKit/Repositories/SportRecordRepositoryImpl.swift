import Domain
import Foundation
import Networking

/// Concrete repository coordinating local and remote data sources.
///
/// Implements `SportRecordRepository` (defined in Domain).
/// Responsible for fetching and merging records from both sources.
/// Write operations (add, delete) are routed to the correct
/// data source based on `record.source`.
public final class SportRecordRepositoryImpl: SportRecordRepository, Sendable {
    private let local: LocalSportRecordDataSource
    private let remote: RemoteSportRecordDataSource

    public init(
        local: LocalSportRecordDataSource,
        remote: RemoteSportRecordDataSource
    ) {
        self.local = local
        self.remote = remote
    }

    public func fetchAll() async throws -> SportRecordFetchResult {
        async let localTask = local.fetchAll()
        async let remoteTask = remote.fetchAll()

        let cached = try await localTask

        do {
            let records = try await remoteTask
            let localIDs = Set(cached.map(\.id))
            let uniqueRemote = records.filter { !localIDs.contains($0.id) }
            return SportRecordFetchResult(records: cached + uniqueRemote)
        } catch {
            return SportRecordFetchResult(records: cached, isRemoteUnavailable: true)
        }
    }

    public func add(_ record: SportRecord) async throws {
        switch record.source {
        case .local: try await local.add(record)
        case .remote: try await remote.add(record)
        }
    }

    public func delete(_ record: SportRecord) async throws {
        switch record.source {
        case .local: try await local.delete(id: record.id)
        case .remote: try await remote.delete(id: record.id)
        }
    }
}
