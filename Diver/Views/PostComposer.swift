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

    @State private var attachedMedia: [(URL, UUID)] = [
        (URL(string: "https://picsum.photos/100/100")!, UUID()),
        (URL(string: "https://picsum.photos/100/100")!, UUID()),
        (URL(string: "https://picsum.photos/100/100")!, UUID()),
    ]

    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TextField("Write a post", text: $textContent, axis: .vertical)
                        .padding()
                        .lineLimit(8...)
                        .focused($isFocused)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 1.0)
                        }
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(attachedMedia, id: \.1) { item in
                                AsyncImage(url: item.0)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 10)
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white)
                                    }
                                    
                            }
                        }
                        .padding()
                        .shadow(radius: 2)
                    }
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
                    ToolbarItemGroup(placement: .keyboard) {
                        HStack {
                            Button(action: { }) {
                                Image(systemName: "number")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            Button(action: { }) {
                                Image(systemName: "photo")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            Button(action: { }) {
                                Image(systemName: "at")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            Button(action: { }) {
                                Image(systemName: "exclamationmark.triangle")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .frame(maxWidth: .infinity)
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
