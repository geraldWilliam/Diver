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
    @Environment(Navigator.self) var navigator
    
    private enum ContentMode {
        case followers
        case following
        case posts
    }
    
    @State private var followers: [AccountInfo] = []
    @State private var following: [AccountInfo] = []
    
    let account: AccountInfo
    
    @State private var selectedContentMode: ContentMode = .followers
    
    var body: some View {
        ScrollView {
            VStack {
                Header(account: account)
                    .padding(.horizontal)
                
                Text(account.attributedBio ?? "")
                
                Picker(selection: $selectedContentMode) {
                    Text("Followers: \(account.followersCount) ")
                        .tag(ContentMode.followers)
                    Text("Following: \(account.followingCount)")
                        .tag(ContentMode.following)
                    Text("Posts: \(account.postCount)")
                        .tag(ContentMode.posts)
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                ScrollView(.horizontal) {
                    VStack {
                        HStack {
                            switch selectedContentMode {
                            case .followers:
                                ForEach(followers) { account in
                                    Card(account: account)
                                        .containerRelativeFrame(.horizontal, count: 5, span: 4, spacing: 0)
                                        .onTapGesture {
                                            navigator.go(to: .profile(account))
                                        }
                                }
                            case .following:
                                ForEach(following) { account in
                                    Card(account: account)
                                        .containerRelativeFrame(.horizontal, count: 5, span: 4, spacing: 0)
                                        .onTapGesture {
                                            navigator.go(to: .profile(account))
                                        }
                                }
                            case .posts:
                                ContentUnavailableView("Unimplemented Screen.", systemImage: "exclamationmark.circle")
                            }
                        }
                        .padding(.horizontal, 30)
                        .scrollTargetLayout()
                    }
                }
                .scrollTargetBehavior(.viewAligned)
            }
        }
        .task {
            // Accounts the current account follows.
            followers = await accounts.followers(for: account)
            // Accounts that follow the current account.
            following = await accounts.following(account)
        }
    }
}

private extension ProfileView {
    
    struct HeaderImage: View {
        let account: AccountInfo
        var body: some View {
            ZStack {
                AsyncImage(url: account.headerImage) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 200)
                        .clipShape(
                            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 5, topTrailing: 5))
                        )
                } placeholder: {
                    Image(systemName: "exclamationmark.circle")
                        .frame(height: 200)
                }
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.black.opacity(0.8), .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
            }
            .frame(maxWidth: .infinity)
            .clipped()
        }
    }

    struct ProfileImage: View {
        let account: AccountInfo
        var body: some View {
            AsyncImage(url: account.profileImage) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                Rectangle().fill(.clear)
            }
        }
    }

    struct NameTag: View {
        let account: AccountInfo
        var body: some View {
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
        }
    }

    struct Header: View {
        @Environment(Accounts.self) var accounts
        @Environment(Session.self) var session
        let account: AccountInfo
        var body: some View {
            VStack {
                ZStack {
                    HeaderImage(account: account)
                    // Nested stack to get bottom-left alignment for pfp.
                    VStack {
                        Spacer()
                        HStack {
                            ProfileImage(account: account)
                                .frame(width: 70, height: 70)
                                .padding([.leading, .bottom], 12)
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
                }
                NameTag(account: account)
            }
            .ignoresSafeArea()
        }
    }

    struct Card: View {
        let account: AccountInfo
        var body: some View {
            VStack {
                CardView {
                    VStack {
                        ZStack {
                            HeaderImage(account: account)
                            VStack {
                                Spacer()
                                HStack {
                                    ProfileImage(account: account)
                                    Spacer()
                                }
                            }
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        }
                        NameTag(account: account)
                            .padding(.horizontal)
                        Divider()
                        Text(account.attributedBio ?? "")
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .padding(.bottom)
                    }
                }
                Spacer()
                    .frame(minHeight: 0)
            }
        }
    }
}

#Preview {
    ProfileView(account: .mock())
        .environment(Accounts(repo: MockAccountRepository()))
        .environment(Session(repo: MockSessionRepository()))
        .environment(Navigator(posts: Posts(repo: MockPostsRepository())))
}
