import Foundation
import XCTest
@testable import GlobalNewsKit

final class EditionClientFailureTests: XCTestCase {
    func testMissingEditionReadsAsUnpublished() {
        let failure = EditionClient.Failure.badStatus(404)

        XCTAssertEqual(failure.localizedDescription, "The edition isn't published yet (404).")
    }

    func testServerErrorsBlameTheServer() {
        XCTAssertEqual(
            EditionClient.Failure.badStatus(503).localizedDescription,
            "The newsroom's server is having trouble (503)."
        )
    }

    func testOtherStatusesCarryTheCode() {
        XCTAssertEqual(
            EditionClient.Failure.badStatus(418).localizedDescription,
            "The edition couldn't be downloaded (HTTP 418)."
        )
    }

    func testNonJsonBodyReadsAsUnreadable() throws {
        let error = try failure(decoding: Data("<html>maintenance</html>".utf8))

        XCTAssertEqual(
            error.localizedDescription,
            "The edition downloaded but couldn't be read (the response wasn't valid JSON)."
        )
    }

    func testMissingFieldNamesTheFieldAndItsPath() throws {
        let json = Data(
            """
            {"generated_at": "2026-08-19T06:00:00Z", "headline": "Late",
             "stories": [{"id": "a", "region": "europe"}]}
            """.utf8
        )

        let error = try failure(decoding: json)

        XCTAssertEqual(
            error.localizedDescription,
            "The edition downloaded but couldn't be read (missing \"headline\" in stories #1)."
        )
    }

    func testAWholeResponseOfTheWrongShapeSaysSo() throws {
        let error = try failure(decoding: Data("[]".utf8))

        XCTAssertEqual(
            error.localizedDescription,
            "The edition downloaded but couldn't be read (the response wasn't in the expected shape)."
        )
    }

    /// `dataCorrupted` covers both a body that isn't JSON and a well-formed
    /// body holding a value a type refuses to parse (a malformed URL or date);
    /// only the first deserves "wasn't valid JSON".
    func testAValueTheModelCantParseIsNotCalledInvalidJson() {
        let path: [CodingKey] = [
            EditionKey(stringValue: "stories"), EditionKey(intValue: 0),
            EditionKey(stringValue: "image_url"),
        ]
        let corrupted = DecodingError.dataCorrupted(
            .init(codingPath: path, debugDescription: "Invalid URL string.")
        )

        XCTAssertEqual(
            FeedDecodingDetail.describe(corrupted),
            "unreadable value in stories #1 → image_url"
        )
    }

    private struct EditionKey: CodingKey {
        var stringValue: String
        var intValue: Int?

        init(stringValue: String) {
            self.stringValue = stringValue
            intValue = nil
        }

        init(intValue: Int) {
            self.intValue = intValue
            stringValue = "Index \(intValue)"
        }
    }

    private func failure(decoding data: Data) throws -> EditionClient.Failure {
        do {
            _ = try EditionClient.decode(data)
            XCTFail("expected decoding to fail")
            return .badStatus(0)
        } catch let failure as EditionClient.Failure {
            return failure
        }
    }
}
