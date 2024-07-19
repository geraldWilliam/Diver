//
//  ContentView.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI
import TootSDK

/// The root view of the application. A new SwiftUI project generates this file by default. Do not discard it. Instead, use it as the entry point of the UI. This is a good
/// place to handle presentation of things like authentication UI, version lockouts, or global error alerts.
struct ContentView: View {
    var body: some View {
        Timeline()
    }
}

#Preview {
    let mockRepo = MockPostsRepository()
    let controller = PostsController(repo: mockRepo)
    return ContentView()
        .environment(controller)
}
