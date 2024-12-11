//
//  Session.swift
//  Diver
//
//  Created by Gerald Burke on 7/31/24.
//

import AuthenticationServices
import Foundation
import SwiftUI

@MainActor @Observable final class Session {
    /// A type to represent the state of the logout process. Logout requires confirmation. The view that initiates logout should present an alert if Session‘s
    /// `promptLogoutConfirmation` value is true. When the alert is cancelled, call Session‘s  `cancelLogout` which sets `logout` back to
    /// `undetermined`. If logout is confirmed, call Session‘s `confirmLogout` which sets `logout` to `confirmed`.
    enum Logout {
        case undetermined
        case requested
        case confirmed
    }

    let repo: SessionRepositoryProtocol

    var storedAccounts: [AccountInfo] = []

    /// Whether the Session is authenticated.
    var isLoggedIn: Bool

    /// The currently authenticated account.
    // TODO: It might be nice to have multiple accounts logged in at once eventually.
    var currentSession: SessionInfo?

    /// The state of the Session‘s logout process.
    var logout: Logout = .undetermined

    /// A property for binding to a confirmation alert.
    var promptLogoutConfirmation: Bool = false

    /// A Failure value for publishing errors.
    var failure: Failure?

    /// A property for binding to an error alert.
    var showingError: Bool = false

    // MARK: - Initialization

    init(repo: SessionRepositoryProtocol) {
        self.repo = repo
        self.isLoggedIn = false // repo.isLoggedIn
        observeFailure()
    }

    // MARK: - Methods

    func getStoredAccounts() {
        Task {
            do {
                storedAccounts = try repo.getStoredAccounts()
            } catch {
                failure = Failure(error)
            }
        }
    }

    func store(_ session: SessionInfo) {
        Task {
            do {
                storedAccounts.append(try repo.store(session.account))
            } catch {
                failure = Failure(error)
            }
        }
    }

    func addAccount(instance: String) {
        guard let url = URL(string: instance) else {
            failure = Failure("Invalid URL: \(instance)")
            return
        }
        Task {
            do {
                store(try await repo.getSession(instance: url))
                observeLogout()
                logout = .undetermined
            } catch {
                failure = Failure(error)
            }
        }
    }

    func logIn(as account: AccountInfo) {
        if let token = TokenService().token(for: account) {
            currentSession = SessionInfo(token: token, account: account)
            withAnimation {
                isLoggedIn = true
            }
            observeLogout()
        }
    }

    /// Prompt logout. This should result in an alert with cancel and confirm actions.
    func requestLogout() {
        logout = .requested
        promptLogoutConfirmation = true
    }

    /// An action to handle cancellation of logout request.
    func cancelLogout() {
        logout = .undetermined
    }

    /// An action to confirm logout.
    func confirmLogout() {
        logout = .confirmed
    }

    // MARK: - Private

    private func observeLogout() {
        withObservationTracking {
            _ = logout
        } onChange: {
            Task {
                await self.handleLogoutChange()
            }
        }
    }

    private func handleLogoutChange() {
        switch logout {
        case .undetermined, .requested:
            /// If logout has not been confirmed, continue observation.
            observeLogout()
        case .confirmed:
            withAnimation {
                isLoggedIn = false
            }
        }
    }

    private func observeFailure() {
        withObservationTracking {
            /// The repository throws an error if the user cancels the login flow. Rather than obscuring that behind a custom error, I just import
            /// AuthenticationServices here in the observable and check for the error I want to ignore.
            if case .canceledLogin = (failure?.underlyingError as? ASWebAuthenticationSessionError)?.code {
                return
            }
            /// Any other errors should be presented to the user.
            showingError = failure != nil
        } onChange: {
            Task {
                await self.observeFailure()
            }
        }
    }
}
