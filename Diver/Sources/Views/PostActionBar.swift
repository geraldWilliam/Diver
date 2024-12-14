//
//  PostActionBar.swift
//  Diver
//
//  Created by Gerald Burke on 10/24/24.
//

import SwiftUI

struct PostActionBar: View {
    @Environment(Navigator.self) var navigator
    @Environment(Posts.self) var posts
    let postID: PostInfo.ID
    @State private var confirmingDelete: Bool = false

    var body: some View {
        /// The view is re-evaluated when `posts` changes. Re-query the feed for the post.
        /// This makes the button states update correctly for favorites, replies, and boosts.
        // TODO: Can I use a binding or something for this? Querying the feed feels wrong.
        if let post = posts.feed.first(where: { $0.id == postID }) {
            HStack {
                /// Reply
                Button(action: { navigator.present(.postComposer(post: post)) }) {
                    Image(systemName: "bubble.right")
                }
                /// Boost
                Button(action: { post.boosted ? posts.removeBoost(post) : posts.boost(post) }) {
                    Image(systemName: "arrow.2.squarepath")
                }
                .foregroundStyle(post.boosted ? Color.red : .accentColor)
                /// Favorite
                Button(action: { post.favorited ? posts.removeFavorite(post) : posts.favorite(post) }) {
                    Image(systemName: post.favorited ? "star.fill" : "star")
                }
                .foregroundStyle(post.favorited ? Color.yellow : .accentColor)
                /// Share Sheet
                if let url = post.url ?? post.boost?.url {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                /// More Actions...
                Menu {
                    Button(role: .destructive, action: { confirmingDelete = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "gear")
                }
            }
            .buttonStyle(BorderedButtonStyle())
            .alert("Delete Post?", isPresented: $confirmingDelete) {
                Button("Cancel") {}
                Button("Delete") { posts.delete(post.id) }
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    let posts = Posts(repo: MockPostsRepository())
    let post = PostInfo.mock()
    PostActionBar(postID: post.id)
        .environment(posts)
}
