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
    /// Check is the user is logged in.
    var isLoggedIn: Bool { get }
    /// Get a session.
    func logIn() async throws -> SessionInfo
    /// Clear the session.
    func logOut()
}

// MARK: - Concrete Implementation

final class SessionRepository: SessionRepositoryProtocol {
    let client: TootClient
    var isLoggedIn: Bool {
        token != nil
    }
    private let tokenService: TokenService
    private var token: String? {
        get {
            tokenService.token
        }
        set {
            tokenService.token = newValue
        }
    }
    // Don't I need to cache this?
    private var account: AccountInfo?

    init(client: TootClient, tokenService: TokenService) {
        self.client = client
        self.tokenService = tokenService
        Task {
            // This is required for activating the TootClient.
            try await client.connect()
        }
    }

    func logIn() async throws -> SessionInfo {
        if let token, let account {
            return SessionInfo(token: token, account: account)
        }
        let token = try await client.presentSignIn(callbackURI: "com.nerdery.Diver://home")
        // Cache the token in the keychain.
        self.token = token
        
        let account = AccountInfo(account: try await client.verifyCredentials())
        // TODO: Cache the account?!?!
        self.account = account
        
        let session = SessionInfo(token: token, account: account)
        return session
    }
    
    func logOut() {
        token = nil
        account = nil
    }
}

// MARK: - Mock Implementation

// periphery:ignore
struct MockSessionRepository: SessionRepositoryProtocol {
    var isLoggedIn: Bool { true }
    func logIn() async throws -> SessionInfo {
        SessionInfo(token: "fake-access-token", account: .mock())
    }
    func logOut() {
        //
    }
}
