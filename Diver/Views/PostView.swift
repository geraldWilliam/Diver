//
//  PostView.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

/// A composable view representing a single post. Under a header with the author‘s avatar and display name, the post‘s content is displayed.
///
/// Note, this view does not access the Posts. The post is passed in at initialization and no logic is performed. This view is just layout.
struct PostView: View {
    /// The post.
    let post: PostInfo
    /// The detail screen re-uses this view but shouldn‘t show the number of replies. Boosts of other posts also hide the reply count.
    let hideReplyCount: Bool
    /// A formatter to prepare the created date of a post for presentation.
    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                let isBoost = post.boost != nil
                let diameter: CGFloat = isBoost ? 30 : 40
                AvatarView(path: post.avatarPath, diameter: diameter)
                VStack(alignment: .leading) {
                    Text(post.authorName)
                        .fontWeight(isBoost ? .light : .bold)
                        .truncationMode(.tail)
                        .lineLimit(2)
                    if let account = post.account?.acct, !isBoost {
                        Text(account)
                            .fontWeight(.light)
                            .foregroundStyle(Color.gray)
                            .truncationMode(.tail)
                            .lineLimit(1)
                    }
                }
            }
            /// Not all posts have text content.
            if let content = post.attributedBody {
                Text(content)
            }
            /// An altered style if this post is a boost of another one.
            if let boost = post.boost {
                PostView(post: boost, hideReplyCount: false)
                    .blockQuote()
            }
            /// If there are images, show a preview of the first.
            if let preview = post.previews.first {
                AsyncImage(url: preview) { result in
                    result.image?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .animation(.easeIn, value: preview)
            }
            /// The main post of a PostDetailView hides the reply count. Posts in the TimelineView that are simply boosts also hide the reply count.
            HStack {
                if !hideReplyCount, post.boost == nil {
                    Text("\(post.replyCount) replies")
                }
                Text(dateFormatter.string(from: post.createdDate))
            }
            .font(.caption)
            .fontWeight(.light)
            .padding(.top, 5)
        }
        .padding(.vertical)
    }
}

#Preview {
    return PostView(post: PostInfo.mock(), hideReplyCount: false)
}
