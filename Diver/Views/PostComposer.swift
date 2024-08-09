//
//  PostComposer.swift
//  Diver
//
//  Created by Gerald Burke on 8/2/24.
//

import SwiftUI

@MainActor struct PostComposer: View {
    @Environment(Navigator.self) var navigator
    @Environment(Posts.self) var posts
    @State private var textContent: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Write a post", text: $textContent, axis: .vertical)
                    .padding()
                    .lineLimit(8...)
                    .focused($isFocused)
                    .overlay {
                        RoundedRectangle(cornerSize: CGSize(width: 12, height: 12))
                            .stroke(Color.gray, lineWidth: 1.0)
                    }
                    .padding()
                   
                Spacer()

                HStack {
                    Button(action: { }) {
                        Image(systemName: "number")
                            .frame(maxWidth: .infinity)
                    }
                    Button(action: { }) {
                        Image(systemName: "photo")
                            .frame(maxWidth: .infinity)
                    }
                    Button(action: { }) {
                        Image(systemName: "at")
                            .frame(maxWidth: .infinity)
                    }
                    Button(action: { }) {
                        Image(systemName: "exclamationmark.triangle")
                            .frame(maxWidth: .infinity)
                    }
                }
                .primaryButtonStyle()
                .frame(maxWidth: .infinity)
                .padding()
            }
            .onAppear {
                isFocused = true
            }
            .navigationTitle("Compose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { cancelPost() }) {
                        Text("Cancel")
                    }
                }
                ToolbarItem {
                    Button(action: { sendPost() }) {
                        Text("Send")
                    }
                }
            }
        }
    }
    
    private func cancelPost() {
        navigator.modal = nil
    }
    
    private func sendPost() {
        posts.publish(textContent)
        navigator.modal = nil
    }
}

#Preview {
    let posts = Posts(repo: MockPostsRepository())
    let navigator = Navigator(posts: posts)
    return PostComposer()
        .environment(posts)
        .environment(navigator)
}
