//
//  DiverApp.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI
import TootSDK

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
@main struct DiverApp: App {
    /// Allows the application to use UIApplicationDelegate callbacks for monitoring lifecycle events, remote notifications, etc.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    /// A repository for accessing content.
    private var postsRepository: PostsRepositoryProtocol {
        if CommandLine.arguments.contains("ui-testing") {
            /// For UI tests, use a mock repository.
            return MockPostsRepository()
        } else {
            /// For live runs of the application, use a repository that accesses content via TootClient.
            let client = TootClient(
                instanceURL: instanceURL,
                accessToken: accessToken
            )
            return PostsRepository(client: client)
        }
    }

    var body: some Scene {
        /// A source of truth for the view.
        let postsController = Posts(repo: postsRepository)
        /// A source of truth for navigation state.
        let navigator = Navigator(postsController: postsController)
        /// The actual content.
        WindowGroup {
            ContentView()
                // Add required observables to the environment.
                .environment(postsController)
                .environment(navigator)
                .environment(appDelegate.notifications)
                // Register a deep link handler.
                .onOpenURL { url in
                    navigator.deepLink(url)
                }
        }
    }
}
