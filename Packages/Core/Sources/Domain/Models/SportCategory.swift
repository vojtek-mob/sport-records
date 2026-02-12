import Foundation

/// Categories of sport activities.
///
/// Defined in Domain as the single source of truth.
/// Data layer represents this as `String` in DTOs and maps to this enum.
public enum SportCategory: String, CaseIterable, Identifiable, Sendable, Codable {
    public var id: String { rawValue }

    case running
    case cycling
    case swimming
    case gym
    case hiking
    case other
}
