//
//  InstanceService.swift
//  Diver
//
//  Created by Gerald Burke on 11/4/24.
//

import Foundation
import SwiftKeychainWrapper

final class InstanceService {
    private let userDefaults = UserDefaults.standard
    private let keychain = KeychainWrapper(serviceName: "net.sudonym.Diver")
    private let storageKey = "storedInstances"
    
    private(set) var stored: [InstanceInfo] {
        get {
            let identifiers = userDefaults
                .array(forKey: storageKey)
                .map { $0 as? [String] ?? [] } ?? []
            return identifiers.map {
                InstanceInfo(id: $0, token: keychain.string(forKey: $0))
            }
        }
        set {
            userDefaults.set(newValue, forKey: storageKey)
            
            stored.forEach { instance in
                if let token = instance.token {
                    keychain.set(token, forKey: instance.domainName)
                }
            }
        }
    }
}
