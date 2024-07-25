//
//  PostDetailView.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

/// The detail screen for a post. It shows the post and its replies.
struct PostDetailView: View {
    /// This view uses the same observable as the TimelineView.
    @Environment(Posts.self) var posts: Posts
    /// The main post being displayed.
    let post: PostInfo

    var body: some View {
        List {
            Section {
                /// Show the main post as a header section.
                PostView(post: post, hideReplyCount: true)
            }
            Section {
                /// Show a list of replies below the main post.
                ForEach(posts.replies[post.id] ?? []) { reply in
                    NavigationLink(value: Navigator.Destination.postDetail(reply)) {
                        PostView(post: reply, hideReplyCount: false)
                    }
                }
            }
        }
        .navigationTitle("Detail")
        .toolbarTitleDisplayMode(.inline)
        .listStyle(.plain)
        .task {
            posts.getReplies(for: post)
        }
    }
}

#Preview {
    let repo = MockPostsRepository()
    let posts = Posts(repo: repo)
    return PostDetailView(post: PostInfo.mock())
        .environment(posts)
}
