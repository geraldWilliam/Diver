//
//  ProfileView.swift
//  Diver
//
//  Created by Gerald Burke on 10/25/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(Accounts.self) var accounts
    @Environment(Session.self) var session
    let account: AccountInfo
    
    var body: some View {
        ScrollView {
            LazyVStack {
                AsyncImage(url: account.headerImage) { image in
                    image
                        .resizable()
                } placeholder: {
                    Image(systemName: "exclamationmark.circle")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                HStack {
                    AsyncImage(url: account.profileImage) { image in
                        image
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } placeholder: {
                        Image(systemName: "exclamationmark.circle")
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .padding()
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text(account.displayName)
                            .font(.headline)
                        Text(account.handle)
                            .foregroundStyle(Color.secondary)
                    }
                }

                VStack(alignment: .leading) {
                    if accounts.following.contains(account) {
                        Button(action: { /*authors.unfollow(account.id)*/ }) {
                            Text("Unfollow")
                        }
                    } else if account != session.currentSession?.account {
                        Button(action: { accounts.follow(account.id) }) {
                            Text("Follow")
                        }
                    }
                    // TODO: Follow requests.
                }
                .buttonStyle(BorderedButtonStyle())

                VStack {
                    Row(
                        title: "\(account.followersCount) Followers",
                        action: {}
                    )
                    Divider()
                    Row(
                        title: "Following \(account.followingCount)",
                        action: {}
                    )
                    Divider()
                    Row(
                        title: "\(account.postCount) Posts",
                        action: {}
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    List {
        ProfileView(account: .mock())
    }
    .environment(Accounts(repo: MockAccountRepository()))
    .environment(Session(repo: MockSessionRepository()))
}

private struct Row: View {
    let title: String
    let action: () -> Void
    var body: some View {
        HStack {
            Button(action: action) { Text(title) }
            Spacer()
        }
    }
}
