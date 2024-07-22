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
    
    struct NotificationCategory {
        static let deepLink = "DEEP_LINK"
    }
    
    private let notificationCenter: UNUserNotificationCenter = .current()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        // TODO: This shouldn't happen on launch.
        requestNotificationPermission()
        return true
    }
    
    override init() {
        super.init()
        notificationCenter.delegate = self
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
    
    private func navigate(for content: UNNotificationContent) {
        guard let entry = content.userInfo["url"] as? String, let url = URL(string: entry) else {
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// This function allows us to view notifications in the app even with it in the foreground.
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
    
    /// This function lets us do something when the user interacts with a notification, like log that they clicked it, or navigate to a specific screen.
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
}
