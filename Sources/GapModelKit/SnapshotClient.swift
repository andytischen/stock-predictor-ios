import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Downloads and decodes the published `snapshot.json`.
///
/// The app points this at the GitHub Pages URL the publish workflow writes to,
/// e.g. `https://andytischen.github.io/Stock-Market-Predictor/snapshot.json`.
public struct SnapshotClient: Sendable {
    public let url: URL
    private let session: URLSession

    public init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }

    public enum Failure: LocalizedError, Equatable {
        case badStatus(Int)

        /// `SnapshotStore` shows `localizedDescription`, so spell the reason out;
        /// the default for a bare `Error` is "the operation could not be completed".
        public var errorDescription: String? {
            switch self {
            case .badStatus(404):
                return "No snapshot has been published yet (404)."
            case let .badStatus(code) where code >= 500:
                return "The snapshot server is having trouble (\(code))."
            case let .badStatus(code):
                return "The snapshot couldn't be downloaded (HTTP \(code))."
            }
        }
    }

    /// Fetch the latest snapshot. Throws on transport, HTTP or decoding errors.
    public func fetch() async throws -> Snapshot {
        let (data, response) = try await session.data(from: url)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw Failure.badStatus(http.statusCode)
        }
        return try Snapshot.decoder.decode(Snapshot.self, from: data)
    }

    /// Decode a snapshot from bytes already in hand (previews, tests, cache).
    public static func decode(_ data: Data) throws -> Snapshot {
        try Snapshot.decoder.decode(Snapshot.self, from: data)
    }
}
