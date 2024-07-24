//
//  PostRepository.swift
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
    /// Get the first page of the timeline.
    // TODO: Can I just remove this and use getNextPage?
    func getPosts() async throws -> [PostInfo]
    /// Get the next page of the timeline.
    func getNextPage() async throws -> [PostInfo]
    /// Get the replies to a post.
    func getReplies(for post: PostInfo) async throws -> [PostInfo]
}

// MARK: - Concrete Implementation

actor PostsRepository: PostsRepositoryProtocol {
    /// `PostsRepository` has a direct dependency on the TootClient package. The package does not need to be mockable. The repository _is_ the
    /// mockable interface by which the application accesses this package.
    let client: TootClient

    init(client: TootClient) {
        self.client = client
    }

    func getPosts() async throws -> [PostInfo] {
        try await client.getTimeline(.home).result.map { PostInfo(post: $0) }
    }

    func getReplies(for post: PostInfo) async throws -> [PostInfo] {
        try await client.getContext(id: post.id).descendants.map { PostInfo(post: $0) }
    }

    func getNextPage() async throws -> [PostInfo] {
        let nextPage = try await client.getTimeline(.home).previousPage
        return try await client.getTimeline(.home, pageInfo: nextPage).result.map { PostInfo(post: $0) }
    }
}

// MARK: - Mock Implementation

struct MockPostsRepository: PostsRepositoryProtocol {

    func getPosts() async throws -> [PostInfo] {
        return (0..<12).map { _ in
            PostInfo.mock()
        }
    }

    func getReplies(for post: PostInfo) async throws -> [PostInfo] {
        return (0..<12).map { _ in
            PostInfo.mock()
        }
    }

    func getNextPage() async throws -> [PostInfo] {
        return (0..<12).map { _ in
            PostInfo.mock()
        }
    }
}
