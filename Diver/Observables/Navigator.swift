//
//  Navigator.swift
//  Diver
//
//  Created by Gerald Burke on 7/19/24.
//

import SwiftUI // I wish I didn‘t have to import SwiftUI here but I need the NavigationPath.

/// This is an Observable class that centralizes navigation logic.
///
/// - Defines valid navigation destinations.
/// - Provides a NavigationPath to which NavigationStack should bind.
/// - Exposes a method to construct views for destinations.
///
/// See how we bind the path and use the view construction method in ContentView.swift.
///
@MainActor @Observable final class Navigator {
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
    }

    /// Use Modal values to prompt sheet presentations. This strategy allows us to centralize management of sheets. See `content(for modal:)`.
    enum Modal: String, Identifiable {
        var id: String { rawValue }
        case postComposer
    }
    
    /// Required for executing deep link navigation.
    let posts: Posts

    /// Instantiate your NavigationStack with this path.
    var path = NavigationPath()

    /// Assign a value to this property to present a modal. Pass a binding to this property to the `sheet` modifier on the app‘s root view.
    var modal: Modal?

    // MARK: - Initialization

    init(posts: Posts) {
        self.posts = posts
    }

    // MARK: - Navigation

    /// Use this method to prompt navigation without using a NavigationLink.
    ///
    /// - Parameter destination: The destination view of the transition.
    func go(to destination: Destination) {
        path.append(destination)
    }

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
            }
        }
    }

    func content(for modal: Modal) -> some View {
        Group {
            switch modal {
            case .postComposer:
                Text("Write a post!")
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
            if let first = posts.timeline.first {
                go(to: .postDetail(first))
            }
        default:
            break
        }
    }
}
