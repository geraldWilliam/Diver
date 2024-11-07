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
    let displayName: String
    let handle: String
    let profileImage: URL?
    let postCount: Int

    init(account: Account) {
        self.id = account.id
        self.displayName = account.displayName ?? ""
        self.handle = account.acct
        self.profileImage = URL(string: account.avatar)
        self.postCount = account.postsCount
    }

    init(id: String, displayName: String, handle: String, profileImage: URL, postCount: Int) {
        self.id = id
        self.displayName = displayName
        self.handle = handle
        self.profileImage = profileImage
        self.postCount = postCount
    }

    static func mock() -> AccountInfo {
        AccountInfo(
            id: UUID().uuidString,
            displayName: "testUsername",
            handle: "@testUsername@testDomain.com",
            profileImage: URL(string: "https://picsum.photos/200/300")!,
            postCount: 123
        )
    }
}
