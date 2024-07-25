//
//  Timeline.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

struct TimelineView: View {
    @Environment(Posts.self) var posts
    @Environment(Notifications.self) var notifications
    var body: some View {
        @Bindable var posts = posts
        List {
            ForEach(posts.timeline) { post in
                /// NavigationLink‘s value is appended to the navigation stack‘s path. See the `navigationDestination` modifier for handling.
                NavigationLink(value: Navigator.Destination.postDetail(post)) {
                    /// The “label“ for the navigation link. This is the view displayed in the list row.
                    PostView(post: post, hideReplyCount: false)
                }
            }
            Button(action: { posts.getNextPage() }) {
                Text("Get More")
            }
        }
        .navigationTitle("Home")
        .listStyle(.plain)
        .toolbar {
            if notifications.canRequestAuthorization {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { notifications.requestAuthorization() }) {
                        Image(systemName: "app.badge")
                    }
                }
            }
            ToolbarItem {
                Button(action: { /* TODO: Present Post Composer */}) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .alert(isPresented: $posts.showingError, error: posts.failure) {
            Button(action: { posts.failure = nil }) {
                Text("OK")
            }
        }
        .task {
            posts.getPosts()
        }
        .refreshable {
            posts.getPosts()
        }
    }
}

#Preview {
    let mockRepo = MockPostsRepository()
    let posts = Posts(repo: mockRepo)
    return TimelineView()
        .environment(posts)

}
