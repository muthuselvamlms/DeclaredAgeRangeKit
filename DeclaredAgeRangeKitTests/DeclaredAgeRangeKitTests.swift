//
//  DeclaredAgeRangeKitTests.swift
//  DeclaredAgeRangeKitTests
//
//  Created by Muthu L on 26/10/25.
//

import XCTest
@testable import DeclaredAgeRangeKit
import UIKit

final class AgeRangeServiceTests: XCTestCase {
    
    // MARK: - Mocks
    final class DummyProvider: AgeRangeProviderProtocol {
        var shouldThrow = false
        var lastThresholds: (Int, Int?, Int?)?
        var lastCalled = false
        var simulatedResponse: AgeRangeService.Response = .sharing(range: .init(lowerBound: 18))
        
        func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int?, _ threshold3: Int?, in viewController: UIViewController) async throws -> AgeRangeService.Response {
            lastCalled = true
            lastThresholds = (threshold1, threshold2, threshold3)
            if shouldThrow {
                throw AgeRangeService.Error.notAvailable
            }
            return simulatedResponse
        }
        
        func resetMockData() {
            lastCalled = false
            lastThresholds = nil
        }
    }

    // MARK: - Properties
    var provider: DummyProvider!
    var service: AgeRangeService!

    override func setUp() {
        super.setUp()
        provider = DummyProvider()
        service = AgeRangeService(provider)
    }

    override func tearDown() {
        provider = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Basic Tests
    func testRequestAgeRange_SuccessfulResponse() async throws {
        // Given
        provider.simulatedResponse = .sharing(range: .init(lowerBound: 13, upperBound: 17))
        
        // When
        let response = try await service.requestAgeRange(ageGates: 13, nil, nil, in: UIViewController())
        
        // Then
        if case .sharing(let range) = response {
            XCTAssertEqual(range.lowerBound, 13)
            XCTAssertEqual(range.upperBound, 17)
        } else {
            XCTFail("Expected .sharing response")
        }
        XCTAssertTrue(provider.lastCalled)
    }

    func testRequestAgeRange_ThrowsError() async {
        // Given
        provider.shouldThrow = true
        
        // When
        do {
            _ = try await service.requestAgeRange(ageGates: 13, nil, nil, in: UIViewController())
            XCTFail("Expected error not thrown")
        } catch let error as AgeRangeService.Error {
            // Then
            XCTAssertEqual(error, .notAvailable)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testResetMockData_ClearsProviderState() {
        // Given
        provider.lastCalled = true
        
        // When
        service.resetMockData()
        
        // Then
        XCTAssertFalse(provider.lastCalled)
    }

    // MARK: - Struct & Enum Conformance
    func testErrorHashableEquatable() {
        let err1 = AgeRangeService.Error.notAvailable
        let err2 = AgeRangeService.Error.notAvailable
        XCTAssertEqual(err1, err2)
        XCTAssertEqual(err1.hashValue, err2.hashValue)
    }

    func testAgeRangeDeclarationEquatableHashable() {
        let decl1 = AgeRangeService.AgeRangeDeclaration.selfDeclared
        let decl2 = AgeRangeService.AgeRangeDeclaration.selfDeclared
        XCTAssertEqual(decl1, decl2)
        XCTAssertEqual(decl1.hashValue, decl2.hashValue)
    }

    func testParentalControlsOptionSet() {
        var controls: AgeRangeService.ParentalControls = [.communicationLimits, .screenTimeLimits]
        XCTAssertTrue(controls.contains(.communicationLimits))
        XCTAssertTrue(controls.description.contains("communicationLimits"))
        controls.remove(.communicationLimits)
        XCTAssertFalse(controls.contains(.communicationLimits))
    }

    // MARK: - MockSettings & SharingPreference
    func testMockSettingsInitialization() {
        let mockSettings = AgeRangeService.MockSettings(
            dateOfBirth: Date(),
            sharingPreference: .askFirst,
            activeParentalControls: [.screenTimeLimits]
        )
        XCTAssertNotNil(mockSettings.dateOfBirth)
        XCTAssertEqual(mockSettings.sharingPreference, .askFirst)
        XCTAssertTrue(mockSettings.activeParentalControls.contains(.screenTimeLimits))
    }

    // MARK: - Response Enum
    func testResponseDeclinedSharing() {
        let response = AgeRangeService.Response.declinedSharing
        if case .declinedSharing = response {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected declinedSharing case")
        }
    }
}
