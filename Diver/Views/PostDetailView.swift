//
//  PostDetailView.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

/// The detail screen for a post. It shows the post and its replies.
struct PostDetailView: View {
    @State var postDetailController: PostDetailController
    let post: PostInfo
    var body: some View {
        List {
            Section {
                PostView(post: post, hideReplyCount: true)
            }
            Section {
                ForEach(postDetailController.replies) { post in
                    NavigationLink(value: post) {
                        PostView(post: post, hideReplyCount: false)
                    }
                }
            }
        }
        .navigationTitle("Detail")
        .toolbarTitleDisplayMode(.inline)
        .listStyle(.plain)
        .task {
            postDetailController.getReplies(for: post)
        }
    }
}

#Preview {
    let repo = MockPostsRepository()
    let controller = PostDetailController(repo: repo)
    return PostDetailView(postDetailController: controller, post: PostInfo.mock())
}
