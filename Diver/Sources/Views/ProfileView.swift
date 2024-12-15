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
    @State private var selectedContentMode: Int = 0
    var body: some View {
        ScrollView {
            LazyVStack {
                ZStack {
                    AsyncImage(url: account.headerImage) { image in
                        image
                            .resizable()
                            .frame(maxWidth: .infinity)
                    } placeholder: {
                        Image(systemName: "exclamationmark.circle")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .overlay {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.black.opacity(0.8), .clear],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                    }
                 
                    // Nested stack to get bottom-left alignment for pfp.
                    VStack {
                        Spacer()
                        HStack {
                            AsyncImage(url: account.profileImage) { image in
                                image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } placeholder: {
                                EmptyView()
                            }
                            .frame(width: 70, height: 70)
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                if accounts.following.contains(account) {
                                    Button(action: { accounts.unfollow(account.id) }) {
                                        Text("Unfollow")
                                            .foregroundStyle(Color.white)
                                    }
                                } else if account != session.currentSession?.account {
                                    Button(action: { accounts.follow(account.id) }) {
                                        Text("Follow")
                                            .foregroundStyle(Color.white)
                                    }
                                }
                            }
                            .buttonStyle(BorderedButtonStyle())
                        }
                    }
                    .padding()
                }

                HStack {
                    VStack(alignment: .leading) {
                        Text(account.displayName)
                            .font(.headline)
                        Text(account.handle)
                            .foregroundStyle(Color.secondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.leading)
                .padding(.vertical)
                
                // TODO: Extract above into separate view. AccountView? AuthorView?
                
                Picker(selection: $selectedContentMode) {
                    Text("Followers: \(account.followersCount) ")
                        .tag(0)
                    Text("Following: \(account.followingCount)")
                        .tag(1)
                    Text("Posts: \(account.postCount)")
                        .tag(2)
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
                
                List {
                    ForEach(0..<account.followersCount, id: \.self) { index in
                        
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ProfileView(account: .mock())
        .environment(Accounts(repo: MockAccountRepository()))
        .environment(Session(repo: MockSessionRepository()))
}
