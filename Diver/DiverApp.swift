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
/// presented in ContentView‘s body needs a `PostsController`. Rather than passing the controller to ContentView and then forwarding it to the Timeline, we
/// put it in the environment.
// TODO: AppDelegate
@main struct DiverApp: App {
    /// Allows the application to use UIApplicationDelegate callbacks for monitoring lifecycle events, remote notifications, etc.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        let appController = AppController()
        let navigator = Navigator(appController: appController)
        WindowGroup {
            ContentView()
                // Add required observables to the environment.
                .environment(appController.postsController)
                .environment(navigator)
                // Register a deep link handler.
                .onOpenURL { url in
                    navigator.deepLink(url)
                }
        }
    }
}
