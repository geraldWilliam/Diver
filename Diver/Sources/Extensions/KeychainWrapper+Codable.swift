//
//  KeychainWrapper+Codable.swift
//  Diver
//
//  Created by Gerald Burke on 11/5/24.
//

import Foundation
import SwiftKeychainWrapper

extension KeychainWrapper {
    private static var encoder = JSONEncoder()
    private static var decoder = JSONDecoder()
    func codable<T: Codable>(key: String) -> T? {
        // Check for a cached account in the keychain.
        try? data(forKey: key).map {
            return try Self.decoder.decode(T.self, from: $0)
        }
    }
    
    func set<T: Codable>(codable: T, key: String) -> Bool {
        do {
            return set(try Self.encoder.encode(codable), forKey: key)
        } catch {
            return false
        }
    }
}
