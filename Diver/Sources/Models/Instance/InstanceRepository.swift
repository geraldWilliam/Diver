//
//  InstanceRepository.swift
//  Diver
//
//  Created by Gerald Burke on 11/4/24.
//

import Foundation
import SwiftKeychainWrapper

protocol InstanceRepositoryProtocol {
    var stored: [InstanceInfo] { get }
    func store(_ instanceName: String) throws -> InstanceInfo
    func remove(_ instance: InstanceInfo) throws
}

final class InstanceRepository: InstanceRepositoryProtocol {
    let service = InstanceService()
    var stored: [InstanceInfo] = []
    init() {
        do {
            stored = try service.list()
        } catch {
            stored = []
        }
    }
    func store(_ instanceName: String) throws -> InstanceInfo {
        guard stored.first(where: { $0.id == instanceName }) == nil else {
            throw Failure("Instance \(instanceName) already stored.")
        }
        let instance = InstanceInfo(id: instanceName)
        stored = try service.store(instance)
        return instance
    }
    
    func remove(_ instance: InstanceInfo) throws {
        stored = try service.remove(instance)
    }
}

class MockInstanceRepository: InstanceRepositoryProtocol {
    var stored: [InstanceInfo] = []
    init() {
        stored = [.mock()]
    }
    func store(_ instanceName: String) throws -> InstanceInfo {
        guard stored.first(where: { $0.id == instanceName }) == nil else {
            throw Failure("Instance \(instanceName) already stored.")
        }
        let instance = InstanceInfo(id: instanceName)
        stored.append(instance)
        return instance
    }
    func remove(_ instance: InstanceInfo) {
        stored.removeAll(where: { $0 == instance })
    }
}
