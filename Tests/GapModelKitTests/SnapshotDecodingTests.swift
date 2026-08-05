import XCTest
@testable import GapModelKit

final class SnapshotDecodingTests: XCTestCase {
    private func loadFixture() throws -> Data {
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "snapshot", withExtension: "json"),
            "snapshot.json fixture missing"
        )
        return try Data(contentsOf: url)
    }

    func testDecodesTheDocumentedShape() throws {
        let snapshot = try SnapshotClient.decode(loadFixture())
        XCTAssertEqual(snapshot.generatedAt, "2026-08-05T06:30:00Z")
        XCTAssertEqual(snapshot.summary, "Brent -0.3%, WTI -0.8% | S&P 500 73%")
        XCTAssertEqual(snapshot.markets.count, 2)
        XCTAssertEqual(snapshot.crude.count, 1)

        let sp = try XCTUnwrap(snapshot.markets.first)
        XCTAssertEqual(sp.market, "S&P 500")
        XCTAssertEqual(sp.symbol, "^GSPC")
        XCTAssertEqual(sp.pOpenUp, 0.7272, accuracy: 1e-9)
        XCTAssertEqual(sp.oosAuc, 0.6939, accuracy: 1e-9)
        let driver = try XCTUnwrap(sp.drivers.first)
        XCTAssertEqual(driver.name, "mkt_n225_return")
        XCTAssertEqual(driver.logOdds, 0.8518, accuracy: 1e-9)
    }

    func testShockFieldsAreOptional() throws {
        let snapshot = try SnapshotClient.decode(loadFixture())
        XCTAssertNil(snapshot.markets[0].pShocked)
        XCTAssertEqual(snapshot.markets[1].pShocked, 0.48)
        XCTAssertEqual(try XCTUnwrap(snapshot.markets[1].pChange), 0.0677, accuracy: 1e-9)
    }

    func testParsesTimestamps() throws {
        let snapshot = try SnapshotClient.decode(loadFixture())
        XCTAssertNotNil(snapshot.generatedDate)
        // ASX 200 opens the previous calendar day (23:00 UTC).
        let asx = snapshot.markets[1]
        XCTAssertEqual(asx.sessionOpenUtc, "2026-08-04T23:00:00Z")
        XCTAssertNotNil(asx.sessionOpenDate)
    }

    func testCrudeDecodes() throws {
        let crude = try XCTUnwrap(SnapshotClient.decode(loadFixture()).crude.first)
        XCTAssertEqual(crude.symbol, "BZ=F")
        XCTAssertEqual(crude.return1d, -0.0033, accuracy: 1e-9)
        XCTAssertFalse(crude.isShock)
    }
}

final class FormattingTests: XCTestCase {
    func testPercent() {
        XCTAssertEqual(Format.percent(0.7272), "73%")
        XCTAssertEqual(Format.percent(0.5), "50%")
    }

    func testSignedPercent() {
        XCTAssertEqual(Format.signedPercent(-0.008), "-0.8%")
        XCTAssertEqual(Format.signedPercent(0.013), "+1.3%")
    }

    func testLeansUp() {
        XCTAssertTrue(Format.leansUp(0.5))
        XCTAssertFalse(Format.leansUp(0.49))
    }
}
