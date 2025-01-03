//
//  ProfileNav.swift
//  Diver
//
//  Created by Gerald Burke on 8/12/24.
//

import SwiftUI

struct ProfileNav: View {
    @Environment(Navigator.self) var navigator
    @Environment(Session.self) var session
    var body: some View {
        @Bindable var navigator = navigator
        NavigationStack(path: $navigator.profilePath) {
            session.currentSession.map {
                ProfileView(account: $0.account)
                    .navigationDestination(for: Navigator.Destination.self) { destination in
                        navigator.content(for: destination)
                    }
            }
        }
        .tag(Navigator.Tab.profile)
        .tabItem {
            VStack {
                Image(systemName: "person")
                Text("Profile")
            }
        }
    }
}

#Preview {
    let posts = Posts(repo: MockPostsRepository())
    let navigator = Navigator(posts: posts)
    return ProfileNav()
        .environment(navigator)
}
