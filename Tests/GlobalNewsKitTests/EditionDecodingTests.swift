import Foundation
import XCTest
@testable import GlobalNewsKit

final class EditionDecodingTests: XCTestCase {
    private func fixture() throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "news", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    func testDecodesEdition() throws {
        let edition = try EditionClient.decode(try fixture())

        XCTAssertEqual(edition.stories.count, 6)
        XCTAssertEqual(edition.generatedDate, Edition.iso8601.date(from: "2026-08-19T06:00:00Z"))
        XCTAssertEqual(edition.lead?.id, "opec-quota-rethink")
        XCTAssertTrue(edition.lead?.isBreaking == true)
        XCTAssertEqual(edition.rest.count, 5)
        XCTAssertFalse(edition.rest.contains { $0.id == "opec-quota-rethink" })
    }

    func testDecodesStoryFields() throws {
        let story = try XCTUnwrap(try EditionClient.decode(try fixture()).lead)

        XCTAssertEqual(story.region, .middleEast)
        XCTAssertEqual(story.topic, .energy)
        XCTAssertEqual(story.source, "Randy's Energy Desk")
        XCTAssertEqual(story.imageURL?.lastPathComponent, "opec.jpg")
        XCTAssertEqual(story.paragraphs.count, 3)
    }

    func testUnknownRegionAndTopicFallBack() throws {
        let story = try XCTUnwrap(
            try EditionClient.decode(try fixture()).stories.first { $0.id == "antarctic-relay" }
        )

        XCTAssertEqual(story.region, .other)
        XCTAssertEqual(story.topic, .world)
    }

    func testOptionalStoryFieldsMayBeAbsent() throws {
        let json = Data(
            """
            {"generated_at": "2026-08-19T06:00:00Z", "headline": "Minimal",
             "stories": [{"id": "a", "headline": "H", "region": "europe"}]}
            """.utf8
        )

        let story = try XCTUnwrap(try EditionClient.decode(json).stories.first)

        XCTAssertEqual(story.standfirst, "")
        XCTAssertNil(story.articleURL)
        XCTAssertFalse(story.isLead)
        XCTAssertEqual(story.topic, .world)
    }

    func testRegionsAreInFirstAppearanceOrder() throws {
        let edition = try EditionClient.decode(try fixture())

        XCTAssertEqual(edition.regions, [.middleEast, .europe, .asiaPacific, .africa, .americas, .other])
        XCTAssertEqual(edition.stories(in: .europe).map(\.id), ["ecb-holds"])
    }
}
