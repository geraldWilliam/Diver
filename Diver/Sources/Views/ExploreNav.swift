//
//  ExploreNav.swift
//  Diver
//
//  Created by Gerald Burke on 10/25/24.
//

import SwiftUI

struct ExploreNav: View {
    @Environment(Navigator.self) var navigator
    var body: some View {
        @Bindable var navigator = navigator
        NavigationStack(path: $navigator.explorePath) {
            ExploreView()
                .navigationDestination(for: Navigator.Destination.self) { destination in
                    navigator.content(for: destination)
                }
                .sheet(item: $navigator.modal) { modal in
                    navigator.content(for: modal)
                }
        }
        .tag(Navigator.Tab.explore)
        .tabItem {
            VStack {
                Image(systemName: "magnifyingglass")
                Text("Explore")
            }
        }
    }
}

#Preview {
    let posts = Posts(repo: MockPostsRepository())
    let navigator = Navigator(posts: posts)
    return ExploreNav()
        .environment(navigator)
}
