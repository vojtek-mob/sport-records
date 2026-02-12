import ComposableArchitecture
import DataKit
import Domain
import Foundation
import Networking
import SportRecordsFeature
import SwiftData

// This file wires up the live SportRecordsClient using concrete
// implementations from DataKit and Networking.
// Keeping this in the App target ensures Feature modules stay
// free of infrastructure dependencies.

extension SportRecordsClient: @retroactive DependencyKey {
    // The API key below is a Supabase publishable (anon) key. It is designed
    // to be embedded in client apps and only grants row-level-security scoped
    // access. Keeping it inline is intentional so that other developers can
    // clone the repo and run the PoC without extra build configuration.
    // For a production app, move credentials to a gitignored .xcconfig file.
    private static let supabaseConfig = SupabaseConfig(
        // swiftlint:disable:next force_unwrapping
        projectURL: URL(string: "https://xqvxgqildpqizfbrivsc.supabase.co")!,
        apiKey: "sb_publishable_mqgIrvoMDrvL87RaYQXNZQ_3dutpfmX"
    )

    /// Result of initializing infrastructure dependencies.
    /// Stores either the live repository or the initialization error,
    /// so the app never crashes on startup if SwiftData fails to load.
    private enum Infrastructure {
        case ready(repository: SportRecordRepository)
        case failed(Error)
    }

    private static let infrastructure: Infrastructure = {
        let schema = Schema([SportRecordModel.self])
        do {
            let stack = try SwiftDataStack(for: schema)
            let apiClient: APIClient = URLSessionAPIClient(
                baseURL: supabaseConfig.projectURL,
                defaultHeaders: supabaseConfig.defaultHeaders
            )
            let local = SwiftDataLocalDataSource(modelContainer: stack.container)
            let remote = SupabaseRemoteSportRecordDataSource(apiClient: apiClient)
            let repository: SportRecordRepository = SportRecordRepositoryImpl(
                local: local,
                remote: remote
            )
            return .ready(repository: repository)
        } catch {
            return .failed(error)
        }
    }()

    public static var liveValue: SportRecordsClient {
        switch infrastructure {
        case let .ready(repository):
            // All operations delegate to the repository, which owns
            // the routing logic for local vs remote data sources.
            return SportRecordsClient(
                fetchAll: { try await repository.fetchAll() },
                add: { try await repository.add($0) },
                delete: { try await repository.delete($0) }
            )

        case let .failed(error):
            // Every operation surfaces the initialization error to the UI
            // so the user sees a meaningful message instead of a crash.
            return SportRecordsClient(
                fetchAll: { throw error },
                add: { _ in throw error },
                delete: { _ in throw error }
            )
        }
    }
}
