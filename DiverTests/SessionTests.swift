//
//  SessionTests.swift
//  DiverTests
//
//  Created by Gerald Burke on 8/1/24.
//

import XCTest
@testable import Diver

final class SessionTests: DiverTests {
    @MainActor func testItCanLogIn() async throws {
        let repo = MockSessionRepository()
        let subject = Session(repo: repo)
        XCTAssertFalse(subject.isLoggedIn)
        try await expect("It should log in") {
            subject.logIn()
        } toChange: {
            _ = subject.isLoggedIn
        }
        XCTAssertTrue(subject.isLoggedIn)
    }
}
