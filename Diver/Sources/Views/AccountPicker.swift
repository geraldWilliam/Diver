//
//  AccountPicker.swift
//  Diver
//
//  Created by Gerald Burke on 11/6/24.
//

import SwiftUI

struct AccountPicker: View {
    @Environment(Session.self) var session
    @Environment(Accounts.self) var accounts
    // TODO: Move instance list to separate view.
    @State private var instanceName: String = ""
    @State private var addingInstance: Bool = false
    @State private var showingValidationError: Bool = false
    @FocusState private var instanceFieldIsFocused: Bool

    private let scheme = "https://"

    private var instance: String {
        scheme + instanceName
    }

    var body: some View {
        VStack {
            Group {
                Button(action: { setInstanceFieldDisplayed(true) }) {
                    if addingInstance {
                        HStack(spacing: 0) {
                            Text(scheme)
                                .padding(.trailing, 4)
                            TextField("example.social", text: $instanceName)
                                .focused($instanceFieldIsFocused)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .textContentType(.URL)
                                .onSubmit {
                                    showLogin()
                                }
                        }
                    } else {
                        Label {
                            Text("Add an Account")
                        } icon: {
                            Image(systemName: "plus.circle")
                        }
                    }
                }

                ForEach(session.storedAccounts) { account in
                    Button(action: { session.logIn(as: account) }) {
                        Text(account.handle)
                    }
                }
            }
            .padding(24)
            .underlineButtonStyle()
        }
        .frame(maxHeight: 300)
        .onTapGesture {
            if addingInstance {
                setInstanceFieldDisplayed(false)
            }
        }
        .alert("\(instance) is not a valid URL", isPresented: $showingValidationError) { /**/  }
        .task {
            session.getStoredAccounts()
        }
    }

    private func setInstanceFieldDisplayed(_ displayed: Bool) {
        withAnimation {
            addingInstance = displayed
        } completion: {
            instanceFieldIsFocused = displayed
        }
    }

    private func validateInstanceName() -> Bool {
        return instanceName.count > 3 && instanceName.contains(".") && URL(string: instance) != nil
    }

    private func showLogin() {
        // TODO: Maybe there's a way to use TootSDK to check if the URL is a fedi server?
        if validateInstanceName() {
            session.addAccount(instance: instance)
            instanceName = ""
            setInstanceFieldDisplayed(false)
        } else {
            showingValidationError = true
        }
    }
}

#Preview {
    let session = Session(repo: MockSessionRepository())
    let accounts = Accounts(repo: MockAccountRepository())
    AccountPicker()
        .environment(session)
        .environment(accounts)
}
