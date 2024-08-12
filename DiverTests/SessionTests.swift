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
        try await logIn(subject: subject)
        XCTAssertTrue(subject.isLoggedIn)
    }

    @MainActor func testItCanConfirmLogout() async throws {
        let repo = MockSessionRepository()
        let subject = Session(repo: repo)
        try await logIn(subject: subject)
        XCTAssertEqual(.undetermined, subject.logout)
        try await expect("It should log out") {
            subject.requestLogout()
        } toChange: {
            _ = subject.logout
        }
        XCTAssertEqual(.requested, subject.logout)
        XCTAssertTrue(subject.promptLogoutConfirmation)
        try await expect("It should log out on confirmation") {
            subject.confirmLogout()
        } toChange: {
            _ = subject.logout
        }
        XCTAssertFalse(subject.isLoggedIn)
    }

    @MainActor func testItCanCancelLogout() async throws {
        let repo = MockSessionRepository()
        let subject = Session(repo: repo)
        try await logIn(subject: subject)
        XCTAssertEqual(.undetermined, subject.logout)
        try await expect("It should log out") {
            subject.requestLogout()
        } toChange: {
            _ = subject.logout
        }
        XCTAssertEqual(.requested, subject.logout)
        XCTAssertTrue(subject.promptLogoutConfirmation)
        try await expect("It should log out on confirmation") {
            subject.cancelLogout()
        } toChange: {
            _ = subject.logout
        }
        XCTAssertTrue(subject.isLoggedIn)
    }

    @MainActor private func logIn(subject: Session) async throws {
        // Log in
        try await expect("It should log in") {
            subject.logIn()
        } toChange: {
            _ = subject.isLoggedIn
        }
    }
}
