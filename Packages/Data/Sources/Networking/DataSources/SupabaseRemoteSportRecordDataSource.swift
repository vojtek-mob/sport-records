import Domain
import Foundation

/// Remote data source backed by a Supabase PostgREST API.
///
/// Uses the standard `APIClient` to make requests, adding
/// Supabase-specific conventions (query-param filtering, Prefer header).
///
/// PostgREST differences from a typical REST API:
/// - Uses `PATCH` for updates (not `PUT`)
/// - Filters via query parameters (`?id=eq.<uuid>`) rather than path parameters
/// - Returns arrays even for single-row operations
/// - Requires `Prefer: return=representation` to get response bodies on mutations
public final class SupabaseRemoteSportRecordDataSource: RemoteSportRecordDataSource, Sendable {
    private static let selectAll = "?select=*"
    private static let returnRepresentationHeader = ["Prefer": "return=representation"]

    private let apiClient: APIClient
    private let tablePath: String

    public init(apiClient: APIClient, tablePath: String = "/rest/v1/sport_records") {
        self.apiClient = apiClient
        self.tablePath = tablePath
    }

    public func fetchAll() async throws -> [SportRecord] {
        let dtos: [SportRecordDTO] = try await apiClient.request(
            endpoint: "\(tablePath)\(Self.selectAll)",
            method: .get,
            body: nil
        )
        return dtos.compactMap { $0.toDomain() }
    }

    public func add(_ record: SportRecord) async throws {
        let dto = SportRecordDTO(from: record)
        // PostgREST returns an array with the inserted row(s)
        let _: [SportRecordDTO] = try await apiClient.request(
            endpoint: tablePath,
            method: .post,
            headers: Self.returnRepresentationHeader,
            body: dto
        )
    }

    public func delete(id: UUID) async throws {
        try await apiClient.requestVoid(
            endpoint: "\(tablePath)\(Self.idFilter(id))",
            method: .delete,
            body: nil
        )
    }
}

private extension SupabaseRemoteSportRecordDataSource {
    static func idFilter(_ id: UUID) -> String {
        "?id=eq.\(id.uuidString)"
    }
}
