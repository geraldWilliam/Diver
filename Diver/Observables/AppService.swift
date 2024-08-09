//
//  AppService.swift
//  Diver
//
//  Created by Gerald Burke on 7/31/24.
//

import Foundation
import TootSDK

/// This struct is a container and coordinator for the app‘s observables. It is annotated @MainActor because it instantiates and accesses types isolated to the main actor.
///
// TODO: Consider best location for global values.
/// I am undecided whether to just make this stuff part of the DiverApp declaration. There‘s no real reason that the app file has to be super-short. We could just decide
/// that‘s where global dependencies are instantiated and injected...
///
@MainActor struct AppService {
    /// A source of truth for the session, including authentication status.
    var session: Session
    /// A source of truth for timeline, post detail, and compose.
    var posts: Posts
    /// A source of truth for navigation state.
    var navigator: Navigator
    /// A provider for the client instance.
    private let client = TootClient(instanceURL: instanceURL, accessToken: TokenService.shared.token)
    
    // MARK: - Initialization
    
    init() {
        /// Initialization uses mocks for UI tests.
        let isTesting = CommandLine.arguments.contains("ui-testing")
        
        /// A container for repositories to populate observables.
        struct Repositories {
            let session: SessionRepositoryProtocol
            let posts: PostsRepositoryProtocol
        }
        
        /// Set up repositories for instantiating observables.
        let repos: Repositories = if isTesting {
            /// Test runs use mock repositories.
            Repositories(
                session: MockSessionRepository(),
                posts: MockPostsRepository()
            )
        } else {
            /// Live runs use real repositories that leverage the client.
            Repositories(
                session: SessionRepository(client: client),
                posts: PostsRepository(client: client)
            )
        }

        session = Session(repo: repos.session)
        posts = Posts(repo: repos.posts)
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
            // Track the session‘s logged in state.
            _ = session.isLoggedIn
        } onChange: {
            Task {
                if await session.isLoggedIn {
                    // User is authenticated, get content.
                    await posts.getLatestPosts()
                }
                // Keep observing changes to `session.isLoggedIn`.
                await observeSession()
            }
        }
    }
}
