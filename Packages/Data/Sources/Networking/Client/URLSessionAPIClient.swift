import Foundation

/// Concrete `APIClient` backed by `URLSession`.
public final class URLSessionAPIClient: APIClient, Sendable {
    private static let contentTypeJSON = "application/json"
    private static let successStatusRange = 200...299

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let defaultHeaders: [String: String]

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        defaultHeaders: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.session = session
        self.defaultHeaders = defaultHeaders

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    public func request<T: Decodable & Sendable>(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String],
        body: (any Encodable & Sendable)?
    ) async throws -> T {
        let (data, _) = try await performRequest(
            endpoint: endpoint,
            method: method,
            headers: headers,
            body: body
        )

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    public func requestVoid(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String],
        body: (any Encodable & Sendable)?
    ) async throws {
        _ = try await performRequest(
            endpoint: endpoint,
            method: method,
            headers: headers,
            body: body
        )
    }

    // MARK: - Private

    private func performRequest(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String],
        body: (any Encodable & Sendable)?
    ) async throws -> (Data, HTTPURLResponse) {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(Self.contentTypeJSON, forHTTPHeaderField: "Content-Type")

        for (key, value) in defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.encodingError(error)
            }
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard Self.successStatusRange.contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        return (data, httpResponse)
    }
}
