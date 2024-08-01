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
@main struct DiverApp: App {
    /// Allows the application to use UIApplicationDelegate callbacks for monitoring lifecycle events, remote notifications, etc.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    /// A container for the app‘s dependencies.
    let service = AppService()

    var body: some Scene {
        /// The actual content.
        WindowGroup {
            /// The root view of the application.
            ContentView()
                // Add required observables to the environment.
                .environment(service.session)
                .environment(service.posts)
                .environment(service.navigator)
                .environment(appDelegate.notifications)
                // Register a deep link handler.
                .onOpenURL { url in
                    service.navigator.deepLink(url)
                }
        }
    }
}
