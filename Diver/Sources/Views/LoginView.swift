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
            BubbleView(isHidden: $session.isLoggedIn)
            ScrollView {
                CardView {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text("WELCOME TO")
                                .font(.subheadline)
                                .fontWeight(.light)

                            Text("Diver")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)

                            Text("A FEDIVERSE CLIENT")
                                .font(.headline)
                                .fontWeight(.light)
                        }
                        .foregroundColor(Color.primary)

                        AccountPicker()
                    }
                    .padding(.vertical, 20)
                }
                .offset(y: 100)
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    .loginBackgroundLight,
                    .loginBackgroundDark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
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
