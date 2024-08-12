//
//  TimelineNav.swift
//  Diver
//
//  Created by Gerald Burke on 8/12/24.
//

import SwiftUI

struct TimelineNav: View {
    @Environment(Navigator.self) var navigator
    var body: some View {
        @Bindable var navigator = navigator
        NavigationStack(path: $navigator.timelinePath) {
            TimelineView()
                .navigationDestination(for: Navigator.Destination.self) { destination in
                    navigator.content(for: destination)
                }
                .sheet(item: $navigator.modal) { modal in
                    navigator.content(for: modal)
                }
        }
        .tag(Navigator.Tab.timeline)
        .tabItem {
            VStack {
                Image(systemName: "list.bullet")
                Text("Timeline")
            }
        }
    }
}

#Preview {
    let session = Session(repo: MockSessionRepository())
    let posts = Posts(repo: MockPostsRepository())
    let navigator = Navigator(posts: posts)
    return TimelineNav()
        .environment(navigator)
}
