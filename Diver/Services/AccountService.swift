//
//  AccountService.swift
//  Diver
//
//  Created by Gerald Burke on 10/24/24.
//

import Foundation
import SwiftKeychainWrapper

private let serviceName = "com.nerdery.Diver"
private let accountKey = "stored_account"

final class AccountService {
    
    private let keychain = KeychainWrapper(serviceName: serviceName)

    var account: AccountInfo? {
        get {
            // Is there an account in memory?
            if let storedAccount {
                return storedAccount
            }
            // Check for a cached account in the keychain.
            let account = try? keychain.data(forKey: accountKey).map {
                return try JSONDecoder().decode(AccountInfo.self, from: $0)
            }
            // Store the result in memory.
            storedAccount = account
            // And return it.
            return account
        }
        set {
            // The account is being set directly. Store it in memory.
            storedAccount = newValue
            // And store it in the keychain.
            if let newValue {
                do {
                    let data = try JSONEncoder().encode(newValue)
                    keychain.set(data, forKey: accountKey)
                } catch {
                    debugPrint("Failed to encode AccountInfo: \(newValue)")
                }
            } else {
                keychain.removeObject(forKey: accountKey)
            }
        }
    }
    
    private var storedAccount: AccountInfo?
}
