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
    func follow(_ id: Account.ID) async throws -> AccountInfo
}

final class AccountRepository: AccountRepositoryProtocol {
    
    let client: TootClient
    
    init(client: TootClient) {
        self.client = client
    }
    
    func search(text: String) async throws -> [AccountInfo] {
        let params = SearchAccountsParams(query: text, resolve: true)
        let accounts = try await client.searchAccounts(params: params)
        return accounts.map(AccountInfo.init)
    }
    
    func follow(_ id: TootSDK.Account.ID) async throws -> AccountInfo {
        _ = try await client.followAccount(by: id)
        let account = try await client.getAccount(by: id)
        return AccountInfo(account: account)
    }
}

struct MockAccountRepository: AccountRepositoryProtocol {
    func search(text: String) async throws -> [AccountInfo] {
        return [.mock()]
    }
    
    func follow(_ id: TootSDK.Account.ID) async throws -> AccountInfo {
        return .mock()
    }
}
