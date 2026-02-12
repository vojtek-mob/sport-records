import Foundation

/// Shared ISO 8601 date parsing and formatting.
///
/// Handles both formats commonly returned by backends:
/// - With fractional seconds: `2024-01-15T10:30:00.000Z`
/// - Without fractional seconds: `2024-01-15T10:30:00+00:00`
///
/// PostgreSQL TIMESTAMPTZ via PostgREST may return either format.
public enum ISO8601DateCoder {
    // nonisolated(unsafe): Formatters are initialized once via static let (thread-safe)
    // and never mutated after creation. ISO8601DateFormatter lacks Sendable but is safe here.
    nonisolated(unsafe) private static let withFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    nonisolated(unsafe) private static let base: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    /// Parses an ISO 8601 date string, trying fractional seconds first then without.
    public static func parse(_ string: String) -> Date? {
        withFractionalSeconds.date(from: string) ?? base.date(from: string)
    }

    /// Formats a `Date` as an ISO 8601 string with fractional seconds.
    public static func string(from date: Date) -> String {
        withFractionalSeconds.string(from: date)
    }
}
