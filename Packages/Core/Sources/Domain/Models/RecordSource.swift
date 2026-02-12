import Foundation

/// Indicates whether a sport record originates from local storage or a remote server.
public enum RecordSource: String, Sendable, Codable, Hashable, CaseIterable {
    case local
    case remote
}
