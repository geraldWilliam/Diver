//
//  SessionInfo.swift
//  Diver
//
//  Created by Gerald Burke on 7/31/24.
//

import Foundation

struct SessionInfo {
    let token: String
    let account: AccountInfo

    var instanceURL: URL? {
        let host = account.url.host()
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        return components.url
    }
}
