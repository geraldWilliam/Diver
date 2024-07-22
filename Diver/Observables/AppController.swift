//
//  AppController.swift
//  Diver
//
//  Created by Gerald Burke on 7/19/24.
//

import Foundation
import TootSDK

/// This type is responsible for providing instances of other controllers.
@MainActor @Observable class AppController {
    /// The external fediverse client.
    // TODO: We can‘t mock this dependency. Is that a problem? Yes, for UI tests.
    private let client = TootClient(
        instanceURL: instanceURL,
        accessToken: accessToken
    )
    /// A repository to share between PostsController and PostDetailController.
    let postsRepository: PostsRepository
    /// This controller populates the Timeline.
    var postsController: PostsController

    init() {
        postsRepository = PostsRepository(client: client)
        postsController = PostsController(repo: postsRepository)
    }

    /// A source of truth for the PostDetailView.
    /// - Parameter post: The post to display in the detail view.
    /// - Returns: An instance of PostDetailController.
    func postDetailController(for post: PostInfo) -> PostDetailController {
        return PostDetailController(repo: postsRepository)
    }
}
