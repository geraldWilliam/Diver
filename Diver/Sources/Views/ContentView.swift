//
//  ContentView.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

/// The root view of the application. A new SwiftUI project generates this file by default. Do not discard it. Instead, use it as the entry point of the UI. This is a good
/// place to handle presentation of things like authentication UI, version lockouts, or global error alerts.
struct ContentView: View {
    @Environment(Session.self) var session
    @Environment(Navigator.self) var navigator
    var body: some View {
        @Bindable var navigator = navigator
        if session.isLoggedIn {
            TabView(selection: $navigator.tabSelection) {
                TimelineNav()
                ProfileNav()
                ExploreNav()
            }
        } else {
            LoginView()
        }
    }
}

#Preview {
    let session = Session(repo: MockSessionRepository())
    let posts = Posts(repo: MockPostsRepository())
    let navigator = Navigator(posts: posts)
    return ContentView()
        .environment(session)
        .environment(posts)
        .environment(navigator)
}
