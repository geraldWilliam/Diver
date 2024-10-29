//
//  DiverApp.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

/// The entry point of the application. Keep this file brief. The App should perform the following tasks:
///
/// - Instantiate global services.
/// - Inject global observables.
/// - Create an AppDelegate if needed.
///
/// Any user interface setup should happen in `ContentView`.
///
/// A note on Environment: Use the environment to inject dependencies that are needed more than one step into the parent-child view hierarchy. The Timeline
/// presented in ContentView‘s body needs a `Posts`. Rather than passing it to ContentView and then forwarding it to the Timeline, we put it in the
/// environment.
///
/// Orchestrating Observables:
///
import TootSDK

@main struct DiverApp: App {
    /// Allows the application to use UIApplicationDelegate callbacks for monitoring lifecycle events, remote notifications, etc.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    /// A source of truth for the session, including authentication status.
    var session: Session
    /// A source of truth for timeline, post detail, and compose.
    var posts: Posts
    /// A source of truth for accounts to explore, follow, etc.
    var authors: Authors
    /// A source of truth for navigation state.
    var navigator: Navigator
    /// A provider for the client instance.
    private let client: TootClient

    // MARK: - Initialization

    init() {
        /// A service for caching the access token to the keychain.
        let tokenService = TokenService()
        ///
        let accountService = AccountService()
        /// Initialize the client.
        client = TootClient(instanceURL: instanceURL, accessToken: tokenService.token)
        /// Initialization uses mocks for UI tests.
        let isTesting = CommandLine.arguments.contains("ui-testing")
        /// A container type for the application‘s repositories.
        typealias Repos = (
            session: SessionRepositoryProtocol,
            posts: PostsRepositoryProtocol,
            accounts: AccountRepositoryProtocol
        )
        /// Set up repositories for instantiating observables. Test runs use mock repositories, live runs use real repositories that leverage the client.
        let repos: Repos = (
            session: isTesting
            ? MockSessionRepository()
            : SessionRepository(client: client, tokenService: tokenService, accountService: accountService),
            posts: isTesting
            ? MockPostsRepository()
            : PostsRepository(client: client),
            accounts: isTesting
            ? MockAccountRepository()
            : AccountRepository(client: client, accountService: accountService)
        )
        /// Instantiate observables to be injected in Environment.
        session = Session(repo: repos.session)
        posts = Posts(repo: repos.posts)
        authors = Authors(repo: repos.accounts)
        navigator = Navigator(posts: posts)
        /// Handle initial authentication state. See ContentView.swift for initial UI state based on `isLoggedIn`.
        if session.isLoggedIn {
            /// Get initial content.
            posts.getLatestPosts()
        } else {
            /// Not yet logged in. Observe session to fetch posts when authentication is complete.
            observeSession()
        }
    }

    var body: some Scene {
        /// The actual content.
        WindowGroup {
            /// The root view of the application.
            ContentView()
                /// Add required observables to the environment.
                .environment(session)
                .environment(posts)
                .environment(authors)
                .environment(navigator)
                .environment(appDelegate.notifications)
                // Register a deep link handler.
                .onOpenURL { url in
                    navigator.deepLink(url)
                }
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
