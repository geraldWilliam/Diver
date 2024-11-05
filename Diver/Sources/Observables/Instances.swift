//
//  Instances.swift
//  Diver
//
//  Created by Gerald Burke on 11/5/24.
//

import Foundation

@MainActor @Observable final class Instances {
    var available: [InstanceInfo] = []
    var failure: Failure?
    
    private let repo: InstanceRepositoryProtocol
    
    init(repo: InstanceRepositoryProtocol) {
        self.repo = repo
        getInstances()
    }
    
    func getInstances() {
        available = repo.stored
    }
    
    func add(_ instanceName: String) {
        do {
            let instance = try repo.store(instanceName)
            available.append(instance)
        } catch {
            failure = Failure(error)
        }
    }
    
    func remove(_ instance: InstanceInfo) {
        do {
            try repo.remove(instance)
            available = repo.stored
        } catch {
            failure = Failure(error)
        }
        
    }
}
