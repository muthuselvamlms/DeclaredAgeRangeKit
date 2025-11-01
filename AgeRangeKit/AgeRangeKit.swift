//
//  AgeRangeKit.swift
//  AgeRangeKit
//
//  Created by Muthu L on 01/11/25.
//

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

public protocol AgeRangeProviderProtocol {
    #if canImport(UIKit)
    func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int?, _ threshold3: Int?, in viewController: UIViewController) async throws -> AgeRangeService.Response
    #elseif canImport(AppKit)
    func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int?, _ threshold3: Int?, in window: NSWindow) async throws -> AgeRangeService.Response
    #endif
    func resetMockData()
}

/// A request for the age range of a person
/// logged onto the current device.
///
/// Use `AgeRangeService` to request a person's age range and manage their access to content on your app.
/// The code snippet below describes how to request a person's age range
/// and determine what content to display on your app's landing page.
///
/// ```swift
/// do {
///    let response = try await AgeRangeService.shared.requestAgeRange(ageGates: 13, 15, 18)
///    guard let lowerBound = response.lowerBound else {
///        // Allow access to under 13 features.
///        return
///    }
///    if lowerBound >= 18 {
///       // Allow access to 18+ features.
///    } else if lowerBound >= 15 {
///        // Allow access to 15+ features.
///    } else if lowerBound >= 13 {
///        // Allow access to 13+ features.
///    }
/// } catch AgeRangeService.Error.notAvailable {
///    // No age range provided.
///    return
/// }
/// ```
public struct AgeRangeService {
    private var provider: AgeRangeProviderProtocol
    
    /// The singleton app instance.
    ///
    /// Use `shared` to access the ``AgeRangeService`` instance in your app.
    public static let shared = AgeRangeService()
    
    /// An error that occurs when an age range request fails.
    public enum Error: LocalizedError {
        /// The system was unable to share the person's age.
        ///
        /// When the system prompts a person and they decide not to share their age range with your app.
        case notAvailable

        /// The request is invalid.
        case invalidRequest
        
        /// The unknown error
        case unknown
    }
    
    /// An enumeration that describes the declared age range.
    ///
    /// The system specifies whether the person declared the age range or an adult made the determination.
    public enum AgeRangeDeclaration {
        
        /// The age range was declared by the person.
        case selfDeclared
        
        /// The age range was declared by a parent or guardian.
        case guardianDeclared
    }
    
    
    /// An option set to define parental controls enabled and shared as a part of age range declaration.
    public struct ParentalControls: OptionSet {
        /// The raw value of the option set.
        public let rawValue: Int
        
        /// No parental controls are enabled.
        public static let none = ParentalControls([])
        
        /// The system restricts access to content based on age ratings.
        public static let contentRestrictions = ParentalControls(rawValue: 1 << 0)
        
        /// The system enforces screen time limits.
        public static let screenTimeLimits = ParentalControls(rawValue: 1 << 1)
        
        /// The system limits communication with the person.
        public static let communicationLimits = ParentalControls(rawValue: 1 << 2)
        
        /// Creates an option set with the specified raw value.
        /// - Parameter rawValue: The raw value of the option set.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// The raw value of the option set.
        public var description: String {
            var components: [String] = []
            if contains(.contentRestrictions) { components.append("contentRestrictions") }
            if contains(.screenTimeLimits) { components.append("screenTimeLimits") }
            if contains(.communicationLimits) { components.append("communicationLimits") }
            return components.isEmpty ? "none" : components.joined(separator: ", ")
        }
    }
    
    /// A person's age range is based on the information they provided in response to the age range request.
    ///
    /// For more information, refer to ``requestAgeRange(ageGates:_:_:in:)``
    public struct AgeRange {
        /// The lower limit of the person's age range.
        ///
        /// If nil, then the lower bound of the person's age range is 0.
        public var lowerBound: Int?
        
        /// The upper limit of the person's age range.
        ///
        /// If nil, then there's no upper bound of the person's age range.
        public var upperBound: Int?
        
        /// The sharer of the age range.
        ///
        /// For more information, refer to  ``AgeRangeService/AgeRangeDeclaration``.
        public var ageRangeDeclaration: AgeRangeService.AgeRangeDeclaration?
        
        /// The parental controls turned on as a part of the response.
        ///
        /// If empty, upper bound of age range is not below 18 or the person is under 18 with no parental controls enabled.
        public var activeParentalControls: AgeRangeService.ParentalControls
        
        /// Creates a new age range with the specified bounds and controls.
        /// - Parameters:
        ///   - lowerBound: The lower limit of the person's age range. If nil, the lower bound is 0.
        ///   - upperBound: The upper limit of the person's age range. If nil, there's no upper bound.
        ///   - ageRangeDeclaration: Who declared the age range (self or guardian).
        ///   - activeParentalControls: The active parental controls, if any.
        public init(
            lowerBound: Int? = nil,
            upperBound: Int? = nil,
            ageRangeDeclaration: AgeRangeService.AgeRangeDeclaration? = nil,
            activeParentalControls: AgeRangeService.ParentalControls = []
        ) {
            self.lowerBound = lowerBound
            self.upperBound = upperBound
            self.ageRangeDeclaration = ageRangeDeclaration
            self.activeParentalControls = activeParentalControls
        }
    }
    
    /// A response indicating either a person shared their age range or declined to share it.
    public enum Response {

        /// The person declined to share their age range.
        case declinedSharing

        /// The person shared the age range successfully.
        case sharing(range: AgeRangeService.AgeRange)
    }
    
    public init(_ ageRangeProvider: AgeRangeProviderProtocol? = nil) {
        if let ageRangeProvider {
            self.provider = ageRangeProvider
            return
        }
        if #available(iOS 26.0, macOS 26.0, *) {
            #if canImport(DeclaredAgeRange)
            provider = AppleAgeRangeProvider()
            #else
            provider = MockAgeRangeProvider()
            #endif
        } else {
            provider = MockAgeRangeProvider()
        }
    }
    
    /// Determines an age range for the person using the device.
    /// - Parameters:
    ///   - threshold1: The required age gate for your app.
    ///   - threshold2: An optional additional age gate for your app.
    ///   - threshold3: An optional additional age gate for your app.
    ///   - window: The window to anchor and present system UI off of.
    /// - Returns: An ``AgeRangeService/Response`` or throws an ``Error``.
    ///
    #if canImport(UIKit)
    public func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int? = nil, _ threshold3: Int? = nil, in viewController: UIViewController) async throws -> AgeRangeService.Response {
        return try await provider.requestAgeRange(ageGates: threshold1, threshold2, threshold3, in: viewController)
    }
    #elseif canImport(AppKit)
    public func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int? = nil, _ threshold3: Int? = nil, in window: NSWindow) async throws -> AgeRangeService.Response {
        return try await provider.requestAgeRange(ageGates: threshold1, threshold2, threshold3, in: window)
    }
    #endif
    
    /// Resets mock data if using the mock provider.
    public func resetMockData() {
        provider.resetMockData()
    }

    /// Sharing preference options for mock implementation
    public enum MockSharingPreference {
        /// Always share age range with requesting apps
        case alwaysShare
        /// Ask for permission before sharing age range
        case askFirst
        /// Never share age range with requesting apps
        case never
    }

    /// Settings available in mock implementation
    public struct MockSettings {
        /// The user's date of birth
        public let dateOfBirth: Date?
        /// The current sharing preference
        public let sharingPreference: MockSharingPreference
        /// Currently enabled parental controls
        public let activeParentalControls: ParentalControls
    }
}

// MARK: - AgeRangeService Error Conformances
extension AgeRangeService.Error: Equatable {}
extension AgeRangeService.Error: Hashable {}

// MARK: - AgeRangeService AgeRangeDeclaration Conformances
extension AgeRangeService.AgeRangeDeclaration: Equatable {}
extension AgeRangeService.AgeRangeDeclaration: Hashable {}

// MARK: - SwiftUI Support
#if canImport(SwiftUI)
import SwiftUI

@available(iOS 26.0, macOS 26.0, *)
@available(visionOS, unavailable)
public struct RequestAgeRangeAction {
    
    /// Requests the declared age range from the system or mock service.
    ///
    /// Automatically infers the correct presentation context (UIViewController / NSWindow).
    public func callAsFunction(ageGates threshold1: Int,
                               _ threshold2: Int? = nil,
                               _ threshold3: Int? = nil) async throws -> AgeRangeService.Response {
        #if canImport(UIKit)
        guard let rootVC = await UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.keyWindow?.rootViewController else {
            throw AgeRangeService.Error.invalidRequest
        }
        return try await AgeRangeService.shared.requestAgeRange(
            ageGates: threshold1,
            threshold2,
            threshold3,
            in: rootVC
        )
        #elseif canImport(AppKit)
        return try await MainActor.run {
            guard let keyWindow = NSApp.keyWindow else {
                throw AgeRangeService.Error.invalidRequest
            }
            return try await AgeRangeService.shared.requestAgeRange(
                ageGates: threshold1,
                threshold2,
                threshold3,
                in: keyWindow
            )
        }
        #endif
    }
}

@available(iOS 26.0, macOS 26.0, *)
@available(visionOS, unavailable)
private struct RequestAgeRangeKey: EnvironmentKey {
    public static let defaultValue = RequestAgeRangeAction()
}

@available(iOS 26.0, macOS 26.0, *)
@available(visionOS, unavailable)
extension EnvironmentValues {
    public var requestAgeRange: RequestAgeRangeAction {
        get { self[RequestAgeRangeKey.self] }
        set { self[RequestAgeRangeKey.self] = newValue }
    }
}
#endif

