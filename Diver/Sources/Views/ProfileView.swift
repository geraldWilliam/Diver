//
//  ProfileView.swift
//  Diver
//
//  Created by Gerald Burke on 10/25/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(Authors.self) var authors
    @Environment(Session.self) var session
    let account: AccountInfo
    var body: some View {
        LazyVStack {
            HStack {
                AsyncImage(url: account.profileImage) { image in
                    image
                        .resizable()
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "exclamationmark.circle")
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 60, height: 60)
                Divider()
                VStack(alignment: .leading) {
                    Text(account.displayName)
                        .font(.title)
                    Text(account.handle)
                        .foregroundStyle(Color.secondary)
                }
            }
            
            VStack(alignment: .leading) {
                if authors.following.contains(account) {
                    Button(action: { /*authors.unfollow(account.id)*/ }) {
                        Text("Unfollow")
                    }
                } else if account != session.currentAccount {
                    Button(action: { authors.follow(account.id) }) {
                        Text("Follow")
                    }
                }
                // TODO: Follow requests.
            }
            .buttonStyle(BorderedButtonStyle())

            VStack {
                Row(
                    title: "\(123) Followers",
                    action: { }
                )
                Divider()
                Row(
                    title: "Following \(123)",
                    action: { }
                )
                Divider()
                Row(
                    title: "\(account.postCount) Posts",
                    action: { }
                )
            }
        }
    }
}

#Preview {
    List {
        ProfileView(account: .mock())
    }
    .environment(Authors(repo: MockAccountRepository()))
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
