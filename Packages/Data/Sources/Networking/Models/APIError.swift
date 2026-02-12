import Foundation

/// Errors produced by `APIClient` implementations.
public enum APIError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case encodingError(Error)
    case decodingError(Error)
    case networkError(Error)
}
