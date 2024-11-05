//
//  InstanceInfo.swift
//  Diver
//
//  Created by Gerald Burke on 11/4/24.
//

import Foundation

struct InstanceInfo: Codable, Hashable, Identifiable {
    let id: String
    let token: String?
    var domainName: String {
        id
    }
}
