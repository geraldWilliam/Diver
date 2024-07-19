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
/// Modal presentations are not managed by this class.
// TODO: Can we make modals work with this?
@MainActor @Observable final class Navigator {
    /// Use Destination values to drive transitions.
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
    
    /// Instantiate your NavigationStack with this path.
    var path = NavigationPath()
    
    /// The AppController provides other controllers that the Navigator can use to set up content view for destinations.
    private let appController: AppController

    init(appController: AppController) {
        self.appController = appController
    }
    
    /// Use this method to prompt navigation without using a NavigationLink.
    ///
    /// - Parameter destination: The destination view of the transition.
    func go(to destination: Destination) {
        path.append(destination)
    }
    
    /// Get the content view for a navigation destination. This strategy keeps controller instantiation out of views. The Navigator requests a controller from the
    /// AppController and creates a view for the destination.
    ///
    /// - Parameter destination: The destination of the navigation event.
    /// - Returns: The view to be displayed by the navigation event.
    func content(for destination: Destination) -> some View {
        /// Wrap the content in a Group because the compiler won‘t allow us to return different types per case and we don‘t want an AnyView return type.
        Group {
            switch destination {
            case .postDetail(let post):
                let post = post.boost ?? post
                let controller = appController.postDetailController(for: post)
                PostDetailView(postDetailController: controller, post: post)
            }
        }
    }
    
    /// Handle a deep link from AppDelegate.
    /// 
    /// - Parameter value: The deep link value indicating the navigation to perform.
    func deepLink(_ value: String) {
        /// Implementation here depends entirely on how you have deep links set up. This assumes a simple string value. This shows how useful the Navigator
        /// type is: since we already create views in `content(for destination:)`, we already have access to the services and controllers we need.
        switch value {
        case "first_post":
            if let first = appController.postsController.posts.first {
                go(to: .postDetail(first))
            }
        default:
            break
        }
    }
}
