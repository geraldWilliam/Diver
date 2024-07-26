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
    @Environment(Navigator.self) var navigator
    var body: some View {
        @Bindable var navigator = navigator
        NavigationStack(path: $navigator.path) {
            TimelineView()
                .navigationDestination(for: Navigator.Destination.self) { destination in
                    navigator.content(for: destination)
                }
                .sheet(item: $navigator.modal) { modal in
                    navigator.content(for: modal)
                }
        }
    }
}

#Preview {
    let mockRepo = MockPostsRepository()
    let posts = Posts(repo: mockRepo)
    return ContentView()
        .environment(posts)
}
