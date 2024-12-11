//
//  PostDetailView.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

/// The detail screen for a post. It shows the post and its replies.
struct PostDetailView: View {
    /// This view uses the same observable as the FeedView.
    @Environment(Posts.self) var posts: Posts
    /// The main post being displayed.
    let post: PostInfo

    var body: some View {
        ScrollViewReader { proxy in
            List {
                /// Show the full thread, including the main post.
                ForEach(posts.threads[post.id] ?? []) { post in
                    NavigationLink(value: Navigator.Destination.postDetail(post)) {
                        PostView(post: post, isPreview: post != self.post, showsActions: true)
                    }
                    .id(post) // Allow scrolling to the post.
                }
            }
            /// If the thread is already available, scroll to the post.
            .task {
                proxy.scrollTo(post)
            }
            /// If the thread containing the post has been changed, scroll to the post itself. This
            /// allows focusing the post on first load.
            .onChange(of: posts.threads) { oldValue, newValue in
                if let thread = newValue[post.id], thread.contains(post) {
                    proxy.scrollTo(post)
                }
            }
        }
        .navigationTitle("Detail")
        .toolbarTitleDisplayMode(.inline)
        .listStyle(.plain)
        .task {
            posts.getContext(for: post)
        }
    }
}

#Preview {
    let repo = MockPostsRepository()
    let posts = Posts(repo: repo)
    return PostDetailView(post: PostInfo.mock())
        .environment(posts)
}
