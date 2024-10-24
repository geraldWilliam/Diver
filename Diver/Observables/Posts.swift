//
//  Posts.swift
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
@MainActor @Observable final class Posts {
    /// The posts to be displayed. Note, we use a domain-specific model here instead of the external `Post` model provided by TootSDK.
    var timeline: [PostInfo] = []
    /// A dictionary of replies, keyed by their parent posts.
    var replies: [PostInfo.ID: [PostInfo]] = [:]
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

    func getLatestPosts() {
        Task {
            do {
                timeline = try await repo.getLatestPosts()
            } catch {
                failure = Failure(error)
            }
        }
    }

    func getEarlierPosts() {
        Task {
            do {
                let more = try await repo.getEarlierPosts().filter { !timeline.contains($0) }
                timeline.append(contentsOf: more)
            } catch {
                failure = Failure(error)
            }
        }
    }

    func getReplies(for post: PostInfo) {
        Task {
            do {
                replies[post.id] = try await repo.getReplies(for: post)
            } catch {
                failure = Failure(error)
            }
        }
    }

    func publish(_ text: String, media: [Data], replyingTo originalPost: PostInfo?) {
        Task {
            do {
                let post = try await repo.send(text, media: media, replyingTo: originalPost)
                timeline.insert(post, at: 0)
            } catch {
                failure = Failure(error)
            }
        }
    }
    
    // TODO: Support delete & redraft.
    func delete(_ id: PostInfo.ID) {
        Task {
            do {
                _ = try await repo.delete(id)
                timeline.removeAll { $0.id == id }
            } catch {
                failure = Failure(error)
            }
        }
    }
    
    func boost(_ post: PostInfo) {
        Task {
            do {
                // Boost the post. This returns the boost, not the original post.
                let post = try await repo.boost(post)
                // Get the newly boosted post via the `boost` property of the action's result.
                if let boost = post.boost, let index = timeline.firstIndex(where: { $0.id == boost.id }) {
                    // Replace the old copy in the timeline.
                    timeline[index] = boost
                }
            } catch {
                failure = Failure(error)
            }
        }
    }
    
    func removeBoost(_ post: PostInfo) {
        Task {
            do {
                // Un-boost the post. This returns the boost, not the original post.
                let post = try await repo.removeBoost(post)
                // Get the newly boosted post via the `boost` property of the action's result.
                if let index = timeline.firstIndex(where: { $0.id == post.id }) {
                    // Replace the old copy in the timeline.
                    timeline[index] = post
                }
            } catch {
                failure = Failure(error)
            }
        }
    }
    
    func favorite(_ post: PostInfo) {
        Task {
            do {
                let post = try await repo.favorite(post)
                if let index = timeline.firstIndex(where: { $0.id == post.id }) {
                    timeline[index] = post
                }
            } catch {
                failure = Failure(error)
            }
        }
    }
    
    func removeFavorite(_ post: PostInfo) {
        Task {
            do {
                let post = try await repo.removeFavorite(post)
                if let index = timeline.firstIndex(where: { $0.id == post.id }) {
                    timeline[index] = post
                }
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
