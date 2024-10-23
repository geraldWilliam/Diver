//
//  AccountInfo.swift
//  Diver
//
//  Created by Gerald Burke on 10/23/24.
//

import Foundation
import TootSDK

struct AccountInfo {
    let id: String
    
    init(account: Account) {
        self.id = account.id
    }
    
    init(id: String) {
        self.id = id
    }
    
    static func mock() -> AccountInfo {
        AccountInfo(id: UUID().uuidString)
    }
}
