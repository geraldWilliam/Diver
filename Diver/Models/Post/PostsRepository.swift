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
    /// Send a post.
    func send(_ text: String, media: [Data], replyingTo originalPost: PostInfo?) async throws -> PostInfo
    /// Delete a post.
    func delete(_ id: PostInfo.ID) async throws -> PostInfo
    /// Boost a post.
    func boost(_ post: PostInfo) async throws -> PostInfo
    /// Undo a boost of a post.
    func removeBoost(_ post: PostInfo) async throws -> PostInfo
    /// Favorite a post.
    func favorite(_ post: PostInfo) async throws -> PostInfo
    /// Undo a favorite of a post.
    func removeFavorite(_ post: PostInfo) async throws -> PostInfo
}

// MARK: - Concrete Implementation

final class PostsRepository: PostsRepositoryProtocol {

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

    func send(_ text: String, media: [Data], replyingTo originalPost: PostInfo?) async throws -> PostInfo {
        var attachments: [UploadedMediaAttachment] = []
        for data in media {
            let upload = UploadMediaAttachmentParams(file: data)
            attachments.append(try await client.uploadMedia(upload, mimeType: "image/jpeg"))
        }
        // TODO: Enable all of these parameters.
        let params = PostParams(
            post: text,
            mediaIds: attachments.map(\.id),
            poll: nil,
            inReplyToId: nil,
            sensitive: false,
            spoilerText: nil,
            visibility: .public,
            language: "en",
            contentType: nil,
            inReplyToConversationId: nil
        )
        let response = try await client.publishPost(params)
        return PostInfo(post: response)
    }

    private func fetchPosts() async throws -> [PostInfo] {
        let pageInfo = PagedInfo(maxId: earliestPost)
        let posts = try await client.getTimeline(.home, pageInfo: pageInfo)
        earliestPost = posts.previousPage?.maxId
        return posts.result.map { PostInfo(post: $0) }
    }
    
    func delete(_ id: PostInfo.ID) async throws -> PostInfo {
        let post = try await client.deletePost(id: id)
        return PostInfo(post: post)
    }
    
    func boost(_ post: PostInfo) async throws -> PostInfo {
        let response = try await client.boostPost(id: post.id)
        return PostInfo(post: response)
    }
    
    func removeBoost(_ post: PostInfo) async throws -> PostInfo {
        var response = try await client.unboostPost(id: post.id)
        if let reposted = response.reposted, reposted == true {
            // GoToSocial isn't responding with the un-boosted post. Try again.
            response = try await client.unboostPost(id: post.id)
        }
        return PostInfo(post: response)
    }
    
    func favorite(_ post: PostInfo) async throws -> PostInfo {
        let response = try await client.favouritePost(id: post.id)
        return PostInfo(post: response)
    }
    
    func removeFavorite(_ post: PostInfo) async throws -> PostInfo {
        let response = try await client.unfavouritePost(id: post.id)
        return PostInfo(post: response)
    }
}

// MARK: - Mock Implementation

// periphery:ignore
struct MockPostsRepository: PostsRepositoryProtocol {
    func getLatestPosts() async throws -> [PostInfo] {
        return (0..<12).map { _ in
            .mock()
        }
    }

    func getReplies(for post: PostInfo) async throws -> [PostInfo] {
        return (0..<12).map { _ in
            .mock()
        }
    }

    func getEarlierPosts() async throws -> [PostInfo] {
        return (0..<12).map { _ in
            .mock()
        }
    }

    func send(_ text: String, media: [Data], replyingTo originalPost: PostInfo?) async throws -> PostInfo {
        return .mock()
    }
    
    func delete(_ id: PostInfo.ID) async throws -> PostInfo {
        return .mock()
    }
    
    func boost(_ post: PostInfo) async throws -> PostInfo {
        return .mock()
    }
    
    func removeBoost(_ post: PostInfo) async throws -> PostInfo {
        return .mock()
    }
    
    func favorite(_ post: PostInfo) async throws -> PostInfo {
        return .mock()
    }
    
    func removeFavorite(_ post: PostInfo) async throws -> PostInfo {
        return .mock()
    }
}
