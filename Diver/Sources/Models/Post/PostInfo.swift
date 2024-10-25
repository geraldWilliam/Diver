//
//  Post.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import Foundation
import TootSDK
/// A domain model to represent a Post. TootSDK‘s Post type is actually suitable for direct usage in this application but `PostInfo` provides a representation of
/// that external model that only declares the properties we actually use and performs some transformations upon initialization (like converting strings to URLs) to
/// save us a little work later.
///
/// `Identifiable`
/// Models should conform to Identifiable if they need to be displayed in SwiftUI Lists, ForEach, etc.
///
/// `Hashable`
/// Models should conform to Hashable if they need to be selectable in SwiftUI Lists, enumerable by ForEach, etc.
///
/// In many cases, your domain model will be parsed not from an external model type but from raw JSON data. In such cases, declare `Codable` conformance in
/// addition to `Identifiable` and `Hashable`.
struct PostInfo: Identifiable, Hashable {
    /// `Identifiable` conformance.
    let id: String
    /// The URL of the post.
    let url: URL?
    /// The time the post was created.
    let createdDate: Date
    /// The display name of the post author.
    let authorName: String
    /// A URL string pointing to the post author‘s avatar image.
    let avatarPath: String
    /// The main text content of the post.
    let body: String?
    /// Locations of full-size images for the post. Use these in detail views.
    let media: [URL]
    /// Locations of low-res images for the post. Use these in thumbnail previews.
    let previews: [URL]
    /// The number of replies to the post.
    let replyCount: Int
    /// The account that created the post.
    let account: Account?
    /// Whether the current user boosted this post.
    let boosted: Bool
    /// Whether the current user favorited this post.
    let favorited: Bool
    /// This property must be computed because structs cannot have stored properties of their own type. Compiler doesn‘t allow it.
    var boost: PostInfo? {
        if let repost {
            return PostInfo(post: repost)
        }
        return nil
    }
    /// Storage of the external `Post` model backing the `boost` property.
    private let repost: Post?

    // MARK: - Initialization

    init(post: TootSDK.Post) {
        self.account = post.account
        self.repost = post.repost
        self.id = post.id
        self.url = if let path = post.url { URL(string: path) } else { nil }
        self.createdDate = post.createdAt
        self.authorName = post.account.displayName ?? "🀰🀰🀰🀰🀰🀰🀰🀰"
        self.avatarPath = post.account.avatar
        self.body = post.content
        self.media = post.mediaAttachments.compactMap { attachment in
            URL(string: attachment.url)
        }
        self.previews = post.mediaAttachments.compactMap { attachment in
            guard let path = attachment.previewUrl else {
                return nil
            }
            return URL(string: path)
        }
        self.replyCount = post.repliesCount
        self.boosted = post.reposted ?? false
        self.favorited = post.favourited ?? false
    }

    init(
        id: String,
        authorName: String,
        avatarPath: String,
        body: String?,
        media: [URL],
        previews: [URL],
        boosted: Bool,
        favorited: Bool
    ) {
        self.account = nil
        self.repost = nil
        self.id = id
        self.url = nil
        self.createdDate = Date()
        self.authorName = authorName
        self.avatarPath = avatarPath
        self.body = body
        self.media = media
        self.previews = previews
        self.replyCount = 0
        self.boosted = boosted
        self.favorited = favorited
    }

    // MARK: - Mock

    static func mock() -> PostInfo {
        PostInfo(
            id: UUID().uuidString,
            authorName: "Preview Author",
            avatarPath: "",
            body: "This is a preview post!!!",
            media: [],
            previews: [],
            boosted: false,
            favorited: false
        )
    }
}
