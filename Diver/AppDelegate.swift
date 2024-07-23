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
    /// Type-safe declarations of category identifiers for notifications. Remote notifications may use these one of these values for the "category" key.
    struct NotificationCategory {
        static let deepLink = "DEEP_LINK"
    }

    private let notificationCenter: UNUserNotificationCenter = .current()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        /// Handle any UI-test specific requirements for app setup.
        if CommandLine.arguments.contains("testing") {
            /// Speed up UI tests by disabling animations.
            UIView.setAnimationsEnabled(false)
        }
        /// UNUserNotificationCenter‘s delegate must be set before the application finishes launching.
        /// https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/delegate
        notificationCenter.delegate = self
        // TODO: This shouldn't happen on launch.
        requestNotificationPermission()
        return true
    }

    func requestNotificationPermission() {
        Task {
            do {
                try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            } catch {
                // TODO: Actually handle this error, probably by throwing it.
                print("Request authorization error")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// This allows us to view notifications while the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let state = UIApplication.shared.applicationState
        let category = notification.request.content.categoryIdentifier

        let options: UNNotificationPresentationOptions = switch state {
        case .active where category == NotificationCategory.deepLink, .inactive, .background:
            [.list, .badge, .banner]
        case .active:
            [.list, .badge]
        @unknown default:
            [.sound, .badge, .banner]
        }
        completionHandler(options)
    }

    /// This lets us respond when the user interacts with a notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let content = response.notification.request.content
        switch content.categoryIdentifier {
        case NotificationCategory.deepLink:
            navigate(for: content)
        default:
            break
        }
        completionHandler()
    }
    
    /// A helper to parse the deep link URL from a notification and route to it.
    ///
    /// - Parameter content: The notification's content.
    private func navigate(for content: UNNotificationContent) {
        guard let entry = content.userInfo["url"] as? String, let url = URL(string: entry) else {
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
}
