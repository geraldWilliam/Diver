//
//  Authors.swift
//  Diver
//
//  Created by Gerald Burke on 10/25/24.
//

import Foundation

@Observable final class Authors {
    let repo: AccountRepositoryProtocol
    var displayed: [AccountInfo] = []
    var followed: [AccountInfo] = []
    var failure: Failure?
    
    init(repo: AccountRepositoryProtocol) {
        self.repo = repo
    }
    
    func search(_ text: String) {
        Task {
            do {
                displayed = try await repo.search(text: text)
            } catch {
                failure = Failure(error)
            }
        }
    }
    
    func follow(_ id: AccountInfo.ID) {
        Task {
            do {
                let account = try await repo.follow(id)
                followed.append(account)
                displayed.firstIndex(where: { $0.id == id }).map { displayed[$0] = account }
            } catch {
                failure = Failure(error)
            }
        }
    }
}
