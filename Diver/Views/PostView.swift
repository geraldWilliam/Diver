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
    /// Whether the view is presenting an alert for the user to confirm they want to delete the post.
    @State private var confirmingDelete: Bool = false
    
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
                PostView(post: boost, isPreview: true)
                    .blockQuote()
            }
            /// If there are images, show a preview of the first.

            if let image = isPreview ? post.previews.first : post.media.first {
                AsyncImage(url: image) { result in
                    result.image?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .animation(.easeIn, value: image)
            }
            /// The main post of a PostDetailView hides the reply count. Posts in the TimelineView that are simply boosts also hide the reply count.
            HStack {
                if isPreview, post.boost == nil {
                    Text("\(post.replyCount) replies")
                }
                Text(dateFormatter.string(from: post.createdDate))
            }
            .font(.caption)
            .fontWeight(.light)
            .padding(.top, 5)
            
            HStack {
                Button(action: { }) {
                    Image(systemName: "bubble.right")
                }
                Button(action: { post.boosted ? posts.removeBoost(post) : posts.boost(post) }) {
                    Image(systemName: "arrow.2.squarepath")
                }
                .foregroundStyle(post.boosted ? Color.red : .accentColor)
                Button(action: { }) {
                    Image(systemName: "star")
                }
                Button(action: { }) {
                    Image(systemName: "square.and.arrow.up")
                }
                Button(action: { }) {
                    Image(systemName: "gear")
                }
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .padding(.vertical)
        .alert("Delete Post?", isPresented: $confirmingDelete) {
            Button("Cancel") { }
            Button("Delete") { posts.delete(post.id) }
        }
    }
}

#Preview {
    return PostView(post: PostInfo.mock(), isPreview: false)
}
