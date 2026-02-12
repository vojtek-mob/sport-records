import Domain
import Foundation
import SwiftData

/// SwiftData-backed implementation of `LocalSportRecordDataSource`.
///
/// Uses `@ModelActor` to get a dedicated actor with its own `ModelContext`,
/// which is the SwiftData-recommended pattern for background persistence work.
/// The actor naturally satisfies the `Sendable` requirement of the protocol.
/// Actor isolation allows non-async methods to satisfy the protocol's
/// `async throws` requirements without an explicit `async` keyword.
@ModelActor
public actor SwiftDataLocalDataSource: LocalSportRecordDataSource {
    public func fetchAll() throws -> [SportRecord] {
        let descriptor = FetchDescriptor<SportRecordModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    public func add(_ record: SportRecord) throws {
        modelContext.insert(SportRecordModel.from(record))
        try modelContext.save()
    }

    public func delete(id: UUID) throws {
        let predicate = #Predicate<SportRecordModel> { $0.id == id }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        if let existing = try modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            try modelContext.save()
        }
    }
}
