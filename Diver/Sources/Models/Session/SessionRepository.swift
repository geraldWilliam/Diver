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
    /// Get user's owned accounts stored on device.
    func getStoredAccounts() async throws -> [AccountInfo]
    /// Store an account for quick login.
    func store(_ account: AccountInfo) async throws -> AccountInfo
    /// Check is the user is logged in.
    var isLoggedIn: Bool { get }
    /// Get a session.
    func logIn(instance: URL) async throws -> SessionInfo
    /// Clear the session.
    func logOut()
}

// MARK: - Concrete Implementation

final class SessionRepository: SessionRepositoryProtocol {
    let client: TootClient

    var isLoggedIn: Bool {
        token != nil
    }

    let accountService: AccountService

    private let tokenService: TokenService

    private var token: String? {
        get {
            tokenService.token
        }
        set {
            tokenService.token = newValue
        }
    }

    init(client: TootClient, tokenService: TokenService, accountService: AccountService) {
        self.client = client
        self.tokenService = tokenService
        self.accountService = accountService
        Task {
            // This is required for activating the TootClient.
            try await client.connect()
        }
    }

    func getStoredAccounts() async throws -> [AccountInfo] {
        return []
    }

    func store(_ account: AccountInfo) async throws -> AccountInfo {
        // TODO: Persist and only return the argument if save succeeds. 
        return account
    }

    func logIn(instance: URL) async throws -> SessionInfo {
        client.instanceURL = instance
        
        let token = try await client.presentSignIn(callbackURI: "com.nerdery.Diver://home")
        // TODO: Store token, associated with full account handle.
        self.token = token

        let account = AccountInfo(account: try await client.verifyCredentials())
        let session = SessionInfo(token: token, account: account)
        return session
    }

    func logOut() {
        token = nil
        // Will need to implement this to invalidate tokens.
//        client.logout(clientId: <#T##String#>, clientSecret: <#T##String#>)
    }
}

// MARK: - Mock Implementation

// periphery:ignore
class MockSessionRepository: SessionRepositoryProtocol {
    private var account: AccountInfo?
    var isLoggedIn: Bool {
        account != nil
    }

    func getStoredAccounts() async throws -> [AccountInfo] {
        return [.mock()]
    }

    func store(_ account: AccountInfo) async throws -> AccountInfo {
        return .mock()
    }

    func logIn(instance: URL) async throws -> SessionInfo {
        let account = AccountInfo.mock()
        self.account = account
        return SessionInfo(token: "fake-access-token", account: account)
    }

    func logOut() {
        account = nil
    }
}
