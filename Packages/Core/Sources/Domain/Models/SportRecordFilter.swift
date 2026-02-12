import Foundation

/// Filter criteria for querying sport records.
///
/// Fields support "no filter" semantics: `category` uses `nil`,
/// `searchText` uses an empty string, and `sources` defaults to all cases.
public struct SportRecordFilter: Equatable, Sendable {
    public var categories: Set<SportCategory>
    public var searchText: String
    public var sources: Set<RecordSource>

    public init(
        categories: Set<SportCategory> = Set(SportCategory.allCases),
        searchText: String = "",
        sources: Set<RecordSource> = Set(RecordSource.allCases)
    ) {
        self.categories = categories
        self.searchText = searchText
        self.sources = sources
    }

    /// Returns `true` when no filters are active.
    public var isEmpty: Bool {
        categories == Set(SportCategory.allCases)
        && searchText.isEmpty
        && sources == Set(RecordSource.allCases)
    }
}
