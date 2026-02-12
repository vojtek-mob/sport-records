import ComposableArchitecture
import Domain
import Foundation

// This is the TCA bridge layer. @DependencyClient defines a parallel interface
// to the SportRecordRepository protocol from Domain. Features depend on this
// client, never on DataKit or Networking directly.
//
// The `liveValue` (DependencyKey conformance) lives in the App target
// (SportRecordsClientLive.swift) -- the composition root that wires up
// concrete implementations from DataKit, Networking, and Persistence.

/// TCA dependency client for sport record CRUD operations.
///
/// Mirrors the `SportRecordRepository` protocol surface (fetchAll, add, delete).
/// `@DependencyClient` generates default (unimplemented) closures used by `testValue`.
@DependencyClient
public struct SportRecordsClient: Sendable {
    public var fetchAll: @Sendable () async throws -> SportRecordFetchResult
    public var add: @Sendable (SportRecord) async throws -> Void
    public var delete: @Sendable (SportRecord) async throws -> Void
}

// MARK: - DependencyKey

// DependencyKey conformance (liveValue) is provided by the App target.

extension DependencyValues {
    public var sportRecordsClient: SportRecordsClient {
        get { self[SportRecordsClient.self] }
        set { self[SportRecordsClient.self] = newValue }
    }
}

// MARK: - TestDependencyKey

// TestDependencyKey must live here so the Feature module can register the
// client in DependencyValues and tests get the auto-generated stubs.

extension SportRecordsClient: TestDependencyKey {
    public static let testValue = SportRecordsClient()
}
