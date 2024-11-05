//
//  InstanceRepository.swift
//  Diver
//
//  Created by Gerald Burke on 11/4/24.
//

import Foundation
import SwiftKeychainWrapper

final class InstanceRepository {
    let service = InstanceService()
    var stored: [InstanceInfo] {
        service.stored
    }
}
