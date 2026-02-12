import Foundation

// This is a plain Swift protocol -- no TCA dependency.
// The presentation layer defines a parallel @DependencyClient interface;
// the composition root bridges the two for TCA's DI system.

/// Repository contract for managing sport records across local and remote sources.
///
/// Defined in Domain to enforce Dependency Inversion:
/// - Domain owns the interface
/// - DataKit provides the implementation
/// - Features consume via TCA's DI bridge
public protocol SportRecordRepository: Sendable {
    /// Fetches all sport records, merging local and remote sources.
    ///
    /// Returns a `SportRecordFetchResult` that includes the merged records
    /// and indicates whether the remote source was unavailable.
    func fetchAll() async throws -> SportRecordFetchResult

    /// Persists a new sport record to the appropriate data source
    /// based on `record.source`.
    func add(_ record: SportRecord) async throws

    /// Removes a sport record from the appropriate data source
    /// based on `record.source`.
    func delete(_ record: SportRecord) async throws
}
