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
    func getStoredAccounts() throws -> [AccountInfo]
    /// Store an account for quick login.
    func store(_ account: AccountInfo) throws -> AccountInfo
    /// Get a session.
    func getSession(instance: URL) async throws -> SessionInfo
}

// MARK: - Concrete Implementation

final class SessionRepository: SessionRepositoryProtocol {
    var client: TootClient {
        ClientService.shared.client
    }

    private let defaults = UserDefaults.standard
    
    private let decoder = JSONDecoder()
    
    private let encoder = JSONEncoder()
    
    private let storedAccountsKey = "stored_accounts"

    private let accountService: AccountService

    private let tokenService: TokenService

    init(tokenService: TokenService, accountService: AccountService) {
        self.tokenService = tokenService
        self.accountService = accountService
        Task {
            // This is required for activation.
            try await client.connect()
        }
    }

    func getStoredAccounts() throws -> [AccountInfo] {
        try defaults.data(forKey: storedAccountsKey).map {
            try decoder.decode([AccountInfo].self, from: $0)
        } ?? []
    }

    func store(_ account: AccountInfo) throws -> AccountInfo {
        var accounts = try getStoredAccounts()
        accounts.append(account)
        let data = try encoder.encode(accounts)
        defaults.set(data, forKey: storedAccountsKey)
        return account
    }

    func getSession(instance: URL) async throws -> SessionInfo {
        client.instanceURL = instance
        let token = try await client.presentSignIn(callbackURI: "com.sudonym.Diver://home")
        let account = AccountInfo(account: try await client.verifyCredentials())
        let session = SessionInfo(token: token, account: account)
        // Side-effect, maybe move it?
        tokenService.storeToken(for: session)
        return session
    }
}

// MARK: - Mock Implementation

// periphery:ignore
class MockSessionRepository: SessionRepositoryProtocol {

    private var account: AccountInfo?
    
    var isLoggedIn: Bool {
        account != nil
    }

    func getStoredAccounts() throws -> [AccountInfo] {    
        return [.mock()]
    }

    func store(_ account: AccountInfo) throws -> AccountInfo {
        return .mock()
    }

    func getSession(instance: URL) async throws -> SessionInfo {
        let account = AccountInfo.mock()
        self.account = account
        return SessionInfo(token: "fake-access-token", account: account)
    }
}
