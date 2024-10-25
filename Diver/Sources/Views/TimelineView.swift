//
//  Timeline.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

struct TimelineView: View {
    @Environment(Session.self) var session
    @Environment(Posts.self) var posts
    @Environment(Navigator.self) var navigator
    @Environment(Notifications.self) var notifications

    var body: some View {
        @Bindable var session = session
        @Bindable var posts = posts
        List {
            ForEach(posts.timeline) { post in
                /// NavigationLink‘s value is appended to the navigation stack‘s path. See the `navigationDestination` modifier for handling.
                NavigationLink(value: Navigator.Destination.postDetail(post)) {
                    /// The “label“ for the navigation link. This is the view displayed in the list row.
                    PostView(post: post, isPreview: true)
                }
                // Infinite scroll
                .onAppear {
                    if post == posts.timeline.last {
                        posts.getEarlierPosts()
                    }
                }
            }
        }
        .animation(.easeInOut, value: posts.timeline)
        .navigationTitle("Diver")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.plain)
        .toolbar {
            if notifications.canRequestAuthorization {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { notifications.requestAuthorization() }) {
                        Image(systemName: "app.badge")
                    }
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { session.requestLogout() }) {
                    Image(systemName: "person.slash")
                }
            }
            ToolbarItem {
                Button(action: { navigator.present(.postComposer(post: nil)) }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .alert(isPresented: $posts.showingError, error: posts.failure) {
            Button(action: { posts.failure = nil }) {
                Text("OK")
            }
        }
        .alert("Log Out?", isPresented: $session.promptLogoutConfirmation) {
            Button(action: { session.cancelLogout() }) {
                Text("Cancel")
            }
            Button(action: { session.confirmLogout() }) {
                Text("Confirm")
            }
        }
        .refreshable {
            posts.getLatestPosts()
        }
    }
}

#Preview {
    let sessionRepo = MockSessionRepository()
    let session = Session(repo: sessionRepo)
    let mockPostsRepo = MockPostsRepository()
    let posts = Posts(repo: mockPostsRepo)
    let navigator = Navigator(posts: posts)
    let notifications = Notifications(app: .shared)

    posts.getLatestPosts()

    return TimelineView()
        .environment(session)
        .environment(posts)
        .environment(navigator)
        .environment(notifications)
}
