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
    let handle: String
    let profileImage: URL?
    let postCount: Int
    let url: URL

    init(account: Account) {
        self.id = account.id
        self.username = AccountInfo.username(for: account)
        self.displayName = account.displayName ?? ""
        self.handle = account.acct
        self.profileImage = URL(string: account.avatar)
        self.postCount = account.postsCount
        self.url = URL(string: account.url)!
    }

    init(
        id: String,
        username: String,
        displayName: String,
        handle: String,
        profileImage: URL,
        postCount: Int,
        url: URL
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.handle = handle
        self.profileImage = profileImage
        self.postCount = postCount
        self.url = url
    }

    static func mock() -> AccountInfo {
        AccountInfo(
            id: UUID().uuidString,
            username: "testUsername",
            displayName: "A freely defined display name...",
            handle: "@testUsername@testDomain.com",
            profileImage: URL(string: "https://picsum.photos/200/300")!,
            postCount: 123,
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
