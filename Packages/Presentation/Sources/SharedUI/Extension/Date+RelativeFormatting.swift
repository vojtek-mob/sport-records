import Foundation

extension Date {
    /// Locale-aware relative date description.
    ///
    /// - Same day → "today" / "dnes"
    /// - Yesterday → "yesterday" / "včera"
    /// - 2–6 days ago → abbreviated relative (e.g. "3 days ago" / "před 3 dny")
    /// - 7+ days ago → short date (e.g. "Jan 15" / "15. led")
    public var relativeDescription: String {
        let calendar = Calendar.current
        let now = Date()
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: self),
            to: calendar.startOfDay(for: now)
        ).day ?? 0

        guard days >= 0, days < 7 else {
            return formatted(.dateTime.month(.abbreviated).day())
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(from: DateComponents(day: -days))
    }
}
