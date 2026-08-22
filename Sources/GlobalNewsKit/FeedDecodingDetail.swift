import Foundation

/// Turns a `DecodingError` into a short phrase a reader can act on, since the
/// framework's own description is either empty or a debug dump.
enum FeedDecodingDetail {
    static func describe(_ error: DecodingError) -> String {
        switch error {
        case let .keyNotFound(key, context):
            return "missing \"\(key.stringValue)\"\(location(context))"
        case let .typeMismatch(_, context):
            return "unexpected value\(location(context))"
        case let .valueNotFound(_, context):
            return "empty value\(location(context))"
        case .dataCorrupted:
            return "the response wasn't valid JSON"
        @unknown default:
            return "unexpected shape"
        }
    }

    private static func location(_ context: DecodingError.Context) -> String {
        let path = context.codingPath.map(\.stringValue).filter { !$0.isEmpty }
        guard !path.isEmpty else { return "" }
        return " in \(path.joined(separator: " → "))"
    }
}
