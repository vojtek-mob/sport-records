@testable import Networking
import XCTest

final class ISO8601DateCoderTests: XCTestCase {
    // MARK: - parse

    func testParsesDateWithFractionalSeconds() throws {
        let date = try XCTUnwrap(ISO8601DateCoder.parse("2023-11-14T22:13:20.000Z"))
        XCTAssertEqual(date.timeIntervalSince1970, 1_700_000_000, accuracy: 1.0)
    }

    func testParsesDateWithoutFractionalSeconds() throws {
        let date = try XCTUnwrap(ISO8601DateCoder.parse("2023-11-14T22:13:20+00:00"))
        XCTAssertEqual(date.timeIntervalSince1970, 1_700_000_000, accuracy: 1.0)
    }

    func testParsesDateWithTimezoneOffset() throws {
        // +01:00 means the UTC time is one hour earlier
        let date = try XCTUnwrap(ISO8601DateCoder.parse("2023-11-14T23:13:20+01:00"))
        XCTAssertEqual(date.timeIntervalSince1970, 1_700_000_000, accuracy: 1.0)
    }

    func testReturnsNilForEmptyString() {
        XCTAssertNil(ISO8601DateCoder.parse(""))
    }

    func testReturnsNilForGarbageInput() {
        XCTAssertNil(ISO8601DateCoder.parse("not-a-date"))
    }

    func testReturnsNilForDateOnlyString() {
        XCTAssertNil(ISO8601DateCoder.parse("2023-11-14"))
    }

    // MARK: - string(from:)

    func testStringFromDateProducesParsableOutput() throws {
        let original = Date(timeIntervalSince1970: 1_700_000_000)
        let string = ISO8601DateCoder.string(from: original)
        let parsed = try XCTUnwrap(ISO8601DateCoder.parse(string))

        XCTAssertEqual(
            parsed.timeIntervalSince1970,
            original.timeIntervalSince1970,
            accuracy: 0.001
        )
    }

    func testStringFromDateContainsFractionalSeconds() {
        let string = ISO8601DateCoder.string(from: Date(timeIntervalSince1970: 1_700_000_000.123))
        // The output should contain a dot for fractional seconds
        XCTAssertTrue(string.contains("."))
    }
}
