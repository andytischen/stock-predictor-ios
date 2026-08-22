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
