import Domain
import Foundation

extension SportRecord {
    /// Locale-aware duration string, e.g. "1h 23m" or "45m".
    ///
    /// Uses `DateComponentsFormatter` so the output is automatically
    /// localized. Shows hours and minutes only; seconds are not included.
    var formattedDuration: String? {
        Self.durationFormatter.string(from: duration)
    }

    // MARK: - Private

    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = .dropLeading
        return formatter
    }()
}
