import Foundation

/// Turns a `DecodingError` into a short phrase a reader can act on, since the
/// framework's own description is either empty or a debug dump.
enum SnapshotDecodingDetail {
    static func describe(_ error: DecodingError) -> String {
        switch error {
        case let .keyNotFound(key, context):
            return "missing \"\(key.stringValue)\"\(location(context))"
        case let .typeMismatch(_, context):
            return shapeOrLocation("unexpected value", context)
        case let .valueNotFound(_, context):
            return shapeOrLocation("empty value", context)
        case .dataCorrupted:
            return "the response wasn't valid JSON"
        @unknown default:
            return "the response wasn't in the expected shape"
        }
    }

    /// Without a coding path, "unexpected value" on its own says nothing, so
    /// describe the whole response instead.
    private static func shapeOrLocation(
        _ phrase: String, _ context: DecodingError.Context
    ) -> String {
        let place = location(context)
        return place.isEmpty ? "the response wasn't in the expected shape" : phrase + place
    }

    /// Array elements arrive as `Index 0`; number them from one instead, hung
    /// off the field they belong to (`markets #1`).
    private static func location(_ context: DecodingError.Context) -> String {
        var path: [String] = []
        for key in context.codingPath {
            if let index = key.intValue {
                path.append("\(path.popLast() ?? "item") #\(index + 1)")
            } else if !key.stringValue.isEmpty {
                path.append(key.stringValue)
            }
        }
        guard !path.isEmpty else { return "" }
        return " in \(path.joined(separator: " → "))"
    }
}
