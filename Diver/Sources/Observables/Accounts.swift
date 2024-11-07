//
//  Authors.swift
//  Diver
//
//  Created by Gerald Burke on 10/25/24.
//

import Foundation

@Observable final class Accounts {
    let repo: AccountRepositoryProtocol
    var searchResults: [AccountInfo] = []
    var following: [AccountInfo] = []
    var failure: Failure?
    
    init(repo: AccountRepositoryProtocol) {
        self.repo = repo
        Task {
            do {
                following = try await repo.getFollowing()
            } catch {
                failure = Failure(error)
            }
        }
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
}
