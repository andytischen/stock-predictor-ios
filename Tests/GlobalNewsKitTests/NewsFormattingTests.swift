import Foundation
import XCTest
@testable import GlobalNewsKit

final class NewsFormattingTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    func testAgeBuckets() {
        XCTAssertEqual(NewsFormat.age(of: now.addingTimeInterval(-30), now: now), "just now")
        XCTAssertEqual(NewsFormat.age(of: now.addingTimeInterval(-12 * 60), now: now), "12m ago")
        XCTAssertEqual(NewsFormat.age(of: now.addingTimeInterval(-3 * 3_600), now: now), "3h ago")
        XCTAssertEqual(NewsFormat.age(of: now.addingTimeInterval(-2 * 86_400), now: now), "2d ago")
    }

    func testFutureTimestampsReadAsJustNow() {
        XCTAssertEqual(NewsFormat.age(of: now.addingTimeInterval(600), now: now), "just now")
    }

    func testUnparsableTimestampHasNoAge() {
        XCTAssertEqual(NewsFormat.age(ofISO8601: "not a date", now: now), "")
    }

    func testBylineJoinsSourceAndAge() {
        let story = makeStory(
            source: "Randy's Asia Desk",
            publishedAt: Edition.iso8601.string(from: now.addingTimeInterval(-3_600))
        )

        XCTAssertEqual(NewsFormat.byline(story, now: now), "Randy's Asia Desk · 1h ago")
    }

    func testBylineOmitsMissingParts() {
        XCTAssertEqual(NewsFormat.byline(makeStory(source: "", publishedAt: ""), now: now), "")
        XCTAssertEqual(NewsFormat.byline(makeStory(source: "Desk", publishedAt: ""), now: now), "Desk")
    }

    func testReadingTimeRoundsUpToAtLeastOneMinute() {
        XCTAssertEqual(NewsFormat.readingTime(makeStory(body: "one two three")), "1 min read")

        let long = Array(repeating: "word", count: 500).joined(separator: " ")
        XCTAssertEqual(NewsFormat.readingTime(makeStory(body: long)), "3 min read")
    }

    private func makeStory(source: String = "Desk", publishedAt: String = "", body: String = "") -> Story {
        Story(
            id: "a", headline: "H", standfirst: "S", body: body, region: .europe,
            topic: .world, source: source, publishedAt: publishedAt
        )
    }
}
