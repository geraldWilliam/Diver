//
//  AppService.swift
//  Diver
//
//  Created by Gerald Burke on 7/31/24.
//

import Foundation
import TootSDK

/// This struct is a container and coordinator for the app‘s observables. It is annotated @MainActor because it instantiates and accesses types isolated to the main actor.
@MainActor struct AppService {
    /// A source of truth for the session, including authentication status.
    private var session: Session
    /// A source of truth for timeline, post detail, and compose.
    private var posts: Posts
    /// A source of truth for navigation state.
    private var navigator: Navigator
    /// A provider for the client instance.
    private let client = TootClient(instanceURL: instanceURL, accessToken: TokenService.shared.token)
    
    // MARK: - Initialization
    
    init() {
        let isTesting = CommandLine.arguments.contains("ui-testing")

        let sessionRepo: SessionRepositoryProtocol = if isTesting {
            MockSessionRepository()
        } else {
            SessionRepository(client: client)
        }
        session = Session(repo: sessionRepo)

        let postsRepo: PostsRepositoryProtocol = if isTesting {
            /// For UI tests, use a mock repository.
            MockPostsRepository()
        } else {
            /// For app runs, use a real PostsRepository.
            PostsRepository(client: client)
        }
        posts = Posts(repo: postsRepo)
        
        navigator = Navigator(posts: posts)

        if session.isLoggedIn {
            // Get initial content.
            posts.getLatestPosts()
        } else {
            // Not yet logged in. Observe session to fetch posts when authentication is complete.
            observeSession()
        }
    }
    
    // MARK: - Private
    
    private func observeSession() {
        withObservationTracking {
            _ = session.isLoggedIn
        } onChange: {
            Task {
                if await session.isLoggedIn == false {
                    await observeSession()
                } else {
                    await posts.getLatestPosts()
                }
            }
        }
    }
}
