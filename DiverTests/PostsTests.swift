//
//  PostsTests.swift
//  DiverTests
//
//  Created by Gerald Burke on 7/23/24.
//

import XCTest
@testable import Diver

final class PostsTests: DiverTests {
    @MainActor func testItGetsTimeline() async throws {
        let repo = MockPostsRepository()
        let subject = Posts(repo: repo)
        let itHasExpectedPostsCount = expectation(description: #function)
        withObservationTracking {
            _ = subject.timeline
        } onChange: {
            itHasExpectedPostsCount.fulfill()
        }
        subject.getLatestPosts()
        await fulfillment(of: [itHasExpectedPostsCount], timeout: 1)
        XCTAssertEqual(12, subject.timeline.count)
    }
    
    @MainActor func testItGetsEarlierPosts() async throws {
        let repo = MockPostsRepository()
        let subject = Posts(repo: repo)
        // Manually set the timeline to the latest posts.
        subject.timeline = try await repo.getLatestPosts()
        let itHasExpectedPostsCount = expectation(description: #function)
        withObservationTracking {
            _ = subject.timeline
        } onChange: {
            itHasExpectedPostsCount.fulfill()
        }
        subject.getEarlierPosts()
        await fulfillment(of: [itHasExpectedPostsCount], timeout: 1)
        XCTAssertEqual(24, subject.timeline.count)
    }
    
    @MainActor func testItGetsRepliesForPost() async throws {
        let repo = MockPostsRepository()
        let subject = Posts(repo: repo)
        let itHasRepliesForPost = expectation(description: #function)
        withObservationTracking {
            _ = subject.replies
        } onChange: {
            itHasRepliesForPost.fulfill()
        }
        let post = PostInfo.mock()
        subject.getReplies(for: post)
        await fulfillment(of: [itHasRepliesForPost])
        XCTAssertEqual(12, subject.replies[post.id]?.count)
    }
    
    @MainActor func testGetTimelineRaisesErrorOnFailure() async throws {
        let repo = FailingMockPostsRepository()
        let subject = Posts(repo: repo)
        let itRaisesError = expectation(description: #function)
        withObservationTracking {
            _ = subject.failure
        } onChange: {
            itRaisesError.fulfill()
        }
        subject.getLatestPosts()
        await fulfillment(of: [itRaisesError])
        XCTAssertNotNil(subject.failure)
    }
    
    @MainActor func testGetEarlierPostsRaisesErrorOnFailure() async throws {
        let repo = FailingMockPostsRepository()
        let subject = Posts(repo: repo)
        let itRaisesError = expectation(description: #function)
        withObservationTracking {
            _ = subject.failure
        } onChange: {
            itRaisesError.fulfill()
        }
        subject.getEarlierPosts()
        await fulfillment(of: [itRaisesError])
        XCTAssertNotNil(subject.failure)
    }
    
    @MainActor func testGetRepliesForPostRaisesErrorOnFailure() async throws {
        let repo = FailingMockPostsRepository()
        let subject = Posts(repo: repo)
        let itRaisesError = expectation(description: #function)
        withObservationTracking {
            _ = subject.failure
        } onChange: {
            itRaisesError.fulfill()
        }
        subject.getReplies(for: .mock())
        await fulfillment(of: [itRaisesError])
        XCTAssertNotNil(subject.failure)
    }
}

private struct FailingMockPostsRepository: PostsRepositoryProtocol {
    func getLatestPosts() async throws -> [Diver.PostInfo] {
        throw Failure(#function)
    }
    
    func getEarlierPosts() async throws -> [Diver.PostInfo] {
        throw Failure(#function)
    }
    
    func getReplies(for post: Diver.PostInfo) async throws -> [Diver.PostInfo] {
        throw Failure(#function)
    }
}
