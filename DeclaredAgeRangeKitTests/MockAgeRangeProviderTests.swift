//
//  MockAgeRangeProviderTests.swift
//  DeclaredAgeRangeKit
//
//  Created by Muthu L on 01/11/25.
//

import XCTest
@testable import DeclaredAgeRangeKit
import UIKit

final class MockAgeRangeProviderTests: XCTestCase {

    var provider: MockAgeRangeProvider!

    override func setUp() {
        super.setUp()
        provider = MockAgeRangeProvider()
    }

    override func tearDown() {
        provider = nil
        super.tearDown()
    }

    // MARK: - Test Default Initialization
    func testDefaultScenario_IsDeclinedSharing() {
        XCTAssertEqual(provider.currentScenario, .declinedSharing, "Default scenario should be declinedSharing.")
    }

    // MARK: - Test Declined Sharing Scenario
    func testRequestAgeRange_DeclinedSharing_ReturnsDeclined() async throws {
        provider.currentScenario = .declinedSharing

        let response = try await provider.requestAgeRange(ageGates: 13, nil, nil, in: UIViewController())

        if case .declinedSharing = response {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected declinedSharing response.")
        }
    }

    // MARK: - Test Sharing Scenarios
    func testRequestAgeRange_ChildScenario_ReturnsCorrectRange() async throws {
        provider.currentScenario = .sharingChild

        let response = try await provider.requestAgeRange(ageGates: 13, nil, nil, in: UIViewController())

        switch response {
        case .sharing(let range):
            XCTAssertEqual(range.lowerBound, 8)
            XCTAssertEqual(range.upperBound, 12)
            XCTAssertTrue(range.activeParentalControls.contains(.contentRestrictions))
        default:
            XCTFail("Expected sharing response for child scenario.")
        }
    }

    func testRequestAgeRange_TeenScenario_ReturnsCorrectRange() async throws {
        provider.currentScenario = .sharingTeen

        let response = try await provider.requestAgeRange(ageGates: 13, nil, nil, in: UIViewController())

        switch response {
        case .sharing(let range):
            XCTAssertEqual(range.lowerBound, 14)
            XCTAssertEqual(range.upperBound, 17)
            XCTAssertTrue(range.activeParentalControls.isEmpty)
        default:
            XCTFail("Expected sharing response for teen scenario.")
        }
    }

    func testRequestAgeRange_AdultScenario_ReturnsCorrectRange() async throws {
        provider.currentScenario = .sharingAdult

        let response = try await provider.requestAgeRange(ageGates: 18, nil, nil, in: UIViewController())

        switch response {
        case .sharing(let range):
            XCTAssertEqual(range.lowerBound, 18)
            XCTAssertNil(range.upperBound)
        default:
            XCTFail("Expected sharing response for adult scenario.")
        }
    }

    // MARK: - Test Error Scenarios
    func testRequestAgeRange_ErrorNotAvailable_Throws() async {
        provider.currentScenario = .errorNotAvailable
        await assertThrowsSpecificError(expectedError: .notAvailable)
    }

    func testRequestAgeRange_ErrorInvalidRequest_Throws() async {
        provider.currentScenario = .errorInvalidRequest
        await assertThrowsSpecificError(expectedError: .invalidRequest)
    }

    func testRequestAgeRange_ErrorUnknown_Throws() async {
        provider.currentScenario = .errorUnknown
        await assertThrowsSpecificError(expectedError: .unknown)
    }

    private func assertThrowsSpecificError(expectedError: AgeRangeService.Error, file: StaticString = #filePath, line: UInt = #line) async {
        do {
            _ = try await provider.requestAgeRange(ageGates: 13, nil, nil, in: UIViewController())
            XCTFail("Expected \(expectedError) to be thrown", file: file, line: line)
        } catch let error as AgeRangeService.Error {
            XCTAssertEqual(error, expectedError, "Expected \(expectedError), got \(error)", file: file, line: line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: file, line: line)
        }
    }

    // MARK: - Test Reset Behavior
    func testResetMockData_ResetsScenarioToDefault() {
        provider.currentScenario = .sharingAdult
        provider.resetMockData()
        XCTAssertEqual(provider.currentScenario, .declinedSharing)
    }
}
