//
//  FeedNav.swift
//  Diver
//
//  Created by Gerald Burke on 8/12/24.
//

import SwiftUI

struct FeedNav: View {
    @Environment(Navigator.self) var navigator
    var body: some View {
        @Bindable var navigator = navigator
        NavigationStack(path: $navigator.feedPath) {
            FeedView()
                .navigationDestination(for: Navigator.Destination.self) { destination in
                    navigator.content(for: destination)
                }
                .sheet(item: $navigator.modal) { modal in
                    navigator.content(for: modal)
                }
        }
        .tag(Navigator.Tab.feed)
        .tabItem {
            VStack {
                Image(systemName: "list.bullet")
                Text("Feed")
            }
        }
    }
}

#Preview {
    let posts = Posts(repo: MockPostsRepository())
    let navigator = Navigator(posts: posts)
    return FeedNav()
        .environment(navigator)
}
