//
//  PostComposer.swift
//  Diver
//
//  Created by Gerald Burke on 8/2/24.
//

import SwiftUI
import PhotosUI

@MainActor struct PostComposer: View {
    @Environment(Navigator.self) var navigator
    @Environment(Posts.self) var posts
    
    let post: PostInfo?

    @State private var contentWarning: String = ""
    @State private var textContent: String = ""

    @State private var attachedMedia: [PhotosPickerItem] = []
    @State private var displayedImages: [Data] = []

    @FocusState private var isComposeFieldFocused: Bool
    
    private var placeholder: String {
        if post != nil {
            "Write your reply"
        } else {
            "Write a post"
        }
    }
    
    private var isPostIncomplete: Bool {
        textContent.isEmpty && displayedImages.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    /// The original post for replies
                    if let post {
                        ZStack {
                            HStack {
                                Text(post.attributedBody ?? "")
                                Spacer()
                            }
                            .padding()
                        }
                        .background(Color.black.opacity(0.05))
                    }
                    
                    VStack {
                        /// Content Warning
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                            TextField("Content Warning (Optional)", text: $contentWarning)
                                .lineLimit(1)
                        }

                        Divider()

                        /// Text Compose
                        TextField(placeholder, text: $textContent, axis: .vertical)
                            .lineLimit(8...)
                            .focused($isComposeFieldFocused)
                    }
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1.0)
                    }
                    .padding(.horizontal)
                    
                    /// Media attachment
                    PhotosPicker("Choose Media", selection: $attachedMedia, matching: .images)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(displayedImages, id: \.self) { data in
                                if let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                        .padding()
                        .shadow(radius: 2)
                    }
                }
                .onAppear {
                    isComposeFieldFocused = true
                }
                .navigationTitle(post == nil ? "Compose" : "Reply")
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
                        .disabled(isPostIncomplete)
                    }
                }
                .onChange(of: attachedMedia) { oldValue, newValue in
                    Task {
                        displayedImages.removeAll()
                        for item in newValue {
                            if let image = try? await item.loadTransferable(type: Data.self) {
                                displayedImages.append(image)
                            }
                        }
                    }
                }
            }
        }
    }

    private func sendPost() {
        if isPostIncomplete {
            return
        }
        if let post {
            posts.reply(textContent, media: displayedImages, to: post)
        } else {
            posts.publish(textContent, media: displayedImages)
        }
        navigator.modal = nil
    }
    
    private func cancelPost() {
        navigator.modal = nil
    }
}

#Preview {
    let posts = Posts(repo: MockPostsRepository())
    let navigator = Navigator(posts: posts)
    return PostComposer(post: nil)
        .environment(posts)
        .environment(navigator)
}
