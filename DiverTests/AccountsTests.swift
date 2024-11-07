//
//  AccountsTests.swift
//  DiverTests
//
//  Created by Gerald Burke on 11/7/24.
//

import XCTest

@testable import Diver

final class AccountsTests: DiverTests {
    func testItCanSearch() async throws {
        let repo = MockAccountRepository()
        let subject = Accounts(repo: repo)
        XCTAssertEqual(0, subject.searchResults.count)
        try await expect("It should get a search result.") {
            subject.search("@testUsername@testInstance.net")
        } toChange: {
            _ = subject.searchResults
        }
        XCTAssertEqual(1, subject.searchResults.count)
    }
    
    func testItCanGetFollowedAccounts() async throws {
        let repo = MockAccountRepository()
        let subject = Accounts(repo: repo)
        XCTAssertEqual(0, subject.following.count)
        try await expect("It should get followed accounts.") {
            subject.getFollowing()
        } toChange: {
            _ = subject.following
        }
        XCTAssertEqual(1, subject.following.count)
    }

    func testItCanFollowAccount() async throws {
        let repo = MockAccountRepository()
        let subject = Accounts(repo: repo)
        XCTAssertEqual(0, subject.following.count)
        try await expect("It should get the followed account.") {
            subject.follow("fake-id")
        } toChange: {
            _ = subject.following
        }
        XCTAssertEqual(1, subject.following.count)
    }
    
    func testItCanGetStoredAccounts() async throws {
        let repo = MockAccountRepository()
        let subject = Accounts(repo: repo)
        XCTAssertEqual(0, subject.stored.count)
        try await expect("It should get stored accounts.") {
            subject.getStored()
        } toChange: {
            _ = subject.stored
        }
        XCTAssertEqual(1, subject.stored.count)
    }
    
    func testItCanAddAccount() async throws {
        let repo = MockAccountRepository()
        let subject = Accounts(repo: repo)
        XCTAssertEqual(0, subject.stored.count)
        try await expect("It should add a stored account.") {
            subject.store(.mock())
        } toChange: {
            _ = subject.stored
        }
        XCTAssertEqual(1, subject.stored.count)
    }
}
