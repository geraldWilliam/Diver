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
    private let storageKey = "storedInstances"

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func list() throws -> [InstanceInfo] {
        if let stored = userDefaults.data(forKey: storageKey) {
            return try decoder.decode([InstanceInfo].self, from: stored)
        }
        return []
    }

    func store(_ instance: InstanceInfo) throws -> [InstanceInfo] {
        var array: [InstanceInfo]
        if let data = userDefaults.data(forKey: storageKey) {
            array = try decoder.decode([InstanceInfo].self, from: data)
        } else {
            array = []
        }

        if array.contains(instance) {
            // TODO: Throw?
            return array
        }
        array.append(instance)
        userDefaults.set(try encoder.encode(array), forKey: storageKey)
        return array
    }

    func remove(_ instance: InstanceInfo) throws -> [InstanceInfo] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            // TODO: Throw?
            return []
        }
        var array = try decoder.decode([InstanceInfo].self, from: data)
        guard array.contains(instance) else {
            // TODO: Throw?
            return array
        }
        array.removeAll { $0 == instance }
        userDefaults.set(try encoder.encode(array), forKey: storageKey)
        return array
    }
}
