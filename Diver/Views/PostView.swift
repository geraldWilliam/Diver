//
//  PostView.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

/// A composable view representing a single post. Under a header with the author‘s avatar and display name, the post‘s content is displayed.
///
/// Note, this view does not access the PostsController. The post is passed in at initialization and no logic is performed. This view is just layout.
struct PostView: View {
    /// The post.
    let post: PostInfo
    /// The detail screen re-uses this view but shouldn‘t show the number of replies. Boosts of other posts also hide the reply count.
    let hideReplyCount: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                let diameter: CGFloat = post.boost == nil ? 40 : 30
                AvatarView(path: post.avatarPath, diameter: diameter)
                Text(post.authorName)
                    .fontWeight(post.boost == nil ? .bold : .light)
                    .truncationMode(.tail)
                    .lineLimit(2)
            }
            /// Not all posts have text content.
            if let content = post.body {
                Text(content)
            }
            /// An altered style if this post is a boost of another one.
            if let boost = post.boost {
                HStack {
                    Rectangle()
                        .frame(maxWidth: 2)
                        .foregroundStyle(Color.gray)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 1, height: 1)))
                    PostView(post: boost, hideReplyCount: false)
                        .padding(.leading)
                }
            }
            /// If there are images, show a preview of the first.
            if let preview = post.previews.first {
                AsyncImage(url: preview) { result in
                    result.image?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            ///
            if !hideReplyCount, post.boost == nil {
                Text("\(post.replyCount) replies")
                    .font(.caption)
                    .fontWeight(.light)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    return PostView(post: PostInfo.mock(), hideReplyCount: false)
}
