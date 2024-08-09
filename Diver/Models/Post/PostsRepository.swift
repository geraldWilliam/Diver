//
//  PostsRepository.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import Foundation
import TootSDK

// MARK: - Protocol

/// The repository provides a protocol that declares its interface. Observables that depend on the repository should use the protocol so the dependency can be
/// satisfied by a mock repository in tests and previews.
protocol PostsRepositoryProtocol {
    /// Get the latest posts in the timeline.
    func getLatestPosts() async throws -> [PostInfo]
    /// Get a page of earlier posts in the timeline.
    func getEarlierPosts() async throws -> [PostInfo]
    /// Get the replies to a post.
    func getReplies(for post: PostInfo) async throws -> [PostInfo]
    /// Send a simple text post with public visibility.
    func send(_ text: String) async throws -> PostInfo
}

// MARK: - Concrete Implementation

actor PostsRepository: PostsRepositoryProtocol {
    
    let client: TootClient

    private var earliestPost: String?
    
    init(client: TootClient) {
        self.client = client
    }

    func getLatestPosts() async throws -> [PostInfo] {
        earliestPost = nil
        return try await fetchPosts()
    }

    func getEarlierPosts() async throws -> [PostInfo] {
        return try await fetchPosts()
    }

    func getReplies(for post: PostInfo) async throws -> [PostInfo] {
        return try await client.getContext(id: post.id).descendants.map { PostInfo(post: $0) }
    }
    
    func send(_ text: String) async throws -> PostInfo {
        let response = try await client.publishPost(PostParams(post: text, visibility: .public))
        return PostInfo(post: response)
    }

    private func fetchPosts() async throws -> [PostInfo] {
        let pageInfo = PagedInfo(maxId: earliestPost)
        let posts = try await client.getTimeline(.home, pageInfo: pageInfo)
        earliestPost = posts.previousPage?.maxId
        return posts.result.map { PostInfo(post: $0) }
    }
}

// MARK: - Mock Implementation

struct MockPostsRepository: PostsRepositoryProtocol {

    func getLatestPosts() async throws -> [PostInfo] {
        return (0..<12).map { _ in
            PostInfo.mock()
        }
    }

    func getReplies(for post: PostInfo) async throws -> [PostInfo] {
        return (0..<12).map { _ in
            PostInfo.mock()
        }
    }

    func getEarlierPosts() async throws -> [PostInfo] {
        return (0..<12).map { _ in
            PostInfo.mock()
        }
    }
    
    func send(_ text: String) async throws -> PostInfo {
        return .mock()
    }
}
