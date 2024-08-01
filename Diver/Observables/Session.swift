//
//  Session.swift
//  Diver
//
//  Created by Gerald Burke on 7/31/24.
//

import Foundation

@MainActor @Observable final class Session {
    let repo: SessionRepositoryProtocol

    var isLoggedIn: Bool

    var failure: Failure?

    init(repo: SessionRepositoryProtocol) {
        self.repo = repo
        self.isLoggedIn = TokenService.shared.token != nil
    }
    
    func logIn() {
        Task {
            do {
                isLoggedIn = try await repo.logIn().isEmpty == false
            } catch {
                failure = Failure(error)
            }
        }
    }
}
