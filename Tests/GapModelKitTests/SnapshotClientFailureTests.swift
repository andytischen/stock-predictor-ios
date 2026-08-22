import Foundation
import XCTest
@testable import GapModelKit

final class SnapshotClientFailureTests: XCTestCase {
    func testMissingSnapshotReadsAsUnpublished() {
        XCTAssertEqual(
            SnapshotClient.Failure.badStatus(404).localizedDescription,
            "No snapshot has been published yet (404)."
        )
    }

    func testServerErrorsBlameTheServer() {
        XCTAssertEqual(
            SnapshotClient.Failure.badStatus(502).localizedDescription,
            "The snapshot server is having trouble (502)."
        )
    }

    func testOtherStatusesCarryTheCode() {
        XCTAssertEqual(
            SnapshotClient.Failure.badStatus(403).localizedDescription,
            "The snapshot couldn't be downloaded (HTTP 403)."
        )
    }
}
