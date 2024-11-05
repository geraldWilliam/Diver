//
//  InstanceInfo.swift
//  Diver
//
//  Created by Gerald Burke on 11/4/24.
//

import Foundation

struct InstanceInfo: Codable, Hashable, Identifiable {
    let id: String
    var domainName: String { id }
    
    // MARK: - Mock

    static func mock() -> InstanceInfo {
        InstanceInfo(id: UUID().uuidString)
    }
}
