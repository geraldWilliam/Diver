//
//  PostsController.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import Foundation

/// This is a member of the “Observable“ layer.
///
/// In your application, you might use a Controller, a View Model, a Presenter, a Store, or any other concept that makes sense for your circumstance. However you
/// conceptualize the members of this layer, they must meet the requirements of a Source of Truth for the view layer.
///
/// @MainActor
/// Since the view observes the properties of this type, changes to those properties should be published on the main actor.
///
/// @Observable
/// This macro implements conformance to the `Observable` protocol so changes to properties emit notifications.
///
/// final
/// This type is marked final simply to indicate that it is not intended for subclassing.
@MainActor @Observable final class PostsController {
    /// The posts to be displayed. Note, we use a domain-specific model here instead of the external `Post` model provided by TootSDK.
    var posts: [PostInfo] = []
    /// A boolean to indicate whether an error should be displayed.
    var showingError: Bool = false
    /// An error, wrapped in a Failure. See `Failure.swift` for more details.
    var failure: Failure?
    /// The repository used to fetch posts.
    private let repo: PostsRepositoryProtocol
    
    // MARK: - Initialization
    
    init(repo: PostsRepositoryProtocol) {
        self.repo = repo
        /// Monitor the `failure` property to update the `showingError` flag.
        observeFailure()
    }
    
    // MARK: - Methods
    
    func getPosts() {
        Task {
            do {
                posts = try await repo.getPosts()
            } catch {
                failure = Failure(error)
            }
        }
    }
    
    func getNextPage() {
        Task {
            do {
                posts.append(contentsOf: try await repo.getNextPage())
            } catch {
                failure = Failure(error)
            }
        }
    }
    
    // MARK: - Private
    
    private func observeFailure() {
        withObservationTracking {
            /// In this case, all errors are displayed. In some cases, you might examine the error to determine whether it should show an alert.
            showingError = failure != nil
        } onChange: {
            /// `withObservationTracking` only gets the next update. Recursively call `observeFailure` to continuously observe the property.
            Task { await self.observeFailure() }
        }
    }
}
