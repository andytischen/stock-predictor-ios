import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Downloads and decodes the published `news.json` edition.
public struct EditionClient: Sendable {
    public let url: URL
    private let session: URLSession

    public init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }

    public enum Failure: Error, Equatable {
        case badStatus(Int)
    }

    /// Fetch the latest edition. Throws on transport, HTTP or decoding errors.
    public func fetch() async throws -> Edition {
        let (data, response) = try await session.data(from: url)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw Failure.badStatus(http.statusCode)
        }
        return try Edition.decoder.decode(Edition.self, from: data)
    }

    /// Decode an edition from bytes already in hand (previews, tests, cache).
    public static func decode(_ data: Data) throws -> Edition {
        try Edition.decoder.decode(Edition.self, from: data)
    }
}
