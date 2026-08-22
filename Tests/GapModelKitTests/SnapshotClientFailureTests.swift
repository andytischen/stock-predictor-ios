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

    func testNonJsonBodyReadsAsUnreadable() throws {
        do {
            _ = try SnapshotClient.decode(Data("<html>maintenance</html>".utf8))
            XCTFail("expected decoding to fail")
        } catch let failure as SnapshotClient.Failure {
            XCTAssertEqual(
                failure.localizedDescription,
                "The snapshot downloaded but couldn't be read (the response wasn't valid JSON)."
            )
        }
    }

    func testMissingFieldNamesTheField() throws {
        do {
            _ = try SnapshotClient.decode(Data("{}".utf8))
            XCTFail("expected decoding to fail")
        } catch let failure as SnapshotClient.Failure {
            XCTAssertTrue(
                failure.localizedDescription.hasPrefix(
                    "The snapshot downloaded but couldn't be read (missing \""
                ),
                failure.localizedDescription
            )
        }
    }
}
