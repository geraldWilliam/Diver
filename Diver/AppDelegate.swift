//
//  AppDelegate.swift
//  Diver
//
//  Created by Gerald Burke on 7/19/24.
//

import UIKit

/// An AppDelegate class. Here, you can implement application lifecycle hooks just like you would in UIApplicationDelegate. In this example, the class implements
/// `application(_:didFinishLaunchingWithOptions:)` and handles push notifications.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    /// Internally, Notifications sets the delegate for UNUserNotificationCenter. This assignment must occur before the app finishes launching.
    /// The app injects this Notifications instance into SwiftUI's environment in DiverApp.swift.
    var notifications: Notifications!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        /// Handle any UI-test specific requirements for app setup.
        if CommandLine.arguments.contains("testing") {
            /// Speed up UI tests by disabling animations.
            UIView.setAnimationsEnabled(false)
        }
        notifications = Notifications(app: application)
        return true
    }
}
