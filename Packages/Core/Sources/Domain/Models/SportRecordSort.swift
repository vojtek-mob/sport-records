import Foundation

/// Sort options for sport records lists.
public enum SportRecordSort: String, CaseIterable, Identifiable, Sendable {
    public var id: String { rawValue }

    case byDate
    case byName
    case byDuration
}
