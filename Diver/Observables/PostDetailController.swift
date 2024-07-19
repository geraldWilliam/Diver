//
//  PostDetailController.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import Foundation

/// This is a member of the “Observable“ layer.
///
/// For details on the type‘s annotations, see PostsController.
@MainActor @Observable final class PostDetailController {
    /// Replies to the post. This should be displayed as a list below a post in the detail view.
    var replies: [PostInfo] = []
    /// An error, wrapped in a Failure. See `Failure.swift` for more details.
    var failure: Failure?
    /// The repository used to fetch replies.
    private let repo: PostsRepositoryProtocol
    
    // MARK: - Initialization
    
    init(repo: PostsRepositoryProtocol) {
        self.repo = repo
    }
    
    // MARK: - Methods

    func getReplies(for post: PostInfo) {
        Task {
            do {
               replies  = try await repo.getReplies(for: post)
            } catch {
                failure = Failure(error)
            }
        }
    }
}
