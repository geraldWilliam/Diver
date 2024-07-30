//
//  DiverTests.swift
//  DiverTests
//
//  Created by Gerald Burke on 7/15/24.
//

import XCTest

class DiverTests: XCTestCase {
    /// Use this class to define shared functionality for test cases. Other test cases inherit from this superclass.
    func expect(
        _ description: String,
        duration: TimeInterval = 1,
        operation: @escaping () -> Void,
        toChange access: @escaping () -> Void
    ) async throws {
        let condition = expectation(description: description)
        withObservationTracking {
            access()
        } onChange: {
            condition.fulfill()
        }
        operation()
        await fulfillment(of: [condition], timeout: duration)
    }
}
