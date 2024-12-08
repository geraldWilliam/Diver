//
//  LoginView.swift
//  Diver
//
//  Created by Gerald Burke on 8/1/24.
//

import SwiftUI

@MainActor struct LoginView: View {
    @Environment(Session.self) var session

    var body: some View {
        @Bindable var session = session
        ZStack {
            ForEach(0..<4) { index in
                BubbleView(
                    isHidden: $session.isLoggedIn,
                    startAfter: TimeInterval(index)
                )
            }
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: 24)
                    Group {
                        Text("Welcome to Diver")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("A Fediverse Client")
                            .font(.headline)
                    }
                    .foregroundColor(Color.primary)
                    .fontDesign(.rounded)
                    AccountPicker()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(Color.loginBackground)
        .alert(isPresented: $session.showingError, error: session.failure) {
            Button(action: { session.failure = nil }) {
                Text("OK")
            }
        }
    }
}

#Preview {
    let session = Session(repo: MockSessionRepository())
    let accounts = Accounts(repo: MockAccountRepository())
    return LoginView()
        .environment(session)
        .environment(accounts)

}
