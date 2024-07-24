//
//  PostsTests.swift
//  DiverTests
//
//  Created by Gerald Burke on 7/23/24.
//

import XCTest
@testable import Diver

final class PostsTests: DiverTests {
    @MainActor func testItGetsFollowedAuthors() async throws {
        let subject = Posts(repo: MockPostsRepository())
        let itHasExpectedPostsCount = expectation(description: #function)
        withObservationTracking {
            let _ = subject.timeline
        } onChange: {
            itHasExpectedPostsCount.fulfill()
        }
        subject.getPosts()
        await fulfillment(of: [itHasExpectedPostsCount], timeout: 1)
        XCTAssertEqual(12, subject.timeline.count)
    }
}
