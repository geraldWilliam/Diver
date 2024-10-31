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
        VStack {
            AsyncImage(url: account.profileImage) { output in
                output.image?
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            }
            Text(account.displayName)
                .font(.title)
            Text(account.handle)
                .foregroundStyle(Color.secondary)


                Text("\(123) Followers")
                    .padding()
                    .overlay {
                        UnevenRoundedRectangle(cornerRadii: .init(topLeading: 5, bottomLeading: 5))
                            .fill(Color.clear)
                            .stroke(Color.black)
                            
                    }
                Text("Following \(123)")
                    .padding()
                    .overlay {
                        UnevenRoundedRectangle(cornerRadii: .init(bottomTrailing: 5, topTrailing: 5))
                            .fill(Color.clear)
                            .stroke(Color.black)
                    }

            Group {
                if authors.following.contains(account) {
                    Button(action: { authors.follow(account.id) }) {
                        Text("Follow")
                    }
                } else if account != session.currentAccount {
                    Button(action: { authors.follow(account.id) }) {
                        Text("Unfollow")
                    }
                }
            }
            .buttonStyle(BorderedButtonStyle())

            Button(action: { }) {
                Text("\(account.postCount) Posts")
            }
            .buttonStyle(BorderedButtonStyle())
        }
    }
}

#Preview {
    ProfileView(account: .mock())
        .environment(Authors(repo: MockAccountRepository()))
        .environment(Session(repo: MockSessionRepository()))
}
