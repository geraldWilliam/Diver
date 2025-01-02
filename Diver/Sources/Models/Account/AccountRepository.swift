//
//  AccountRepository.swift
//  Diver
//
//  Created by Gerald Burke on 10/25/24.
//

import Foundation
import TootSDK

protocol AccountRepositoryProtocol {
    func search(text: String) async throws -> [AccountInfo]
    func getFollowing() async throws -> [AccountInfo]
    func getFollowing(_ id: AccountInfo.ID) async throws -> [AccountInfo]
    func getFollowers() async throws -> [AccountInfo]
    func getFollowers(for id: AccountInfo.ID) async throws -> [AccountInfo]
    func follow(_ id: AccountInfo.ID) async throws -> AccountInfo
    func unfollow(_ id: AccountInfo.ID) async throws -> AccountInfo
}

final class AccountRepository: AccountRepositoryProtocol {
    
    private var clientService: ClientService
    
    private var client: TootClient { clientService.client }

    private let accountService: AccountService

    init(clientService: ClientService, accountService: AccountService) {
        self.clientService = clientService
        self.accountService = accountService
    }

    func search(text: String) async throws -> [AccountInfo] {
        let params = SearchAccountsParams(query: text, resolve: true)
        let accounts = try await client.searchAccounts(params: params)
        return accounts.map(AccountInfo.init)
    }

    func getFollowing() async throws -> [AccountInfo] {
        guard let account = accountService.account else {
            return []
        }
        return try await getFollowing(account.id)
    }
    
    func getFollowing(_ id: AccountInfo.ID) async throws -> [AccountInfo] {
        let accounts = try await client.getFollowing(for: id)
        return accounts.result.map {
            AccountInfo(account: $0)
        }
    }
    
    func getFollowers() async throws -> [AccountInfo] {
        guard let account = accountService.account else {
            return []
        }
        return try await getFollowers(for: account.id)
    }
    
    func getFollowers(for id: AccountInfo.ID) async throws -> [AccountInfo] {
        let accounts = try await client.getFollowers(for: id)
        return accounts.result.map {
            AccountInfo(account: $0)
        }
    }

    func follow(_ id: AccountInfo.ID) async throws -> AccountInfo {
        _ = try await client.followAccount(by: id)
        let account = try await client.getAccount(by: id)
        return AccountInfo(account: account)
    }

    func unfollow(_ id: AccountInfo.ID) async throws -> AccountInfo {
        _ = try await client.unfollowAccount(by: id)
        let account = try await client.getAccount(by: id)
        return AccountInfo(account: account)
    }
}

struct MockAccountRepository: AccountRepositoryProtocol {
    func search(text: String) async throws -> [AccountInfo] {
        return [.mock()]
    }

    func getFollowing() async throws -> [AccountInfo] {
        return [.mock()]
    }
    
    func getFollowing(_ id: AccountInfo.ID) async throws -> [AccountInfo] {
        return [.mock()]
    }
    
    func getFollowers() async throws -> [AccountInfo] {
        return [.mock()]
    }
    
    func getFollowers(for id: AccountInfo.ID) async throws -> [AccountInfo] {
        return [.mock()]
    }

    func follow(_ id: AccountInfo.ID) async throws -> AccountInfo {
        return .mock()
    }

    func unfollow(_ id: AccountInfo.ID) async throws -> AccountInfo {
        return .mock()
    }
}
