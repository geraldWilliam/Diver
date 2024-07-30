//
//  AuthorHeader.swift
//  Diver
//
//  Created by Gerald Burke on 7/30/24.
//

import SwiftUI

struct AuthorHeader: View {
    let post: PostInfo
    var body: some View {
        HStack {
            let isBoost = post.boost != nil
            let diameter: CGFloat = isBoost ? 30 : 40
            AvatarView(path: post.avatarPath, diameter: diameter)
            VStack(alignment: .leading) {
                Text(post.authorName)
                    /// Boost posts show the booster‘s name in lighter font to draw focus to the boosted content.
                    .fontWeight(isBoost ? .light : .bold)
                    /// Ellipsis for overflow.
                    .truncationMode(.tail)
                    /// Some display names can be quite long. Limit to two lines.
                    .lineLimit(2)
                    /// The author name in boost posts is displayed above the boosted. The author‘s role as booster is only indicated by this positioning. For
                    /// the accessibility label, append localized "boosted" so VoiceOver reads "<author-name> boosted ... "
                    .accessibilityLabel(isBoost ? String(localized: "\(post.authorName) boosted") : post.authorName)
                
                /// If this is an original post, not a boost, show the author‘s handle (e.g., @username@mastodon.social).
                if let account = post.account?.acct, !isBoost {
                    Text(account)
                        .fontWeight(.light)
                        .truncationMode(.tail)
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    AuthorHeader(post: PostInfo.mock())
}
