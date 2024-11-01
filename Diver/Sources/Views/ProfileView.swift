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
                AsyncImage(url: account.profileImage) { output in
                    output.image?
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                }
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
            }
            .buttonStyle(BorderedButtonStyle())

            VStack(alignment: .leading) {
                Button(action: { }) { Text("\(123) Followers") }
                    .frame(maxWidth: .infinity)
                Divider()
                Button(action: { }) { Text("Following \(123)") }
                    .frame(maxWidth: .infinity)
                Divider()
                Button(action: { }) { Text("\(account.postCount) Posts") }
                    .frame(maxWidth: .infinity)
            }
            .scrollDisabled(true)
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
