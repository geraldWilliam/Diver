//
//  Notifications.swift
//  Diver
//
//  Created by Gerald Burke on 7/24/24.
//

import UIKit

@Observable class Notifications: NSObject, UNUserNotificationCenterDelegate {

    /// Type-safe declarations of category identifiers for notifications. Remote notifications may use these one of these values for the "category" key.
    struct NotificationCategory {
        static let deepLink = "DEEP_LINK"
    }

    var canRequestAuthorization: Bool = false

    var failure: Failure?

    private let app: UIApplication

    private let notificationCenter: UNUserNotificationCenter = .current()

    init(app: UIApplication) {
        self.app = app
        super.init()
        notificationCenter.delegate = self
        Task {
            await checkAuthorizationStatus()
        }
    }

    func requestAuthorization() {
        Task {
            do {
                try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
                await checkAuthorizationStatus()
            } catch {
                failure = Failure(error)
            }
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        canRequestAuthorization = settings.authorizationStatus == .notDetermined
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// This allows us to view notifications while the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let state = app.applicationState
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
        app.open(url, options: [:])
    }
}
