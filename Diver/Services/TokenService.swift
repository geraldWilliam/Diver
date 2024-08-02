//
//  TokenService.swift
//  Diver
//
//  Created by Gerald Burke on 8/1/24.
//

import Foundation
import SwiftKeychainWrapper

private let serviceName = "com.nerdery.Diver"
private let accessTokenKey = "access_token"

final class TokenService {
    static let shared = TokenService()
    
    private let keychain = KeychainWrapper(serviceName: serviceName)

    var token: String? {
        get {
            keychain.string(forKey: accessTokenKey)
        }
        set {
            if let newValue {
                keychain.set(newValue, forKey: accessTokenKey)
            } else {
                keychain.removeObject(forKey: accessTokenKey)
            }
        }
    }
}