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
    // TODO: currentSession instead of account?
    var account: AccountInfo? { get }
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
        token != nil && account != nil
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

    var account: AccountInfo? {
        get {
            accountService.account
        }
        set {
            accountService.account = newValue
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

    func logIn() async throws -> SessionInfo {
        if let token, let account {
            return SessionInfo(token: token, account: account)
        }

        let token = try await client.presentSignIn(callbackURI: "com.nerdery.Diver://home")
        self.token = token

        let account = AccountInfo(account: try await client.verifyCredentials())
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
class MockSessionRepository: SessionRepositoryProtocol {
    var account: AccountInfo?
    var isLoggedIn: Bool {
        account != nil
    }
    func logIn() async throws -> SessionInfo {
        let account = AccountInfo.mock()
        self.account = account
        return SessionInfo(token: "fake-access-token", account: account)
    }
    func logOut() {
        self.account = nil
    }
}
