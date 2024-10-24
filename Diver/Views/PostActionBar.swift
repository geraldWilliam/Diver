//
//  PostActionBar.swift
//  Diver
//
//  Created by Gerald Burke on 10/24/24.
//

import SwiftUI

struct PostActionBar: View {
    let posts: Posts
    let post: PostInfo
    @State private var confirmingDelete: Bool = false
    var body: some View {
        HStack {
            /// Reply
            Button(action: { /* SHOW REPLY UI */ }) {
                Image(systemName: "bubble.right")
            }
            /// Boost
            Button(action: { post.boosted ? posts.removeBoost(post) : posts.boost(post) }) {
                Image(systemName: "arrow.2.squarepath")
            }
            .foregroundStyle(post.boosted ? Color.red : .accentColor)
            /// Favorite
            Button(action: { post.favorited ? posts.removeFavorite(post) : posts.favorite(post) }) {
                Image(systemName: "star")
            }
            .foregroundStyle(post.favorited ? Color.red : .accentColor)
            /// Share Sheet
            if let url = post.url {
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
            Button("Cancel") { }
            Button("Delete") { posts.delete(post.id) }
        }
    }
}

#Preview {
    let posts = Posts(repo: MockPostsRepository())
    let post = PostInfo.mock()
    PostActionBar(posts: posts, post: post)
}
