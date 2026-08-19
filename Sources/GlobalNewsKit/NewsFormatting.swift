import Foundation

/// Display helpers for the news layout, kept out of SwiftUI so they can be
/// unit-tested on Linux.
public enum NewsFormat {
    /// A compact age for a timestamp, e.g. `"12m ago"`, `"3h ago"`, `"2d ago"`.
    public static func age(of date: Date, now: Date = Date()) -> String {
        let seconds = max(0, now.timeIntervalSince(date))
        switch seconds {
        case ..<60: return "just now"
        case ..<3_600: return "\(Int(seconds / 60))m ago"
        case ..<86_400: return "\(Int(seconds / 3_600))h ago"
        default: return "\(Int(seconds / 86_400))d ago"
        }
    }

    /// The same, for the ISO-8601 strings the feed carries. Empty when unparsable.
    public static func age(ofISO8601 string: String, now: Date = Date()) -> String {
        guard let date = Edition.iso8601.date(from: string) else { return "" }
        return age(of: date, now: now)
    }

    /// The line under a headline: source, then age when known.
    public static func byline(_ story: Story, now: Date = Date()) -> String {
        let age = age(ofISO8601: story.publishedAt, now: now)
        return [story.source, age].filter { !$0.isEmpty }.joined(separator: " · ")
    }

    /// Roughly how long the story takes to read, e.g. `"3 min read"`.
    public static func readingTime(_ story: Story, wordsPerMinute: Int = 220) -> String {
        let words = story.body.split(whereSeparator: { $0.isWhitespace }).count
        return "\(max(1, Int((Double(words) / Double(wordsPerMinute)).rounded(.up)))) min read"
    }
}
