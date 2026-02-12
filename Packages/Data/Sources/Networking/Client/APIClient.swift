import Foundation

/// Protocol for making HTTP requests.
/// Abstracted to allow testing with mock implementations.
public protocol APIClient: Sendable {
    /// Performs an HTTP request and decodes the response body.
    func request<T: Decodable & Sendable>(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String],
        body: (any Encodable & Sendable)?
    ) async throws -> T

    /// Performs an HTTP request without decoding a response body (e.g. DELETE returning 204).
    func requestVoid(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String],
        body: (any Encodable & Sendable)?
    ) async throws
}

// MARK: - Convenience overloads (no per-request headers)

extension APIClient {
    public func request<T: Decodable & Sendable>(
        endpoint: String,
        method: HTTPMethod,
        body: (any Encodable & Sendable)?
    ) async throws -> T {
        try await request(endpoint: endpoint, method: method, headers: [:], body: body)
    }

    public func requestVoid(
        endpoint: String,
        method: HTTPMethod,
        body: (any Encodable & Sendable)?
    ) async throws {
        try await requestVoid(endpoint: endpoint, method: method, headers: [:], body: body)
    }
}
