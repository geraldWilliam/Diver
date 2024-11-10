//
//  TokenService.swift
//  Diver
//
//  Created by Gerald Burke on 8/1/24.
//

import Foundation
import SwiftKeychainWrapper

private let serviceName = "com.sudonym.Diver"

final class TokenService {

    private let keychain = KeychainWrapper(serviceName: serviceName)

    func token(for session: SessionInfo) -> String? {
        keychain.string(forKey: session.account.handle)
    }

    func storeToken(for session: SessionInfo) {
        keychain.set(session.token, forKey: session.account.handle)
    }
    
    func clearToken(for session: SessionInfo) {
        keychain.removeObject(forKey: session.account.handle)
    }
}
