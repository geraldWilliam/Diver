//
//  Timeline.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

struct Timeline: View {
    @Environment(PostsController.self) var postsController
    var body: some View {
        @Bindable var controller = postsController
        List(controller.posts) { post in
            /// NavigationLink‘s value is appended to the navigation stack‘s path. See the `navigationDestination` modifier for handling.
            NavigationLink(value: Navigator.Destination.postDetail(post)) {
                /// The “label“ for the navigation link. This is the view displayed in the list row.
                PostView(post: post, hideReplyCount: false)
            }
        }
        .navigationTitle("Home")
        .listStyle(.plain)
        .toolbar {
            ToolbarItem {
                Button(action: { /* TODO: Present Post Composer */}) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .alert(isPresented: $controller.showingError, error: controller.failure) {
            Button(action: { controller.failure = nil }) {
                Text("OK")
            }
        }
        .task {
            controller.getPosts()
        }
        .refreshable {
            controller.getPosts()
        }
    }
}

#Preview {
    let mockRepo = MockPostsRepository()
    let controller = PostsController(repo: mockRepo)
    return Timeline()
        .environment(controller)
    
}
