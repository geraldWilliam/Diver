//
//  Accounts.swift
//  Diver
//
//  Created by Gerald Burke on 10/25/24.
//

import Foundation

@MainActor @Observable final class Accounts {
    let repo: AccountRepositoryProtocol
    var searchResults: [AccountInfo] = []
    var following: [AccountInfo] = []
    var failure: Failure?

    init(repo: AccountRepositoryProtocol) {
        self.repo = repo
    }

    func search(_ text: String) {
        Task {
            do {
                searchResults = try await repo.search(text: text)
            } catch {
                failure = Failure(error)
            }
        }
    }

    func getFollowing() {
        Task {
            do {
                following = try await repo.getFollowing()
            } catch {
                failure = Failure(error)
            }
        }
    }

    func follow(_ id: AccountInfo.ID) {
        Task {
            do {
                let account = try await repo.follow(id)
                following.append(account)
                searchResults.firstIndex(where: { $0.id == id }).map { searchResults[$0] = account }
            } catch {
                failure = Failure(error)
            }
        }
    }

    func unfollow(_ id: AccountInfo.ID) {
        Task {
            do {
                let account = try await repo.unfollow(id)
                following.removeAll { $0.id == id }
                searchResults.firstIndex(where: { $0.id == id }).map { searchResults[$0] = account }
            } catch {
                failure = Failure(error)
            }
        }
    }
    
    func following(_ account: AccountInfo) async -> [AccountInfo] {
        do {
            return try await repo.getFollowing(account.id)
        } catch {
            failure = Failure(error)
            return []
        }
    }
    
    func followers(for account: AccountInfo) async -> [AccountInfo] {
        do {
            return try await repo.getFollowers(for: account.id)
        } catch {
            failure = Failure(error)
            return []
        }
    }
}
