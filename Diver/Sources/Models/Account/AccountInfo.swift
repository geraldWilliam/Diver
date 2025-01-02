//
//  AccountInfo.swift
//  Diver
//
//  Created by Gerald Burke on 10/23/24.
//

import Foundation
import TootSDK

struct AccountInfo: Codable, Hashable, Identifiable {
    let id: String
    let username: String
    let displayName: String
    let bio: String
    let profileImage: URL?
    let headerImage: URL?
    let postCount: Int
    let followersCount: Int
    let followingCount: Int
    let url: URL

    var handle: String {
        let host = URLComponents(url: url, resolvingAgainstBaseURL: false)?.host ?? ""
        return ["@", username, "@", host].joined()
    }

    init(account: Account) {
        self.id = account.id
        self.username = AccountInfo.username(for: account)
        self.displayName = account.displayName ?? ""
        self.bio = account.note
        self.profileImage = URL(string: account.avatar)
        self.headerImage = URL(string: account.header)
        self.postCount = account.postsCount
        self.followersCount = account.followersCount
        self.followingCount = account.followingCount
        self.url = URL(string: account.url)!
    }

    init(
        id: String,
        username: String,
        displayName: String,
        bio: String,
        profileImage: URL,
        headerImage: URL,
        postCount: Int,
        followersCount: Int,
        followingCount: Int,
        url: URL
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.profileImage = profileImage
        self.headerImage = headerImage
        self.postCount = postCount
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.url = url
    }

    static func mock() -> AccountInfo {
        AccountInfo(
            id: UUID().uuidString,
            username: "testUsername",
            displayName: "my Name",
            bio: String.filler(wordCount: 100),
            profileImage: URL(string: "https://picsum.photos/200/300")!,
            headerImage: URL(string: "https://picsum.photos/600/300")!,
            postCount: 123,
            followersCount: 456,
            followingCount: 789,
            url: URL(string: "https://me@sudonym.net")!
        )
    }

    private static func username(for account: Account) -> String {
        if let username = account.username {
            return username
        }
        let components = account.acct.split(separator: "@")
        if let username = components.first {
            return String(username)
        }
        return ""
    }
}
