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
// TODO: AppDelegate
@main struct DiverApp: App {
    var body: some Scene {
        let appController = AppController()
        let navigator = Navigator(appController: appController)
        WindowGroup {
            ContentView()
                .environment(appController.postsController)
                .environment(navigator)
        }
    }
}
