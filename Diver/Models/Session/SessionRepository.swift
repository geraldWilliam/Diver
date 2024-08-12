//
//  SessionRepository.swift
//  Diver
//
//  Created by Gerald Burke on 7/31/24.
//

import Foundation
import TootSDK

// MARK: - Protocol

protocol SessionRepositoryProtocol {
    /// Get an access token.
    func logIn() async throws -> String
}

// MARK: - Concrete Implementation

actor SessionRepository: SessionRepositoryProtocol {
    let client: TootClient

    init(client: TootClient) {
        self.client = client
        Task {
            // This is required for activating the TootClient.
            try await client.connect()
        }
    }

    func logIn() async throws -> String {
        if let token = TokenService.shared.token {
            return token
        }
        let token = try await client.presentSignIn(callbackURI: "com.nerdery.Diver://home")
        // Cache the token in the keychain.
        TokenService.shared.token = token
        return token
    }
}

// MARK: - Mock Implementation

// periphery:ignore
struct MockSessionRepository: SessionRepositoryProtocol {
    var token: String?
    func logIn() async throws -> String {
        "fake-access-token"
    }
}
