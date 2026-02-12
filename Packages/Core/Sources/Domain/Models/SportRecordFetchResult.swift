import Foundation

/// Result of fetching sport records from all available sources.
///
/// When the remote source fails, `records` contains only local data
/// and `isRemoteUnavailable` is `true`, allowing the UI to inform
/// the user that they may be seeing stale data.
public struct SportRecordFetchResult: Equatable, Sendable {
    public let records: [SportRecord]
    public let isRemoteUnavailable: Bool

    public init(records: [SportRecord], isRemoteUnavailable: Bool = false) {
        self.records = records
        self.isRemoteUnavailable = isRemoteUnavailable
    }
}
