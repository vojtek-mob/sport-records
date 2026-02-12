import SwiftData

/// Reusable wrapper around `ModelContainer` that standardises
/// container creation across the app.
///
/// - Pass any `Schema` to share the same stack pattern for different
///   feature modules.
/// - Set `inMemory: true` for unit tests and SwiftUI previews.
public final class SwiftDataStack: Sendable {
    public let container: ModelContainer

    public init(
        for schema: Schema,
        inMemory: Bool = false
    ) throws {
        let config = ModelConfiguration(
            isStoredInMemoryOnly: inMemory
        )
        self.container = try ModelContainer(
            for: schema,
            configurations: [config]
        )
    }
}
