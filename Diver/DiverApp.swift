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
/// A note on Environment: Use the environment to inject dependencies that are needed more than one
/// step into the parent-child view hierarchy. The FeedView presented in ContentView‘s body needs a
/// `Posts`. Rather than passing it to ContentView and then forwarding it to the FeedView, we put it
/// in the environment.
///
/// Orchestrating Observables:
///

@main struct DiverApp: App {
    /// Allows the application to use UIApplicationDelegate callbacks for monitoring lifecycle events, remote notifications, etc.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    /// A service to wrap the client instance. Trying to work out how best to share this state.
    var clientService: ClientService
    /// A source of truth for the session, including authentication status.
    var session: Session
    /// A source of truth for the feed, post detail, and compose.
    var posts: Posts
    /// A source of truth for accounts to explore, follow, etc.
    var accounts: Accounts
    /// A source of truth for navigation state.
    var navigator: Navigator
    /// An animation namespace for showing images in a zoomable overlay.
    @Namespace var zoomAnimation

    // MARK: - Initialization

    init() {
        clientService = ClientService()
        /// A service for caching the access token to the keychain.
        let tokenService = TokenService()
        /// A service for managing accounts.
        let accountService = AccountService()
        /// Initialization uses mocks for UI tests.
        let isTesting = CommandLine.arguments.contains("ui-testing")

        /// Instantiate observables to be injected in Environment.
        session = Session(
            repo: isTesting
                ? MockSessionRepository()
                : SessionRepository(clientService: clientService, tokenService: tokenService)
        )
        posts = Posts(
            repo: isTesting
                ? MockPostsRepository()
                : PostsRepository(clientService: clientService)
        )
        accounts = Accounts(
            repo: isTesting
                ? MockAccountRepository()
                : AccountRepository(clientService: clientService, accountService: accountService)
        )

        navigator = Navigator(posts: posts)
        
        // TODO: Consider moving this to a different location. ContentView? Maybe Posts should have a ref to session?
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
                .environment(accounts)
                .environment(navigator)
                .environment(Zoom(animation: zoomAnimation))
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
                if let current = await session.currentSession, await session.isLoggedIn {
                    try await clientService.updateSession(current)
                    // User is authenticated, get content.
                    await posts.getLatestPosts()
                }
                if await session.isLoggedIn == false {
                    await posts.clearFeed()
                }
                // Keep observing changes to `session.isLoggedIn`.
                await observeSession()
            }
        }
    }
}
