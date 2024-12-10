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
        try await expect("It should get the timeline") {
            subject.getLatestPosts()
        } toChange: {
            _ = subject.timeline
        }
        XCTAssertEqual(12, subject.timeline.count)
    }

    @MainActor func testItGetsEarlierPosts() async throws {
        let repo = MockPostsRepository()
        let subject = Posts(repo: repo)
        // Manually set the timeline to the latest posts.
        subject.timeline = try await repo.getLatestPosts()
        try await expect("It should get earlier posts") {
            subject.getEarlierPosts()
        } toChange: {
            _ = subject.timeline
        }
        XCTAssertEqual(24, subject.timeline.count)
    }

    @MainActor func testItGetsContextForPost() async throws {
        let repo = MockPostsRepository()
        let subject = Posts(repo: repo)
        let post = PostInfo.mock()
        try await expect("It should get context for a post") {
            subject.getContext(for: post)
        } toChange: {
            _ = subject.threads
        }
        XCTAssertEqual(12, subject.threads[post.id]?.count)
    }

    @MainActor func testGetTimelineRaisesErrorOnFailure() async throws {
        let repo = FailingMockPostsRepository()
        let subject = Posts(repo: repo)
        try await expect("It should fail to get the timeline") {
            subject.getLatestPosts()
        } toChange: {
            _ = subject.failure
        }
        XCTAssertNotNil(subject.failure)
    }

    @MainActor func testGetEarlierPostsRaisesErrorOnFailure() async throws {
        let repo = FailingMockPostsRepository()
        let subject = Posts(repo: repo)
        try await expect("It should fail to get earlier posts") {
            subject.getEarlierPosts()
        } toChange: {
            _ = subject.failure
        }
        XCTAssertNotNil(subject.failure)
    }

    @MainActor func testGetContextForPostRaisesErrorOnFailure() async throws {
        let repo = FailingMockPostsRepository()
        let subject = Posts(repo: repo)
        try await expect("It should fail to get context for a post") {
            subject.getContext(for: .mock())
        } toChange: {
            _ = subject.failure
        }
        XCTAssertNotNil(subject.failure)
    }

    @MainActor func testDeletePostRaisesErrorOnFailure() async throws {
        let repo = FailingMockPostsRepository()
        let subject = Posts(repo: repo)
        try await expect("It should fail to get context for a post") {
            subject.delete(PostInfo.mock().id)
        } toChange: {
            _ = subject.failure
        }
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

    func getPost(_ id: Diver.PostInfo.ID) async throws -> Diver.PostInfo {
        throw Failure(#function)
    }

    func getContext(for post: Diver.PostInfo) async throws -> [Diver.PostInfo] {
        throw Failure(#function)
    }

    func send(_ text: String, media: [Data], replyingTo originalPost: Diver.PostInfo?) async throws -> Diver.PostInfo {
        throw Failure(#function)
    }

    func delete(_ id: Diver.PostInfo.ID) async throws -> Diver.PostInfo {
        throw Failure(#function)
    }

    func boost(_ post: Diver.PostInfo) async throws -> Diver.PostInfo {
        throw Failure(#function)
    }

    func removeBoost(_ post: Diver.PostInfo) async throws -> Diver.PostInfo {
        throw Failure(#function)
    }

    func favorite(_ post: Diver.PostInfo) async throws -> Diver.PostInfo {
        throw Failure(#function)
    }

    func removeFavorite(_ post: Diver.PostInfo) async throws -> Diver.PostInfo {
        throw Failure(#function)
    }
}
