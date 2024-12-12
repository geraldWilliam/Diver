//
//  ContentView.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI
import ZoomView
/// The root view of the application. A new SwiftUI project generates this file by default.
/// Do not discard it. Instead, use it as the entry point of the UI. This is a good place to handle
/// presentation of things like authentication UI, version lockouts, or global error alerts.
struct ContentView: View {
    @Environment(Navigator.self) var navigator
    @Environment(Session.self) var session
    @Environment(Zoom.self) var zoom

    var body: some View {
        if session.isLoggedIn {
            @Bindable var navigator = navigator
            @Bindable var zoom = zoom
            /// The main interface of the app for logged-in users.
            TabView(selection: $navigator.tabSelection) {
                FeedNav()
                ProfileNav()
                ExploreNav()
            }
            /// Make Zoom available to child views.
            .environment(self.zoom)
            /// Show the ZoomView over all content.
            .overlay {
                ZoomView(item: $zoom.item) { item in
                    item.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: item.url, in: zoom.animation)
                        .transition(.scale(1))
                }
            }
        } else {
            LoginView()
        }
    }
}

#Preview {
    let session = Session(repo: MockSessionRepository())
    return ContentView()
        .environment(session)
}
