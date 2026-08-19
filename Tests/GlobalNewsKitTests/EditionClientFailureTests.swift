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
}
