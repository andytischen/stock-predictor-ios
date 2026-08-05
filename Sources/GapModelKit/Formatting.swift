import Foundation

/// Display helpers shared by the views, kept in the platform-agnostic core so
/// they can be unit-tested without SwiftUI.
public enum Format {
    /// A probability as a whole-percent string, e.g. `0.7272` → `"73%"`.
    public static func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    /// A signed return as a one-decimal percent, e.g. `-0.008` → `"-0.8%"`.
    public static func signedPercent(_ value: Double) -> String {
        let scaled = value * 100
        return String(format: "%+.1f%%", scaled)
    }

    /// Whether a market's call leans up (>= 0.5).
    public static func leansUp(_ probability: Double) -> Bool {
        probability >= 0.5
    }
}
