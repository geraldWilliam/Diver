//
//  ClientService.swift
//  Diver
//
//  Created by Gerald Burke on 12/14/24.
//

import Foundation
import TootSDK

class ClientService {
    /// Client must be created with a URL. Real requests get URL from session (see updateSession).
    var client = TootClient(instanceURL: URL(string: "https://sudonym.net")!, accessToken: nil)
    func updateSession(_ session: SessionInfo) async throws {
        guard let url = session.instanceURL else {
            return
        }
        client = TootClient(clientName: "Diver", instanceURL: url, accessToken: session.token)
    }
}
