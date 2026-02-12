import Foundation

/// Configuration for connecting to a Supabase project.
///
/// Contains the project URL and API key needed for PostgREST requests.
/// The API key is sent in both `apikey` and `Authorization` headers.
public struct SupabaseConfig: Sendable {
    private enum HeaderKey {
        static let apiKey = "apikey"
        static let authorization = "Authorization"
        static let bearerPrefix = "Bearer "
    }

    public let projectURL: URL
    public let apiKey: String

    public init(projectURL: URL, apiKey: String) {
        self.projectURL = projectURL
        self.apiKey = apiKey
    }

    /// Default HTTP headers required by the Supabase REST API.
    public var defaultHeaders: [String: String] {
        [
            HeaderKey.apiKey: apiKey,
            HeaderKey.authorization: "\(HeaderKey.bearerPrefix)\(apiKey)",
        ]
    }
}
