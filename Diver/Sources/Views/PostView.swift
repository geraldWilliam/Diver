//
//  PostView.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

/// A composable view representing a single post. Under a header with the author‘s avatar and display name, the post‘s content is displayed.
///
struct PostView: View {
    @Environment(Posts.self) var posts
    /// The post.
    let post: PostInfo
    /// Whether the post should be displayed as a preview or full view.
    let isPreview: Bool
    /// Whether the post should show action buttons.
    let showsActions: Bool

    /// A formatter to prepare the created date of a post for presentation.
    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading) {
            AuthorHeader(post: post)
            /// Not all posts have text content.
            if let content = post.attributedBody {
                Text(content)
            }
            /// An altered style if this post is a boost of another one.
            if let boost = post.boost {
                PostView(post: boost, isPreview: true, showsActions: false)
                    .blockQuote()
            }
            /// If there are images, show a preview of the first.
            if let image = isPreview ? post.previews.first : post.media.first {
                AsyncImage(url: image) { image in
                    image.resizable()
                } placeholder: {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .overlay(alignment: .center) {
                            Image(systemName: "exclamationmark.circle")
                        }
                        .foregroundStyle(Color.primary)
                }
                .aspectRatio(contentMode: .fit)
                .animation(.easeIn, value: image)
            }
            /// The main post of a PostDetailView hides the reply count. Posts in the TimelineView
            /// that are simply boosts also hide the reply count.
            HStack {
                if isPreview, post.boost == nil {
                    Text("\(post.replyCount) replies")
                }
                Text(dateFormatter.string(from: post.createdDate))
            }
            .font(.caption)
            .fontWeight(.light)
            .padding(.top, 5)

            if showsActions {
                PostActionBar(posts: posts, post: post)
            }
        }
        .padding(.vertical)
    }
}

//#Preview {
//    let posts = Posts(repo: MockPostsRepository())
//    return PostView(post: PostInfo.mock(), isPreview: false)
//        .environment(posts)
//}
