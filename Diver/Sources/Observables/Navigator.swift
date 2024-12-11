//
//  Navigator.swift
//  Diver
//
//  Created by Gerald Burke on 7/19/24.
//

import SwiftUI

/// This is an Observable class that centralizes navigation logic.
///
/// - Defines valid navigation destinations.
/// - Provides NavigationPaths to which NavigationStacks should bind. See FeedNav.swift and ProfileNav.swift for usage.
/// - Provides tracking of tab selection to which TabView should bind. See ContentView.swift for usage.
/// - Exposes a method to construct views for destinations. See FeedNav.swift and ProfileNav.swift for usage.
///
@MainActor @Observable final class Navigator {

    /// Tabs of the application. ContentView is the root of the UI and if the person using the app is authenticated it shows a tabbed interface. List each tab here.
    enum Tab {
        case feed
        case profile
        case explore
    }

    /// Use Destination values to drive transitions. This strategy allows us to centralize instantiation of navigation destinations here in Navigator.
    /// See `content(for destination:)`. Establishing a convention of using `Navigator.Destination` values also improves clarity at the call site.
    ///
    /// In a NavigationLink:
    ///
    ///     NavigationLink(value: Navigator.Destination.postDetail(post)) { /* The NavigationLink's Label */ }
    ///
    /// In a Button action:
    ///
    ///     Button(action: { navigator.go(to: .postDetail(post) }) { /* The Button's Label */ }
    ///
    enum Destination: Hashable {
        case postDetail(PostInfo)
        case profile(AccountInfo)
        /// Restrict a destination to a certain tab. This prevents push transitions to the destination in all but the associated tab. You could omit this if destinations
        /// are reachable from all tabs. To permit navigation to your destination from a subset of tabs, make this property a collection.
        /// In `go(to destination:)` this property is examined and the Navigator‘s `tabSelection` property is set to the associated tab before pushing
        /// the view for the destination onto the stack.
        var tab: Tab {
            switch self {
            case .postDetail:
                .feed
            case .profile:
                .explore
            }
        }
    }

    /// Use Modal values to prompt sheet presentations. This strategy allows us to centralize management of sheets. See `content(for modal:)`.
    /// Identifiable conformance is required by the `sheet` modifier.
    enum Modal: Identifiable {
        var id: String {
            switch self {
            case .postComposer:
                "postComposer"
            }
        }
        case postComposer(post: PostInfo?)
    }

    /// Required for executing deep link navigation.
    let posts: Posts
    /// Instantiate your TabView with this selection value.
    var tabSelection: Tab = .feed
    /// Instantiate the NavigationStack in the Feed tab with this path.
    var feedPath = NavigationPath()
    /// Instantiate the NavigationStack in the Profile tab with this path.
    var profilePath = NavigationPath()
    /// Instantiate the NavigationStack in the Explore tab with this path.
    var explorePath = NavigationPath()
    /// Assign a value to this property to present a modal. Pass a binding to this property to the `sheet` modifier on the app‘s root view.
    var modal: Modal?

    // MARK: - Initialization

    init(posts: Posts) {
        self.posts = posts
    }

    // MARK: - Navigation

    /// Use this method to prompt navigation without using a NavigationLink.
    ///
    /// - Parameter destination: The destination of the transition.
    func go(to destination: Destination) {
        /// Make sure the right tab is selected. If a destination‘s tab is optional in your implementation, fall back on the current `tabSelection` here.
        tabSelection = destination.tab
        /// Navigate to the destination.
        switch destination.tab {
        case .feed:
            feedPath.append(destination)
        case .profile:
            profilePath.append(destination)
        case .explore:
            explorePath.append(destination)
        }
    }

    /// Use this method to show a sheet presentation.
    ///
    /// - Parameter modal: The destination to display in the sheet.
    func present(_ modal: Modal) {
        self.modal = modal
    }

    /// Get the content view for a navigation destination. This strategy keeps complex view instantiation out of layout code.
    ///
    /// - Parameter destination: The destination of the navigation event.
    /// - Returns: The view to be displayed by the navigation event.
    func content(for destination: Destination) -> some View {
        /// Wrap the content in a Group because the compiler won‘t allow us to return different types per case and we don‘t want an AnyView return type.
        Group {
            switch destination {
            case .postDetail(let post):
                /// This is a simple example but here you might access a service and instantiate any required initialization values for a view.
                PostDetailView(post: post.boost ?? post)
            case .profile(let account):
                ProfileView(account: account)
            }
        }
    }

    /// Get the content view for a modal presentation. This strategy keeps complex view instantiation out of layout code.
    ///
    /// - Parameter modal: The destination of the modal presentation.
    /// - Returns: The view to be displayed in the modal presentation.
    func content(for modal: Modal) -> some View {
        Group {
            switch modal {
            case .postComposer(let post):
                PostComposer(post: post)
            }
        }
    }

    /// Handle a deep link. Attach the `onOpenURL` modifier to the root view of the application. In this example project, I attach the modifier in the `body` of
    /// DiverApp because that‘s the earliest point at which I have a reference to the Navigator. In the `onOpenURL` modifier, pass the received URL to this
    /// method.
    ///
    /// - Parameter value: The deep link value indicating the navigation to perform.
    func deepLink(_ value: URL) {
        switch value.lastPathComponent {
        /// The example deep link just takes us to the first post.
        case "first_post":
            if let first = posts.feed.first {
                go(to: .postDetail(first))
            }
        default:
            break
        }
    }
}
